#include "kernel/types.h" // For standard types like uint, etc.
#include "user/user.h"    // For LIS definitions, printf, exit, etc.

// test_pattern_matcher:
//   Tests the LIS_ENGINE_PATTERN_MATCH engine.
//   It covers various scenarios:
//   - Simple match found.
//   - No match found.
//   - Pattern at the beginning of the text.
//   - Pattern at the end of the text.
//   - Empty text.
//   - Empty pattern.
//   For each test, it calls lis_invoke, checks the return value, and compares
//   the engine's output (match_found) with the expected result.
void test_pattern_matcher() {
    struct lis_pattern_match_args p_args; // Arguments for the pattern matcher engine.
    struct lis_pattern_match_res p_res;
    int ret;

    printf("--- Testing Pattern Matcher Engine ---\n");

    // Test 1: Match found
    printf("Test 1: Simple match ('world' in 'hello world example')\n");
    memset(&p_args, 0, sizeof(p_args)); // Zero out args
    memset(&p_res, 0, sizeof(p_res));   // Zero out results
    strcpy(p_args.pattern, "world");
    strcpy(p_args.text, "hello world example");
    ret = lis_invoke(LIS_ENGINE_PATTERN_MATCH, &p_args, sizeof(p_args), &p_res, sizeof(p_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(p_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(p_res));
    } else {
        printf("  Result: match_found = %d (Expected: 1)\n", p_res.match_found);
    }

    // Test 2: No match
    printf("Test 2: No match ('test' in 'hello world example')\n");
    memset(&p_args, 0, sizeof(p_args));
    memset(&p_res, 0, sizeof(p_res));
    strcpy(p_args.pattern, "test");
    strcpy(p_args.text, "hello world example");
    ret = lis_invoke(LIS_ENGINE_PATTERN_MATCH, &p_args, sizeof(p_args), &p_res, sizeof(p_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(p_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(p_res));
    } else {
        printf("  Result: match_found = %d (Expected: 0)\n", p_res.match_found);
    }
    
    // Test 3: Pattern at the beginning
    printf("Test 3: Pattern at beginning ('hello' in 'hello world')\n");
    memset(&p_args, 0, sizeof(p_args));
    memset(&p_res, 0, sizeof(p_res));
    strcpy(p_args.pattern, "hello");
    strcpy(p_args.text, "hello world");
    ret = lis_invoke(LIS_ENGINE_PATTERN_MATCH, &p_args, sizeof(p_args), &p_res, sizeof(p_res));
     if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(p_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(p_res));
    } else {
        printf("  Result: match_found = %d (Expected: 1)\n", p_res.match_found);
    }

    // Test 4: Pattern at the end
    printf("Test 4: Pattern at end ('world' in 'hello world')\n");
    memset(&p_args, 0, sizeof(p_args));
    memset(&p_res, 0, sizeof(p_res));
    strcpy(p_args.pattern, "world");
    strcpy(p_args.text, "hello world");
    ret = lis_invoke(LIS_ENGINE_PATTERN_MATCH, &p_args, sizeof(p_args), &p_res, sizeof(p_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(p_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(p_res));
    } else {
        printf("  Result: match_found = %d (Expected: 1)\n", p_res.match_found);
    }
    
    // Test 5: Empty text
    printf("Test 5: Empty text ('world' in '')\n");
    memset(&p_args, 0, sizeof(p_args));
    memset(&p_res, 0, sizeof(p_res));
    strcpy(p_args.pattern, "world");
    strcpy(p_args.text, "");
    ret = lis_invoke(LIS_ENGINE_PATTERN_MATCH, &p_args, sizeof(p_args), &p_res, sizeof(p_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(p_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(p_res));
    } else {
        printf("  Result: match_found = %d (Expected: 0)\n", p_res.match_found);
    }

    // Test 6: Empty pattern (engine defined to not match empty pattern)
    printf("Test 6: Empty pattern ('' in 'hello world')\n");
    memset(&p_args, 0, sizeof(p_args));
    memset(&p_res, 0, sizeof(p_res));
    strcpy(p_args.pattern, "");
    strcpy(p_args.text, "hello world");
    ret = lis_invoke(LIS_ENGINE_PATTERN_MATCH, &p_args, sizeof(p_args), &p_res, sizeof(p_res));
     if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(p_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(p_res));
    } else {
        printf("  Result: match_found = %d (Expected: 0)\n", p_res.match_found);
    }
    printf("--- Pattern Matcher Engine Test Complete ---\n\n");
}

// test_simple_arithmetic:
//   Tests the LIS_ENGINE_SIMPLE_ARITH engine.
//   It covers various arithmetic operations and error conditions:
//   - Addition, Subtraction, Multiplication, Division.
//   - Division by zero (expects an engine error).
//   - Invalid operation code (expects an engine error).
//   For each test, it calls lis_invoke, checks the return value, and compares
//   the engine's output (result) with the expected result or error code.
void test_simple_arithmetic() {
    struct lis_simple_arith_args a_args; // Arguments for the simple arithmetic engine.
    struct lis_simple_arith_res a_res;   // Result from the simple arithmetic engine.
    int ret;

    printf("--- Testing Simple Arithmetic Engine ---\n");

    // Test 1: Addition
    printf("Test 1: Addition (10 + 5)\n");
    memset(&a_args, 0, sizeof(a_args));
    memset(&a_res, 0, sizeof(a_res));
    a_args.opcode = ARITH_OP_ADD;
    a_args.operand1 = 10;
    a_args.operand2 = 5;
    ret = lis_invoke(LIS_ENGINE_SIMPLE_ARITH, &a_args, sizeof(a_args), &a_res, sizeof(a_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(a_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(a_res));
    } else {
        printf("  Result: %d (Expected: 15)\n", a_res.result);
    }

    // Test 2: Subtraction
    printf("Test 2: Subtraction (10 - 5)\n");
    memset(&a_args, 0, sizeof(a_args));
    memset(&a_res, 0, sizeof(a_res));
    a_args.opcode = ARITH_OP_SUB;
    a_args.operand1 = 10;
    a_args.operand2 = 5;
    ret = lis_invoke(LIS_ENGINE_SIMPLE_ARITH, &a_args, sizeof(a_args), &a_res, sizeof(a_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(a_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(a_res));
    } else {
        printf("  Result: %d (Expected: 5)\n", a_res.result);
    }

    // Test 3: Multiplication
    printf("Test 3: Multiplication (10 * 5)\n");
    memset(&a_args, 0, sizeof(a_args));
    memset(&a_res, 0, sizeof(a_res));
    a_args.opcode = ARITH_OP_MUL;
    a_args.operand1 = 10;
    a_args.operand2 = 5;
    ret = lis_invoke(LIS_ENGINE_SIMPLE_ARITH, &a_args, sizeof(a_args), &a_res, sizeof(a_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(a_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(a_res));
    } else {
        printf("  Result: %d (Expected: 50)\n", a_res.result);
    }

    // Test 4: Division
    printf("Test 4: Division (10 / 2)\n");
    memset(&a_args, 0, sizeof(a_args));
    memset(&a_res, 0, sizeof(a_res));
    a_args.opcode = ARITH_OP_DIV;
    a_args.operand1 = 10;
    a_args.operand2 = 2;
    ret = lis_invoke(LIS_ENGINE_SIMPLE_ARITH, &a_args, sizeof(a_args), &a_res, sizeof(a_res));
    if (ret < 0) {
        printf("  ERROR: lis_invoke returned %d\n", ret);
    } else if (ret != sizeof(a_res)) {
        printf("  ERROR: lis_invoke returned unexpected size %d, expected %d\n", ret, sizeof(a_res));
    } else {
        printf("  Result: %d (Expected: 5)\n", a_res.result);
    }

    // Test 5: Division by zero
    printf("Test 5: Division by zero (10 / 0)\n");
    memset(&a_args, 0, sizeof(a_args));
    memset(&a_res, 0, sizeof(a_res));
    a_args.opcode = ARITH_OP_DIV;
    a_args.operand1 = 10;
    a_args.operand2 = 0;
    ret = lis_invoke(LIS_ENGINE_SIMPLE_ARITH, &a_args, sizeof(a_args), &a_res, sizeof(a_res));
    // Expected engine error LIS_ENG_ERR_DIV_ZERO (-3)
    // sys_lis_invoke returns this as -5 (LIS_ERR_ENGINE_EXEC) if engine returns non-zero.
    // Or, if engine returns 0 but sets output_len_ptr to 0, sys_lis_invoke returns 0.
    // The current engine returns LIS_ENG_ERR_DIV_ZERO (-3).
    // The current sys_lis_invoke returns -5 if engine_result is non-zero.
    if (ret == -5) { // LIS_ERR_ENGINE_EXEC from sys_lis_invoke
        printf("  Result: lis_invoke returned %d as expected due to engine error (division by zero).\n", ret);
    } else {
        printf("  ERROR: lis_invoke returned %d, expected -5 (engine error for div by zero)\n", ret);
        if (ret >= 0) printf("  a_res.result (if any): %d\n", a_res.result);
    }
    
    // Test 6: Invalid opcode
    printf("Test 6: Invalid opcode (opcode 99)\n");
    memset(&a_args, 0, sizeof(a_args));
    memset(&a_res, 0, sizeof(a_res));
    a_args.opcode = 99; // Invalid opcode
    a_args.operand1 = 10;
    a_args.operand2 = 5;
    ret = lis_invoke(LIS_ENGINE_SIMPLE_ARITH, &a_args, sizeof(a_args), &a_res, sizeof(a_res));
    // Expected engine error LIS_ENG_ERR_INVALID_OP (-4)
    // sys_lis_invoke returns this as -5 (LIS_ERR_ENGINE_EXEC).
    if (ret == -5) { // LIS_ERR_ENGINE_EXEC from sys_lis_invoke
        printf("  Result: lis_invoke returned %d as expected due to engine error (invalid opcode).\n", ret);
    } else {
        printf("  ERROR: lis_invoke returned %d, expected -5 (engine error for invalid opcode)\n", ret);
         if (ret >= 0) printf("  a_res.result (if any): %d\n", a_res.result);
    }
    printf("--- Simple Arithmetic Engine Test Complete ---\n\n");
}

// main:
//   Entry point for the LIS test program.
//   It executes test suites for each implemented LIS engine
//   and then exits.
int main(int argc, char *argv[]) {
    printf("Starting LIS (Local Inference Support) tests...\n\n");

    // Run tests for the pattern matcher engine.
    test_pattern_matcher();
    
    // Run tests for the simple arithmetic engine.
    test_simple_arithmetic();

    printf("LIS tests finished.\n");
    exit(0); // Exit successfully.
}
