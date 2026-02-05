/**
 * PowerPC 64-bit (ELFv2) Calling Convention Test
 */

#include <stdio.h>
#include <stdint.h>

extern long asm_add(long a, long b);
extern long asm_sum_eight(long a, long b, long c, long d,
                          long e, long f, long g, long h);
extern long asm_sum_nine(long a, long b, long c, long d,
                         long e, long f, long g, long h, long i);
extern double asm_sum_floats(double a, double b, double c, double d);
extern long asm_call_helper(long x);
extern long asm_leaf_redzone(long a, long b, long c);

static int tests_passed = 0;
static int tests_failed = 0;

int main(void) {
    long result;
    double resultf;
    
    printf("=== PPC64 ELFv2 Calling Convention Test ===\n\n");
    
    result = asm_add(10, 20);
    printf("asm_add(10, 20) = %ld %s\n", result,
           result == 30 ? "[PASS]" : "[FAIL]");
    if (result == 30) tests_passed++; else tests_failed++;
    
    result = asm_sum_eight(1, 2, 3, 4, 5, 6, 7, 8);
    printf("asm_sum_eight = %ld %s\n", result,
           result == 36 ? "[PASS]" : "[FAIL]");
    if (result == 36) tests_passed++; else tests_failed++;
    
    result = asm_sum_nine(1, 2, 3, 4, 5, 6, 7, 8, 9);
    printf("asm_sum_nine = %ld %s\n", result,
           result == 45 ? "[PASS]" : "[FAIL]");
    if (result == 45) tests_passed++; else tests_failed++;
    
    resultf = asm_sum_floats(1.0, 2.0, 3.0, 4.0);
    printf("asm_sum_floats = %.1f %s\n", resultf,
           (resultf > 9.9 && resultf < 10.1) ? "[PASS]" : "[FAIL]");
    if (resultf > 9.9 && resultf < 10.1) tests_passed++; else tests_failed++;
    
    result = asm_call_helper(21);
    printf("asm_call_helper(21) = %ld %s\n", result,
           result == 42 ? "[PASS]" : "[FAIL]");
    if (result == 42) tests_passed++; else tests_failed++;
    
    result = asm_leaf_redzone(10, 20, 30);
    printf("asm_leaf_redzone = %ld %s\n", result,
           result == 60 ? "[PASS]" : "[FAIL]");
    if (result == 60) tests_passed++; else tests_failed++;
    
    printf("\nPassed: %d, Failed: %d\n", tests_passed, tests_failed);
    return tests_failed;
}
