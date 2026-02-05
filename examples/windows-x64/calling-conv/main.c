/**
 * =============================================================================
 * Microsoft x64 Calling Convention Verification - Test Program
 * =============================================================================
 * 
 * This program tests the assembly implementations of Microsoft x64 calling
 * convention to verify:
 * - Integer parameter passing (RCX, RDX, R8, R9)
 * - Stack parameter passing (5th and beyond)
 * - Shadow Space usage
 * - Floating-point parameter passing (XMM0-XMM3)
 * - Mixed integer/float parameters (position sharing)
 * - Assembly calling C functions
 * - Return values (RAX for integers, XMM0 for floats)
 *
 * Compile with: gcc -c -o main.obj main.c
 * Link with:    gcc -o test_calling_conv.exe main.obj calling_conv.obj
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
 * Sum four integers passed via registers
 * Parameters: RCX=a, RDX=b, R8=c, R9=d
 * Returns: a + b + c + d
 */
extern int64_t sum_four(int64_t a, int64_t b, int64_t c, int64_t d);

/**
 * Sum six integers - first 4 via registers, last 2 via stack
 * Parameters: RCX=a, RDX=b, R8=c, R9=d, [stack]=e, [stack]=f
 * Returns: a + b + c + d + e + f
 */
extern int64_t sum_six(int64_t a, int64_t b, int64_t c, int64_t d, 
                       int64_t e, int64_t f);

/**
 * Demonstrate Shadow Space usage
 * Saves parameters to shadow space before computing
 * Parameters: RCX=a, RDX=b, R8=c, R9=d
 * Returns: a + b + c + d
 */
extern int64_t use_shadow_space(int64_t a, int64_t b, int64_t c, int64_t d);

/**
 * Sum four doubles passed via XMM registers
 * Parameters: XMM0=a, XMM1=b, XMM2=c, XMM3=d
 * Returns: a + b + c + d
 */
extern double sum_doubles(double a, double b, double c, double d);

/**
 * Mixed integer and float parameters (position sharing)
 * Parameters: RCX=n, XMM1=x, R8=m, XMM3=y
 * Returns: n * x + m * y
 */
extern double mixed_params(int64_t n, double x, int64_t m, double y);

/**
 * Assembly function that calls C function
 * Demonstrates proper shadow space allocation and stack alignment
 * Parameters: RCX=x, RDX=y
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
 * Verify all parameter registers with callee-saved register usage
 * Parameters: RCX=a, RDX=b, R8=c, R9=d
 * Returns: a + b + c + d
 */
extern int64_t verify_registers(int64_t a, int64_t b, int64_t c, int64_t d);

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
    printf("=== Microsoft x64 Calling Convention Verification ===\n\n");
    
    /* -------------------------------------------------------------------------
     * Test 1: Integer Parameters (RCX, RDX, R8, R9)
     * ------------------------------------------------------------------------- */
    printf("[Test 1] Integer Parameters (RCX, RDX, R8, R9)\n");
    {
        int64_t result = sum_four(10, 20, 30, 40);
        printf("  sum_four(10, 20, 30, 40) = %" PRId64 "\n", result);
        printf("  Expected: 100");
        TEST_INT("sum_four", result, 100);
    }
    printf("\n");
    
    /* -------------------------------------------------------------------------
     * Test 2: Stack Parameters (5th and beyond)
     * ------------------------------------------------------------------------- */
    printf("[Test 2] Stack Parameters (5th and beyond)\n");
    {
        int64_t result = sum_six(1, 2, 3, 4, 5, 6);
        printf("  sum_six(1, 2, 3, 4, 5, 6) = %" PRId64 "\n", result);
        printf("  Expected: 21");
        TEST_INT("sum_six", result, 21);
    }
    printf("\n");
    
    /* -------------------------------------------------------------------------
     * Test 3: Shadow Space Usage
     * ------------------------------------------------------------------------- */
    printf("[Test 3] Shadow Space Usage\n");
    {
        int64_t result = use_shadow_space(100, 200, 300, 400);
        printf("  use_shadow_space(100, 200, 300, 400) = %" PRId64 "\n", result);
        printf("  Expected: 1000");
        TEST_INT("use_shadow_space", result, 1000);
    }
    printf("\n");
    
    /* -------------------------------------------------------------------------
     * Test 4: Floating Point Parameters (XMM0-XMM3)
     * ------------------------------------------------------------------------- */
    printf("[Test 4] Floating Point Parameters (XMM0-XMM3)\n");
    {
        double result = sum_doubles(1.5, 2.5, 3.5, 4.5);
        printf("  sum_doubles(1.5, 2.5, 3.5, 4.5) = %f\n", result);
        printf("  Expected: 12.0");
        TEST_DOUBLE("sum_doubles", result, 12.0, 0.0001);
    }
    printf("\n");
    
    /* -------------------------------------------------------------------------
     * Test 5: Mixed Integer/Float Parameters (Position Sharing)
     * ------------------------------------------------------------------------- */
    printf("[Test 5] Mixed Integer/Float Parameters\n");
    {
        // mixed_params(n, x, m, y) = n * x + m * y
        // mixed_params(2, 3.0, 4, 5.0) = 2 * 3.0 + 4 * 5.0 = 6.0 + 20.0 = 26.0
        double result = mixed_params(2, 3.0, 4, 5.0);
        printf("  mixed_params(2, 3.0, 4, 5.0) = %f\n", result);
        printf("  Expected: 26.0 (2*3.0 + 4*5.0)");
        TEST_DOUBLE("mixed_params", result, 26.0, 0.0001);
    }
    printf("\n");
    
    /* -------------------------------------------------------------------------
     * Test 6: Assembly Calling C Function
     * ------------------------------------------------------------------------- */
    printf("[Test 6] Assembly Calling C Function\n");
    {
        int64_t result = asm_calls_c(100, 200);
        printf("  asm_calls_c(100, 200) = %" PRId64 "\n", result);
        printf("  Expected: 300");
        TEST_INT("asm_calls_c", result, 300);
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
        int64_t result = verify_registers(1000, 2000, 3000, 4000);
        printf("  verify_registers(1000, 2000, 3000, 4000) = %" PRId64 "\n", result);
        printf("  Expected: 10000");
        TEST_INT("verify_registers", result, 10000);
    }
    printf("\n");
    
    /* -------------------------------------------------------------------------
     * Test 9: Edge Cases
     * ------------------------------------------------------------------------- */
    printf("[Test 9] Edge Cases\n");
    {
        // Test with zero
        int64_t result1 = sum_four(0, 0, 0, 0);
        printf("  sum_four(0, 0, 0, 0) = %" PRId64 "\n", result1);
        printf("  Expected: 0");
        TEST_INT("sum_four_zeros", result1, 0);
        
        // Test with negative numbers
        int64_t result2 = sum_four(-10, 20, -30, 40);
        printf("  sum_four(-10, 20, -30, 40) = %" PRId64 "\n", result2);
        printf("  Expected: 20");
        TEST_INT("sum_four_negative", result2, 20);
        
        // Test with large numbers
        int64_t result3 = sum_four(0x1000000000LL, 0x2000000000LL, 
                                   0x3000000000LL, 0x4000000000LL);
        printf("  sum_four(large values) = 0x%" PRIX64 "\n", (uint64_t)result3);
        printf("  Expected: 0xA000000000");
        TEST_HEX("sum_four_large", result3, 0xA000000000LL);
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
