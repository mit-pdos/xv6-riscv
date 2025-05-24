struct stat;

// system calls
int fork(void);
int exit(int) __attribute__((noreturn));
int wait(int*);
int pipe(int*);
int write(int, const void*, int);
int read(int, void*, int);
int close(int);
int kill(int);
int exec(const char*, char**);
int open(const char*, int);
int mknod(const char*, short, short);
int unlink(const char*);
int fstat(int fd, struct stat*);
int link(const char*, const char*);
int mkdir(const char*);
int chdir(const char*);
int dup(int);
int getpid(void);
char* sbrk(int);
int sleep(int);
int uptime(void);

// System call for LIS (Local Inference Support) framework.
// Invokes a pre-defined computational engine within the kernel.
// Parameters:
//   engine_id: Identifier for the LIS engine to be invoked (see LIS_ENGINE_* defines).
//   input: Pointer to the input data buffer for the engine.
//   input_len: Length of the input data buffer in bytes.
//   output: Pointer to the output data buffer where the engine will write its results.
//   output_len: Capacity of the output data buffer in bytes.
// Returns:
//   On success: The actual number of bytes written to the 'output' buffer (non-negative).
//   On failure: A negative error code (e.g., -1 for general error, -2 for invalid ID, etc.).
int lis_invoke(int engine_id, void *input, int input_len, void *output, int output_len);

// ulib.c
int stat(const char*, struct stat*);
char* strcpy(char*, const char*);
void *memmove(void*, const void*, int);
char* strchr(const char*, char c);
int strcmp(const char*, const char*);
void fprintf(int, const char*, ...) __attribute__ ((format (printf, 2, 3)));
void printf(const char*, ...) __attribute__ ((format (printf, 1, 2)));
char* gets(char*, int max);
uint strlen(const char*);
void* memset(void*, int, uint);
int atoi(const char*);
int memcmp(const void *, const void *, uint);
void *memcpy(void *, const void *, uint);

// umalloc.c
void* malloc(uint);
void free(void*);

// --- LIS (Local Inference Support) Framework User-Space Definitions ---

// LIS Engine Identifiers
// These IDs are used in the 'engine_id' parameter of the lis_invoke system call.
#define LIS_ENGINE_PATTERN_MATCH 0  // ID for the Pattern Matcher engine.
#define LIS_ENGINE_SIMPLE_ARITH  1  // ID for the Simple Arithmetic engine.

// Input/Output Structures for LIS_ENGINE_PATTERN_MATCH
// These structures define the data format for interacting with the pattern matcher engine.

// Arguments for the pattern matcher engine.
struct lis_pattern_match_args {
    char pattern[64]; // The pattern string to search for (null-terminated).
    char text[192];   // The text string to search within (null-terminated).
                      // Max total size should align with kernel's MAX_LIS_DATA_SIZE.
};
// Result from the pattern matcher engine.
struct lis_pattern_match_res {
    int match_found; // Output: 1 if the pattern is found in the text, 0 otherwise.
};


// Input/Output Structures for LIS_ENGINE_SIMPLE_ARITH
// These structures define the data format for interacting with the simple arithmetic engine.

// Arguments for the simple arithmetic engine.
struct lis_simple_arith_args {
    int opcode;   // Operation code (see ARITH_OP_* defines below).
    int operand1; // First integer operand.
    int operand2; // Second integer operand.
};
// Result from the simple arithmetic engine.
struct lis_simple_arith_res {
    int result; // Output: The integer result of the arithmetic operation.
};

// Operation Codes for the Simple Arithmetic Engine (LIS_ENGINE_SIMPLE_ARITH)
// Used in the 'opcode' field of struct lis_simple_arith_args.
#define ARITH_OP_ADD 0 // Opcode for addition.
#define ARITH_OP_SUB 1 // Opcode for subtraction.
#define ARITH_OP_MUL 2 // Opcode for multiplication.
#define ARITH_OP_DIV 3 // Opcode for division.
// --- End of LIS Framework Definitions ---
