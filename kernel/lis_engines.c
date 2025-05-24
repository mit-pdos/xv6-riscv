#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "lis.h" // Should be kernel/lis.h, but standard include paths might handle this.
                 // If not, will need to adjust based on compiler messages.

// engine_table: Array to store registered LIS engines.
// MAX_LIS_ENGINES (from lis.h) defines the maximum capacity of this table.
struct local_engine engine_table[MAX_LIS_ENGINES];

// num_lis_engines: Counter for the number of currently registered LIS engines.
int num_lis_engines = 0;

// Engine-specific error codes. These are returned by engine functions.
// sys_lis_invoke will typically return LIS_ERR_ENGINE_EXEC (-5) if an engine returns non-zero.
#define LIS_ENG_SUCCESS         0  // Indicates successful execution of the engine.
#define LIS_ENG_ERR_INPUT_SIZE  -1 // Error: Input data size is incorrect for the engine.
#define LIS_ENG_ERR_OUTPUT_SIZE -2 // Error: Output buffer capacity is too small for the engine's result.
#define LIS_ENG_ERR_DIV_ZERO    -3 // Error: Division by zero attempted (specific to arithmetic engine).
#define LIS_ENG_ERR_INVALID_OP  -4 // Error: Invalid operation code (specific to arithmetic engine).

// --- LIS Pattern Matcher Engine ---

// Input structure for the pattern matcher engine.
// User-space programs should populate this structure and pass it as input_buf.
// Note: Total size should be considered with MAX_LIS_DATA_SIZE in sys_lis_invoke.
struct pattern_match_args {
    char pattern[64]; // The pattern string to search for.
    char text[192];   // The text string to search within.
};

// Output structure for the pattern matcher engine.
// The engine populates this structure and it's copied to user-space output_buf.
struct pattern_match_res {
    int match_found; // Result: 1 if pattern is found in text, 0 otherwise.
};

// Implementation of the LIS Pattern Matcher engine.
// Searches for a null-terminated 'pattern' within a null-terminated 'text'.
// Adheres to the engine_func_t signature.
int eng_pattern_match(void *input_buf, int input_len, void *output_buf, int *output_len_ptr) {
    // Kernel-level printf for debugging engine calls. Can be removed or conditionalized.
    // printf("eng_pattern_match: input_len=%d, *output_len_ptr (capacity)=%d\n", input_len, *output_len_ptr);

    // Validate input size.
    if (input_len < sizeof(struct pattern_match_args)) {
        // printf for kernel debugging.
        printf("eng_pattern_match: Input size too small. Got %d, expected at least %d\n", input_len, sizeof(struct pattern_match_args));
        return LIS_ENG_ERR_INPUT_SIZE;
    }
    // Validate output buffer capacity.
    if (*output_len_ptr < sizeof(struct pattern_match_res)) {
        printf("eng_pattern_match: Output buffer capacity too small. Got %d, expected at least %d\n", *output_len_ptr, sizeof(struct pattern_match_res));
        return LIS_ENG_ERR_OUTPUT_SIZE;
    }

    // Cast input and output buffers to their respective struct types.
    struct pattern_match_args *args = (struct pattern_match_args *)input_buf;
    struct pattern_match_res *res = (struct pattern_match_res *)output_buf;

    // Ensure null termination for pattern and text for safety, as these come from user space.
    // This guards against missing null terminators if user data isn't perfectly formed,
    // preventing reads beyond the intended buffer lengths within this engine.
    args->pattern[sizeof(args->pattern)-1] = '\0';
    args->text[sizeof(args->text)-1] = '\0';
    
    // Basic string search algorithm (similar to strstr).
    res->match_found = 0; // Default to not found.
    char *p_pattern = args->pattern;
    char *p_text = args->text;
    int current_pattern_len = 0;

    // Calculate actual length of the pattern to avoid matching on embedded nulls if any.
    while(p_pattern[current_pattern_len] != '\0' && current_pattern_len < sizeof(args->pattern)-1) {
        current_pattern_len++;
    }

    if (current_pattern_len == 0) {
        // Policy: Empty pattern does not match anything.
        res->match_found = 0; 
        *output_len_ptr = sizeof(struct pattern_match_res); // Set actual output size.
        return LIS_ENG_SUCCESS;
    }
    
    int text_idx = 0;
    // Iterate through the text.
    while(p_text[text_idx] != '\0' && text_idx < sizeof(args->text)-1) {
        int k = 0;
        // Compare current part of text with pattern.
        while( (p_text[text_idx+k] == p_pattern[k]) &&          // Characters match
               (p_pattern[k] != '\0') &&                        // Not end of pattern
               ((text_idx+k) < sizeof(args->text)-1) &&         // Within text buffer bounds
               (k < current_pattern_len) ) {                    // Within pattern length
            k++;
        }
        if (k == current_pattern_len) { // Entire pattern matched.
            res->match_found = 1;
            break; 
        }
        // If text ends but pattern hasn't, it's not a match from this point.
        if (p_text[text_idx+k] == '\0' && k < current_pattern_len) {
            break;
        }
        text_idx++; // Move to next character in text.
    }
    
    *output_len_ptr = sizeof(struct pattern_match_res); // Set actual output size.
    // printf("eng_pattern_match: Result: %d, Output size: %d\n", res->match_found, *output_len_ptr);
    return LIS_ENG_SUCCESS;
}

