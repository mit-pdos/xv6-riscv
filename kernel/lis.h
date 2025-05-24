#ifndef __LIS_H__
#define __LIS_H__

// Define the function pointer type for LIS engine functions.
// Parameters:
//   input_buf: Pointer to the input data buffer.
//   input_len: Length of the input data buffer in bytes.
//   output_buf: Pointer to the output data buffer where the engine writes its results.
//   output_len_ptr: Pointer to an integer. On entry, the value at this pointer
//                   is the capacity of output_buf. The engine must update this
//                   value to the actual number of bytes written to output_buf.
// Returns:
//   0 on success, or a negative error code specific to the engine on failure.
typedef int (*engine_func_t)(void *input_buf, int input_len, void *output_buf, int *output_len_ptr);

// Defines the structure for a LIS (Local Inference Support) engine.
// Each engine is a kernel-resident computational unit callable from user space.
struct local_engine {
    char *name;             // Name of the engine, primarily for debugging or listing purposes.
    engine_func_t func;     // Function pointer to the actual implementation of the engine.
    // Future extensions could include:
    // int required_input_len; // For pre-validation of input buffer size.
    // int max_output_len;     // For pre-validation of output buffer capacity.
};

// Maximum number of LIS engines that can be registered in the engine_table.
#define MAX_LIS_ENGINES 10

#endif // __LIS_H__
