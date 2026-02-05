/**
 * =============================================================================
 * System V AMD64 ABI Calling Convention Verification - Test Program
 * =============================================================================
 *
 * This program tests the assembly implementations of System V AMD64 ABI
 * calling convention to verify:
 * - Integer parameter passing (RDI, RSI, RDX, RCX, R8, R9)
 * - Stack parameter passing (7th and beyond)
 * - Red Zone usage in leaf functions
 * - Floating-point parameter passing (XMM0-XMM7, independent counting)
 * - Mixed integer/float parameters (independent counting!)
 * - Assembly calling C functions (no Shadow Space)
 * - Return values (RAX for integers, XMM0 for floats)
 * - Callee-saved register preservation
 *
 * Compile with: gcc -c -o main.o main.c
 * Link with:    gcc -o test_calling_conv main.o calling_conv.o
 * =============================================================================
 */

#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <inttypes.h>

/* =============================================================================
 * Assembly function declarations
 * =============================================================================
 */

/**
 * Sum six integers passed via registers
 * Parameters: RDI=a, RSI=b, RDX=c, RCX=d, R8=e, R9=f
 * Returns: a + b + c + d + e + f
 */
extern int64_t sum_six(int64_t a, int64_t b, int64_t c,
                       int64_t d, int64_t e, int64_t f);

/**
 * Sum eight integers - first 6 via registers, last 2 via stack
 * Parameters: RDI=a, RSI=b, RDX=c, RCX=d, R8=e, R9=f, [stack]=g, [stack]=h
 * Returns: a + b + c + d + e + f + g + h
 */
extern int64_t sum_eight(int64_t a, int64_t b, int64_t c, int64_t d,
                         int64_t e, int64_t f, int64_t g, int64_t h);

/**
 * Demonstrate Red Zone usage
 * Uses RSP-128 to RSP without adjusting stack pointer
 * Parameters: RDI=a, RSI=b, RDX=c
 * Returns: a + b + c
 */
extern int64_t use_red_zone(int64_t a, int64_t b, int64_t c);

/**
 * Sum four doubles passed via XMM registers
 * Parameters: XMM0=a, XMM1=b, XMM2=c, XMM3=d
 * Returns: a + b + c + d
 */
extern double sum_doubles(double a, double b, double c, double d);

/**
 * Mixed integer and float parameters (INDEPENDENT counting!)
 * Parameters: RDI=n, XMM0=x, RSI=m, XMM1=y
 * Note: Unlike Microsoft x64, integers and floats are counted separately!
 * Returns: n * x + m * y
 */
extern double mixed_params(int64_t n, double x, int64_t m, double y);

/**
 * Assembly function that calls C function
 * Demonstrates calling without Shadow Space
 * Parameters: RDI=x, RSI=y
 * Returns: c_add(x, y)
 */
extern int64_t asm_calls_c(int64_t x, int64_t y);

/**
 * Return a magic number via RAX
 * Returns: 0x123456789ABCDEF0
 */
extern int64_t get_magic_number(void);

/**
 * Return pi via XMM0
 * Returns: 3.14159265358979...
 */
extern double get_pi(void);

/**
 * Verify callee-saved register preservation (RBX, R12-R15)
 * Parameters: RDI=a, RSI=b, RDX=c, RCX=d
 * Returns: a + b + c + d
 */
extern int64_t verify_callee_saved(int64_t a, int64_t b,
                                   int64_t c, int64_t d);

/**
 * Complex Red Zone usage with intermediate calculations
 * Parameters: RDI=a, RSI=b, RDX=c, RCX=d, R8=e, R9=f
 * Returns: (a*b) + (c*d) + (e*f)
 */
extern int64_t red_zone_complex(int64_t a, int64_t b, int64_t c,
                                int64_t d, int64_t e, int64_t f);

/**
 * Sum eight doubles - demonstrates all 8 XMM parameter registers
 * Parameters: XMM0=a, XMM1=b, XMM2=c, XMM3=d, XMM4=e, XMM5=f, XMM6=g, XMM7=h
 * Returns: a + b + c + d + e + f + g + h
 */
extern double many_float_params(double a, double b, double c, double d,
                                double e, double f, double g, double h);

/* =============================================================================
 * C function called by assembly
 * =============================================================================
 */

