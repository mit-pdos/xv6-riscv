# xv6 Local Inference Support (LIS) Framework

## Introduction

The xv6 Local Inference Support (LIS) framework provides a conceptual mechanism for user-space programs to invoke pre-defined, simple computational "engines" that reside and execute within the xv6 kernel. This framework is a highly simplified mimicry of concepts found in more complex systems like Windows AI Foundry's local models or Android's Neural Networks API, adapted to fit the educational and architectural constraints of the xv6 operating system. Its primary purpose is to demonstrate kernel-user space interaction, system call additions, and basic modular design within the kernel.

## Key Components

### Kernel-Side

*   **`kernel/lis.h`**:
    *   This header file defines the core structures for the LIS framework.
    *   `struct local_engine`: Represents a single computational engine. It contains a name (for debugging/listing) and a function pointer (`func`) to the engine's implementation.
        ```c
        struct local_engine {
            char *name;
            engine_func_t func;
        };
        ```
    *   `engine_func_t`: A function pointer type defining the signature for all LIS engine functions.
        ```c
        typedef int (*engine_func_t)(void *input_buf, int input_len, void *output_buf, int *output_len_ptr);
        ```
        Engines receive input via `input_buf` (length `input_len`) and write output to `output_buf`. The initial value of `*output_len_ptr` indicates the capacity of `output_buf`. The engine must update `*output_len_ptr` to the actual number of bytes written before returning.

*   **`kernel/lis_engines.c`**:
    *   This file is where specific computational engines are implemented and registered.
    *   Engines are defined as C functions adhering to the `engine_func_t` signature.
    *   `engine_table[]`: A static array of `struct local_engine` that holds all registered engines.
    *   `lis_engine_init()`: This function is called during kernel initialization (`main.c`). It populates the `engine_table` with the defined engines.

*   **`sys_lis_invoke()` (in `kernel/sysproc.c`)**:
    *   The primary system call that allows user programs to interact with LIS engines.
    *   **Prototype (Kernel-side view, actual user prototype in `user/user.h`):**
        The kernel implementation `sys_lis_invoke` retrieves arguments using `argint`/`argaddr`. The user-facing prototype is:
        `int lis_invoke(int engine_id, void *input, int input_len, void *output, int output_len);`
    *   **Parameters:**
        *   `engine_id`: An integer identifying the LIS engine to be invoked.
        *   `input`: A user-space pointer to the input data buffer for the engine.
        *   `input_len`: The length (in bytes) of the input data.
        *   `output`: A user-space pointer to the output data buffer where the engine will write its results.
        *   `output_len`: The capacity (in bytes) of the user-space output buffer.
    *   **Return Value:**
        *   On success: Returns the actual number of bytes written to the `output` buffer by the engine (a non-negative integer). This value is determined by the engine itself (via the `output_len_ptr` mechanism).
        *   On failure: Returns a negative error code. Examples include:
            *   `-1`: General argument fetching error.
            *   `-2`: Invalid `engine_id` (not found or out of bounds).
            *   `-3`: Invalid `input_len` or `output_len` (e.g., too large, negative).
            *   `-4`: Error during `copyin` (copying input data from user to kernel).
            *   `-5`: The engine itself returned an error (engine-specific failure).
            *   `-6`: Engine returned an invalid `actual_out_len` (e.g., negative or exceeding `output_len` capacity).
            *   `-7`: Error during `copyout` (copying output data from kernel to user).

### User-Side

*   **`user/user.h`**:
    *   Provides the user-space interface for the LIS framework.
    *   **`lis_invoke` prototype:**
        ```c
        int lis_invoke(int engine_id, void *input, int input_len, void *output, int output_len);
        ```
    *   **Engine ID Definitions:** Constants that define the `engine_id` for each available engine.
        ```c
        #define LIS_ENGINE_PATTERN_MATCH 0
        #define LIS_ENGINE_SIMPLE_ARITH  1
        ```
    *   **I/O Structures:** User-friendly `struct`s for preparing input and interpreting output for each engine. These structures are passed by pointer (as `void *`) to `lis_invoke`.
        *   For `LIS_ENGINE_PATTERN_MATCH`:
            ```c
            struct lis_pattern_match_args { char pattern[64]; char text[192]; };
            struct lis_pattern_match_res { int match_found; /* 0 or 1 */ };
            ```
        *   For `LIS_ENGINE_SIMPLE_ARITH`:
            ```c
            struct lis_simple_arith_args { int opcode; int operand1; int operand2; };
            struct lis_simple_arith_res { int result; };
            // Opcodes like ARITH_OP_ADD, ARITH_OP_SUB, etc. are also defined.
            ```

