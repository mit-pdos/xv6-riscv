#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// For LIS system call
#include "lis.h" // For engine_table, num_lis_engines, engine_func_t

// MAX_LIS_DATA_SIZE defines the maximum size for kernel-side input and output buffers
// used in sys_lis_invoke. This limits the amount of data that can be passed to/from
// an LIS engine in a single call, preventing excessive kernel memory usage.
#define MAX_LIS_DATA_SIZE 256

// External declarations for the LIS engine table and the count of registered engines.
// These are defined in kernel/lis_engines.c.
extern struct local_engine engine_table[];
extern int num_lis_engines;

// sys_lis_invoke: System call to invoke a Local Inference Support (LIS) engine.
// Arguments are fetched from the user process's trap frame:
//   a0 (engine_id): Integer ID of the LIS engine to invoke.
//   a1 (user_input_ptr): User-space pointer to the input data buffer.
//   a2 (input_len): Length of the input data in bytes.
//   a3 (user_output_ptr): User-space pointer to the buffer where results will be written.
//   a4 (output_len): Capacity of the user-space output buffer in bytes.
// Returns:
//   On success: The actual number of bytes written to the user_output_ptr buffer (non-negative).
//               This value is provided by the LIS engine itself.
//   On failure: A negative error code indicating the type of error:
//     -1 (LIS_ERR_INVALID_ARG_FETCH): General error fetching system call arguments.
//     -2 (LIS_ERR_INVALID_ID): The provided engine_id is out of bounds, or the engine is not initialized.
//     -3 (LIS_ERR_INVALID_ARG_SIZE): input_len or output_len is invalid (e.g., negative or exceeds MAX_LIS_DATA_SIZE).
//     -4 (LIS_ERR_COPYIN): Failed to copy input data from user space to kernel space.
//     -5 (LIS_ERR_ENGINE_EXEC): The LIS engine function returned an error (non-zero value).
//     -6 (LIS_ERR_ENGINE_BAD_OUTPUT_LEN): The LIS engine reported an actual_out_len that is negative or exceeds the user's output buffer capacity.
//     -7 (LIS_ERR_COPYOUT): Failed to copy output data from kernel space to user space.
uint64
sys_lis_invoke(void)
{
  int engine_id;               // ID of the LIS engine to invoke.
  uint64 user_input_ptr_addr;  // Address of the user-space input buffer.
  int input_len;               // Length of the input data.
  uint64 user_output_ptr_addr; // Address of the user-space output buffer.
  int output_len;              // Capacity of the user-space output buffer.

  // Step 1: Fetch system call arguments from the trap frame.
  // Corresponds to: lis_invoke(engine_id, input_ptr, input_len, output_ptr, output_len)
  if (argint(0, &engine_id) < 0) return -1;             // engine_id from a0
  if (argaddr(1, &user_input_ptr_addr) < 0) return -1;  // input_ptr from a1
  if (argint(2, &input_len) < 0) return -1;             // input_len from a2
  if (argaddr(3, &user_output_ptr_addr) < 0) return -1; // output_ptr from a3
  if (argint(4, &output_len) < 0) return -1;            // output_len from a4

  // Cast user-space addresses to pointers.
  char *user_input_ptr = (char*)user_input_ptr_addr;
  char *user_output_ptr = (char*)user_output_ptr_addr;

  // Step 2: Validate arguments.
  // Check if engine_id is within the range of registered engines.
  if (engine_id < 0 || engine_id >= num_lis_engines) {
    printf("sys_lis_invoke: invalid engine_id %d (num_engines: %d)\n", engine_id, num_lis_engines);
    return -2; // LIS_ERR_INVALID_ID
  }
  // Validate input length.
  if (input_len < 0 || input_len > MAX_LIS_DATA_SIZE) {
    printf("sys_lis_invoke: invalid input_len %d (max: %d)\n", input_len, MAX_LIS_DATA_SIZE);
    return -3; // LIS_ERR_INVALID_ARG_SIZE
  }
  // Validate output buffer capacity provided by the user.
  if (output_len < 0 || output_len > MAX_LIS_DATA_SIZE) {
    printf("sys_lis_invoke: invalid output_len (capacity) %d (max: %d)\n", output_len, MAX_LIS_DATA_SIZE);
    return -3; // LIS_ERR_INVALID_ARG_SIZE
  }

  // Step 3: Lookup the LIS engine in the engine_table.
  struct local_engine *eng = &engine_table[engine_id];
  if (eng->func == 0) { // Check if the engine function pointer is NULL (engine not initialized).
    printf("sys_lis_invoke: engine_id %d (%s) has null func pointer\n", engine_id, eng->name ? eng->name : "N/A");
    return -2; // LIS_ERR_INVALID_ID or LIS_ERR_ENGINE_NOT_INIT
  }
  engine_func_t eng_func = eng->func; // Get the function pointer for the selected engine.

  // Step 4: Data Transfer (Input) - Copy input data from user space to kernel space.
  // A kernel-side buffer is used to avoid direct kernel access to user pointers during engine execution.
  char k_input_buf[MAX_LIS_DATA_SIZE];
  if (input_len > 0) { // Only copy if input_len is greater than 0.
    if (copyin(myproc()->pagetable, k_input_buf, user_input_ptr, input_len) != 0) {
      printf("sys_lis_invoke: copyin failed for input data (engine: %s)\n", eng->name ? eng->name : "N/A");
      return -4; // LIS_ERR_COPYIN
    }
  }

  // Step 5: Execute the LIS engine.
  char k_output_buf[MAX_LIS_DATA_SIZE]; // Kernel-side buffer for engine output.
  // actual_out_len is passed by address. Its initial value is the capacity of k_output_buf
  // (and user's output_buf). The engine will update it to the actual bytes written.
  int actual_out_len = output_len; 

  // Debug print before calling the engine.
  if(eng->name) {
    printf("sys_lis_invoke: Calling engine: %s (id: %d), input_len: %d, output_buf_capacity: %d\n", eng->name, engine_id, input_len, output_len);
  } else {
    printf("sys_lis_invoke: Calling engine id: %d (name not set), input_len: %d, output_buf_capacity: %d\n", engine_id, input_len, output_len);
  }
  
  // Call the engine function.
  int engine_result = eng_func(k_input_buf, input_len, k_output_buf, &actual_out_len);

  // Check if the engine itself reported an error.
  if (engine_result != 0) {
    printf("sys_lis_invoke: engine %s (id: %d) returned error %d\n", eng->name ? eng->name : "N/A", engine_id, engine_result);
    return -5; // LIS_ERR_ENGINE_EXEC
  }

  // Validate the actual_out_len returned by the engine.
  // It must be non-negative and not exceed the capacity of the user's output buffer.
  if (actual_out_len < 0 || actual_out_len > output_len) {
    printf("sys_lis_invoke: engine %s (id: %d) returned invalid actual_out_len %d (user capacity was %d)\n",
           eng->name ? eng->name : "N/A", engine_id, actual_out_len, output_len);
    return -6; // LIS_ERR_ENGINE_BAD_OUTPUT_LEN
  }

  // Step 6: Data Transfer (Output) - Copy output data from kernel space to user space.
  if (actual_out_len > 0) { // Only copy if the engine produced any output.
    if (copyout(myproc()->pagetable, user_output_ptr, k_output_buf, actual_out_len) != 0) {
      printf("sys_lis_invoke: copyout failed for output data (engine: %s)\n", eng->name ? eng->name : "N/A");
      return -7; // LIS_ERR_COPYOUT
    }
  }
  
  // On success, return the actual number of bytes written by the engine to the user's output buffer.
  return actual_out_len; 
}