// --- LIS Simple Arithmetic Engine ---

// Input structure for the simple arithmetic engine.
// User-space programs should populate this structure.
struct simple_arith_args {
    int opcode;   // Operation code (e.g., 0 for add, 1 for sub - see ARITH_OP_* in user.h).
    int operand1; // First integer operand.
    int operand2; // Second integer operand.
};

// Output structure for the simple arithmetic engine.
// The engine populates this structure.
struct simple_arith_res {
    int result; // Result of the arithmetic operation.
};

// Implementation of the LIS Simple Arithmetic engine.
// Performs basic arithmetic (add, subtract, multiply, divide) on two integers.
// Adheres to the engine_func_t signature.
int eng_simple_arith(void *input_buf, int input_len, void *output_buf, int *output_len_ptr) {
    // printf("eng_simple_arith: input_len=%d, *output_len_ptr (capacity)=%d\n", input_len, *output_len_ptr);

    // Validate input size.
        printf("eng_simple_arith: Input size too small. Got %d, expected %d\n", input_len, sizeof(struct simple_arith_args));
        return LIS_ENG_ERR_INPUT_SIZE;
    }
    // Validate output buffer capacity.
    if (*output_len_ptr < sizeof(struct simple_arith_res)) {
        printf("eng_simple_arith: Output buffer capacity too small. Got %d, expected %d\n", *output_len_ptr, sizeof(struct simple_arith_res));
        return LIS_ENG_ERR_OUTPUT_SIZE;
    }

    // Cast input and output buffers to their respective struct types.
    struct simple_arith_args *args = (struct simple_arith_args *)input_buf;
    struct simple_arith_res *res = (struct simple_arith_res *)output_buf;

    // Kernel-level printf for debugging engine operation.
    // printf("eng_simple_arith: Opcode: %d, Op1: %d, Op2: %d\n", args->opcode, args->operand1, args->operand2);

    // Perform arithmetic operation based on opcode.
    // Opcode values correspond to ARITH_OP_* definitions in user/user.h.
    switch (args->opcode) {
        case 0: // ADD (corresponds to ARITH_OP_ADD)
            res->result = args->operand1 + args->operand2;
            break;
        case 1: // SUBTRACT (corresponds to ARITH_OP_SUB)
            res->result = args->operand1 - args->operand2;
            break;
        case 2: // MULTIPLY (corresponds to ARITH_OP_MUL)
            res->result = args->operand1 * args->operand2;
            break;
        case 3: // DIVIDE (corresponds to ARITH_OP_DIV)
            if (args->operand2 == 0) {
                printf("eng_simple_arith: Division by zero attempted.\n");
                // Output is not valid, so set actual output length to 0.
                *output_len_ptr = 0; 
                return LIS_ENG_ERR_DIV_ZERO; // Return engine-specific error.
            }
            res->result = args->operand1 / args->operand2;
            break;
        default:
            printf("eng_simple_arith: Invalid opcode %d received.\n", args->opcode);
            // Output is not valid for an unknown operation.
            *output_len_ptr = 0;
            return LIS_ENG_ERR_INVALID_OP; // Return engine-specific error.
    }

    *output_len_ptr = sizeof(struct simple_arith_res); // Set actual output size.
    // printf("eng_simple_arith: Result: %d, Output size: %d\n", res->result, *output_len_ptr);
    return LIS_ENG_SUCCESS; // Success.
}

// lis_engine_init: Initializes the LIS engine table.
// This function is called during kernel boot-up (see main.c).
// It populates the `engine_table` with the available LIS engines.
void lis_engine_init(void) {
    // Initialize and register the pattern_matcher engine.
    if (num_lis_engines < MAX_LIS_ENGINES) {
        engine_table[num_lis_engines].name = "pattern_matcher"; // Name for debugging.
        engine_table[num_lis_engines].func = eng_pattern_match; // Function pointer.
        num_lis_engines++; // Increment count of registered engines.
    }

    // Initialize and register the simple_arithmetic engine.
    if (num_lis_engines < MAX_LIS_ENGINES) {
        engine_table[num_lis_engines].name = "simple_arithmetic"; // Name for debugging.
        engine_table[num_lis_engines].func = eng_simple_arith;    // Function pointer.
        num_lis_engines++; // Increment count of registered engines.
    }
    
    // Kernel printf to confirm LIS initialization and number of engines loaded.
    // This is useful for boot-time diagnostics.
    printf("LIS: %d engines initialized.\n", num_lis_engines);
}