## Example Engines

The framework includes two basic example engines:

1.  **`LIS_ENGINE_PATTERN_MATCH` (ID 0):**
    *   **Purpose:** Searches for a given pattern string within a larger text string.
    *   **Input:** `struct lis_pattern_match_args` (containing `pattern` and `text`).
    *   **Output:** `struct lis_pattern_match_res` (containing `match_found`, which is 1 if the pattern is found, 0 otherwise).

2.  **`LIS_ENGINE_SIMPLE_ARITH` (ID 1):**
    *   **Purpose:** Performs basic arithmetic operations (add, subtract, multiply, divide) on two integers.
    *   **Input:** `struct lis_simple_arith_args` (containing `opcode` for the operation, `operand1`, and `operand2`).
    *   **Output:** `struct lis_simple_arith_res` (containing the integer `result` of the operation).

## Usage Example (`user/listest.c`)

The `user/listest.c` program provides a demonstration of how to use the `lis_invoke` system call with the example engines. It includes various test cases for both engines, covering successful operations and error conditions.

A typical call to `lis_invoke` from `user/listest.c` looks like this (for the pattern matcher):

```c
// In user/listest.c:
struct lis_pattern_match_args p_args;
struct lis_pattern_match_res p_res;
int ret;

strcpy(p_args.pattern, "world");
strcpy(p_args.text, "hello world example");

ret = lis_invoke(
    LIS_ENGINE_PATTERN_MATCH, 
    &p_args, 
    sizeof(p_args), 
    &p_res, 
    sizeof(p_res)
);

if (ret == sizeof(p_res)) {
    printf("Match found: %d\n", p_res.match_found);
} else {
    printf("LIS invoke error or unexpected output size: %d\n", ret);
}
```

## Error Handling

*   `sys_lis_invoke` returns a negative integer if an error occurs at the system call level (e.g., invalid `engine_id`, issues with copying data between user and kernel space, or if the engine indicates a problem).
*   The LIS engines themselves can return error codes (defined in `kernel/lis_engines.c`, like `LIS_ENG_ERR_DIV_ZERO`). If an engine returns a non-zero value (indicating an error), `sys_lis_invoke` will return `-5` (LIS_ERR_ENGINE_EXEC) to the user program.
*   The user program (`user/listest.c`) checks the return value of `lis_invoke` to determine success or failure and acts accordingly.

## How to Extend

Adding a new LIS engine involves the following steps:

1.  **Define the Engine Function (Kernel):**
    *   Write a C function in `kernel/lis_engines.c` that adheres to the `engine_func_t` signature:
        `int my_new_engine_func(void *input_buf, int input_len, void *output_buf, int *output_len_ptr);`
    *   This function will contain the logic for your new engine. It must update `*output_len_ptr` with the size of the data written to `output_buf`.

2.  **Register the Engine (Kernel):**
    *   In `kernel/lis_engines.c`, add an entry for your new engine in the `engine_table` within the `lis_engine_init()` function. Assign it a unique name.
        ```c
        // In lis_engine_init()
        if (num_lis_engines < MAX_LIS_ENGINES) {
            engine_table[num_lis_engines].name = "my_new_engine";
            engine_table[num_lis_engines].func = my_new_engine_func;
            num_lis_engines++;
        }
        ```

3.  **Define User-Space Interface (`user/user.h`):**
    *   Define a new engine ID (e.g., `LIS_ENGINE_MY_NEW_ENGINE`). Ensure it corresponds to the order in `engine_table`.
    *   Define `struct`s for the input arguments and output results of your new engine if it uses complex data types.

4.  **Update User Programs:**
    *   Modify existing user programs (like `user/listest.c`) or create new ones to use the new engine ID and I/O structures when calling `lis_invoke`.

5.  **Recompile:** Recompile the xv6 kernel and user programs.
```
