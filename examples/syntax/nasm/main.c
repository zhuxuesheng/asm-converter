/*
 * Test program for NASM (Intel syntax) assembly functions
 * Demonstrates calling assembly functions from C on Windows x64
 */

#include <stdio.h>
#include <stdlib.h>
#include "arith.h"
#include "../common/test_cases.h"

int main(void) {
    int test_failures = 0;
    size_t i;
    
    printf("=== NASM (Intel Syntax) Assembly Demo ===\n\n");
    
    /* Arithmetic operations tests */
    printf("=== Arithmetic Operations ===\n");
    for (i = 0; i < NUM_ARITH_TESTS; i++) {
        const ArithTestCase* tc = &arith_tests[i];
        int64_t result;
        char test_name[64];
        
        /* Test add */
        result = add_numbers(tc->a, tc->b);
        snprintf(test_name, sizeof(test_name), "add_numbers(%lld, %lld)", 
                 (long long)tc->a, (long long)tc->b);
        RUN_TEST(test_name, tc->expected_add, result);
        
        /* Test sub */
        result = sub_numbers(tc->a, tc->b);
        snprintf(test_name, sizeof(test_name), "sub_numbers(%lld, %lld)", 
                 (long long)tc->a, (long long)tc->b);
        RUN_TEST(test_name, tc->expected_sub, result);
        
        /* Test mul */
        result = mul_numbers(tc->a, tc->b);
        snprintf(test_name, sizeof(test_name), "mul_numbers(%lld, %lld)", 
                 (long long)tc->a, (long long)tc->b);
        RUN_TEST(test_name, tc->expected_mul, result);
    }
    printf("\n");
    
    /* Array operations tests */
    printf("=== Memory Access (Array Operations) ===\n");
    {
        int64_t result;
        int64_t arr1[] = { 1, 2, 3, 4, 5 };
        int64_t arr2[] = { 3, 1, 4, 1, 5, 9, 2, 6 };
        int64_t arr3[] = { -5, -2, -8, -1, -10 };
        
        /* Test sum_array */
        result = sum_array(arr1, test_array1_len);
        RUN_TEST("sum_array([1,2,3,4,5])", test_array1_sum, result);
        
        result = sum_array(arr2, test_array2_len);
        RUN_TEST("sum_array([3,1,4,1,5,9,2,6])", test_array2_sum, result);
        
        result = sum_array(arr3, test_array3_len);
        RUN_TEST("sum_array([-5,-2,-8,-1,-10])", test_array3_sum, result);
        
        result = sum_array(NULL, 0);
        RUN_TEST("sum_array([], 0)", 0, result);
        
        /* Test find_max */
        result = find_max(arr1, test_array1_len);
        RUN_TEST("find_max([1,2,3,4,5])", test_array1_max, result);
        
        result = find_max(arr2, test_array2_len);
        RUN_TEST("find_max([3,1,4,1,5,9,2,6])", test_array2_max, result);
        
        result = find_max(arr3, test_array3_len);
        RUN_TEST("find_max([-5,-2,-8,-1,-10])", test_array3_max, result);
    }
    printf("\n");
    
    /* Factorial tests */
    printf("=== Function Calls (Factorial) ===\n");
    for (i = 0; i < NUM_FACTORIAL_TESTS; i++) {
        const FactorialTestCase* tc = &factorial_tests[i];
        int64_t result = factorial(tc->n);
        char test_name[32];
        
        snprintf(test_name, sizeof(test_name), "factorial(%lld)", (long long)tc->n);
        RUN_TEST(test_name, tc->expected, result);
    }
    printf("\n");
    
    /* Summary */
    printf("=== Test Summary ===\n");
    if (test_failures == 0) {
        printf("All tests PASSED!\n");
    } else {
        printf("%d test(s) FAILED!\n", test_failures);
    }
    
    return test_failures > 0 ? 1 : 0;
}