/**
 * Simple addition function called from assembly
 * This verifies that assembly can correctly call C functions
 */
int64_t c_add(int64_t a, int64_t b) {
    return a + b;
}

/* =============================================================================
 * Test utilities
 * =============================================================================
 */

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST_INT(name, actual, expected) do { \
    int64_t _actual = (actual); \
    int64_t _expected = (expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got %" PRId64 ", expected %" PRId64 ")\n", \
               _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

#define TEST_DOUBLE(name, actual, expected, epsilon) do { \
    double _actual = (actual); \
    double _expected = (expected); \
    if (fabs(_actual - _expected) < (epsilon)) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got %f, expected %f)\n", _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

#define TEST_HEX(name, actual, expected) do { \
    uint64_t _actual = (uint64_t)(actual); \
    uint64_t _expected = (uint64_t)(expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got 0x%" PRIX64 ", expected 0x%" PRIX64 ")\n", \
               _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

/* =============================================================================
 * Main test program
 * =============================================================================
 */

int main(void) {
    printf("=== System V AMD64 ABI Calling Convention Verification ===\n\n");

    /* -------------------------------------------------------------------------
     * Test 1: Integer Parameters (RDI, RSI, RDX, RCX, R8, R9)
     * ------------------------------------------------------------------------- */
    printf("[Test 1] Integer Parameters (RDI, RSI, RDX, RCX, R8, R9)\n");
    {
        int64_t result = sum_six(1, 2, 3, 4, 5, 6);
        printf("  sum_six(1, 2, 3, 4, 5, 6) = %" PRId64 "\n", result);
        printf("  Expected: 21");
        TEST_INT("sum_six", result, 21);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 2: Stack Parameters (7th and beyond)
     * ------------------------------------------------------------------------- */
    printf("[Test 2] Stack Parameters (7th and beyond)\n");
    {
        int64_t result = sum_eight(1, 2, 3, 4, 5, 6, 7, 8);
        printf("  sum_eight(1, 2, 3, 4, 5, 6, 7, 8) = %" PRId64 "\n", result);
        printf("  Expected: 36");
        TEST_INT("sum_eight", result, 36);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 3: Red Zone Usage (Leaf Function)
     * ------------------------------------------------------------------------- */
    printf("[Test 3] Red Zone Usage (Leaf Function)\n");
    {
        int64_t result = use_red_zone(100, 200, 300);
        printf("  use_red_zone(100, 200, 300) = %" PRId64 "\n", result);
        printf("  Expected: 600");
        TEST_INT("use_red_zone", result, 600);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 4: Floating Point Parameters (XMM0-XMM7)
     * ------------------------------------------------------------------------- */
    printf("[Test 4] Floating Point Parameters (XMM0-XMM7)\n");
    {
        double result = sum_doubles(1.5, 2.5, 3.5, 4.5);
        printf("  sum_doubles(1.5, 2.5, 3.5, 4.5) = %f\n", result);
        printf("  Expected: 12.0");
        TEST_DOUBLE("sum_doubles", result, 12.0, 0.0001);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 5: Mixed Integer/Float Parameters (Independent Counting!)
     * ------------------------------------------------------------------------- */
    printf("[Test 5] Mixed Integer/Float Parameters (Independent Counting)\n");
    {
        // mixed_params(n, x, m, y) = n * x + m * y
        // In System V: RDI=n, XMM0=x, RSI=m, XMM1=y
        // mixed_params(2, 3.0, 4, 5.0) = 2 * 3.0 + 4 * 5.0 = 6.0 + 20.0 = 26.0
        double result = mixed_params(2, 3.0, 4, 5.0);
        printf("  mixed_params(2, 3.0, 4, 5.0) = %f\n", result);
        printf("  Expected: 26.0 (2*3.0 + 4*5.0)");
        TEST_DOUBLE("mixed_params", result, 26.0, 0.0001);
        printf("  Note: Integer params use RDI,RSI; Float params use XMM0,XMM1\n");
        printf("        (Independent counting, unlike Microsoft x64!)\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 6: Assembly Calling C Function (No Shadow Space!)
     * ------------------------------------------------------------------------- */
    printf("[Test 6] Assembly Calling C Function (No Shadow Space)\n");
    {
        int64_t result = asm_calls_c(100, 200);
        printf("  asm_calls_c(100, 200) = %" PRId64 "\n", result);
        printf("  Expected: 300");
        TEST_INT("asm_calls_c", result, 300);
        printf("  Note: No Shadow Space allocation needed in System V ABI\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 7: Return Values (RAX and XMM0)
     * ------------------------------------------------------------------------- */
    printf("[Test 7] Return Values\n");
    {
        int64_t magic = get_magic_number();
        printf("  get_magic_number() = 0x%" PRIX64 "\n", (uint64_t)magic);
        printf("  Expected: 0x123456789ABCDEF0");
        TEST_HEX("get_magic_number", magic, 0x123456789ABCDEF0ULL);

        double pi = get_pi();
        printf("  get_pi() = %.15f\n", pi);
        printf("  Expected: 3.14159265358979...");
        TEST_DOUBLE("get_pi", pi, 3.14159265358979, 0.00000000001);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 8: Callee-saved Register Preservation
     * ------------------------------------------------------------------------- */
    printf("[Test 8] Callee-saved Register Preservation\n");
    {
        int64_t result = verify_callee_saved(1000, 2000, 3000, 4000);
        printf("  verify_callee_saved(1000, 2000, 3000, 4000) = %" PRId64 "\n", result);
        printf("  Expected: 10000");
        TEST_INT("verify_callee_saved", result, 10000);
        printf("  Note: RBX, R12-R15 must be preserved across function calls\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 9: Complex Red Zone Usage
     * ------------------------------------------------------------------------- */
    printf("[Test 9] Complex Red Zone Usage\n");
    {
        // red_zone_complex(a, b, c, d, e, f) = (a*b) + (c*d) + (e*f)
        // = (2*3) + (4*5) + (6*7) = 6 + 20 + 42 = 68
        int64_t result = red_zone_complex(2, 3, 4, 5, 6, 7);
        printf("  red_zone_complex(2, 3, 4, 5, 6, 7) = %" PRId64 "\n", result);
        printf("  Expected: 68 ((2*3) + (4*5) + (6*7))");
        TEST_INT("red_zone_complex", result, 68);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 10: Many Float Parameters (8 XMM registers)
     * ------------------------------------------------------------------------- */
    printf("[Test 10] Many Float Parameters (8 XMM registers)\n");
    {
        // Sum of 1.0 + 2.0 + 3.0 + 4.0 + 5.0 + 6.0 + 7.0 + 8.0 = 36.0
        double result = many_float_params(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0);
        printf("  many_float_params(1.0, 2.0, ..., 8.0) = %f\n", result);
        printf("  Expected: 36.0");
        TEST_DOUBLE("many_float_params", result, 36.0, 0.0001);
        printf("  Note: System V supports 8 float params in XMM0-XMM7\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Test 11: Edge Cases
     * ------------------------------------------------------------------------- */
    printf("[Test 11] Edge Cases\n");
    {
        // Test with zero
        int64_t result1 = sum_six(0, 0, 0, 0, 0, 0);
        printf("  sum_six(0, 0, 0, 0, 0, 0) = %" PRId64 "\n", result1);
        printf("  Expected: 0");
        TEST_INT("sum_six_zeros", result1, 0);

        // Test with negative numbers
        int64_t result2 = sum_six(-10, 20, -30, 40, -50, 60);
        printf("  sum_six(-10, 20, -30, 40, -50, 60) = %" PRId64 "\n", result2);
        printf("  Expected: 30");
        TEST_INT("sum_six_negative", result2, 30);

        // Test with large numbers
        int64_t result3 = sum_six(0x1000000000LL, 0x2000000000LL,
                                  0x3000000000LL, 0x4000000000LL,
                                  0x5000000000LL, 0x6000000000LL);
        printf("  sum_six(large values) = 0x%" PRIX64 "\n", (uint64_t)result3);
        printf("  Expected: 0x15000000000");
        TEST_HEX("sum_six_large", result3, 0x15000000000LL);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * Summary
     * ------------------------------------------------------------------------- */
    printf("=== Test Summary ===\n");
    printf("Passed: %d\n", tests_passed);
    printf("Failed: %d\n", tests_failed);
    printf("\n");

    if (tests_failed == 0) {
        printf("=== All Tests Passed! ===\n");
        return 0;
    } else {
        printf("=== Some Tests Failed! ===\n");
        return 1;
    }
}
