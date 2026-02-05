/*
 * 共享测试用例定义
 * 用于验证三种汇编语法实现的一致性
 */

#ifndef TEST_CASES_H
#define TEST_CASES_H

#include <stdint.h>
#include <stdio.h>

/* 算术运算测试用例 */
typedef struct {
    int64_t a;
    int64_t b;
    int64_t expected_add;
    int64_t expected_sub;
    int64_t expected_mul;
} ArithTestCase;

static const ArithTestCase arith_tests[] = {
    { 10, 20, 30, -10, 200 },
    { 50, 30, 80, 20, 1500 },
    { 6, 7, 13, -1, 42 },
    { 0, 100, 100, -100, 0 },
    { -5, 3, -2, -8, -15 },
    { 100, -50, 50, 150, -5000 },
    { 0x7FFFFFFF, 1, 0x80000000LL, 0x7FFFFFFELL, 0x7FFFFFFFLL },
};

#define NUM_ARITH_TESTS (sizeof(arith_tests) / sizeof(arith_tests[0]))

/* 数组测试用例 */
static const int64_t test_array1[] = { 1, 2, 3, 4, 5 };
static const int64_t test_array1_sum = 15;
static const int64_t test_array1_max = 5;
static const size_t test_array1_len = 5;

static const int64_t test_array2[] = { 3, 1, 4, 1, 5, 9, 2, 6 };
static const int64_t test_array2_sum = 31;
static const int64_t test_array2_max = 9;
static const size_t test_array2_len = 8;

static const int64_t test_array3[] = { -5, -2, -8, -1, -10 };
static const int64_t test_array3_sum = -26;
static const int64_t test_array3_max = -1;
static const size_t test_array3_len = 5;

/* 阶乘测试用例 */
typedef struct {
    int64_t n;
    int64_t expected;
} FactorialTestCase;

static const FactorialTestCase factorial_tests[] = {
    { 0, 1 },
    { 1, 1 },
    { 5, 120 },
    { 10, 3628800 },
    { 12, 479001600 },
};

#define NUM_FACTORIAL_TESTS (sizeof(factorial_tests) / sizeof(factorial_tests[0]))

/* 测试结果打印宏 */
#define TEST_PASS(name) printf("[PASS] %s\n", name)
#define TEST_FAIL(name, expected, actual) \
    printf("[FAIL] %s: expected %lld, got %lld\n", name, (long long)expected, (long long)actual)

#define RUN_TEST(name, expected, actual) \
    do { \
        if ((expected) == (actual)) { \
            TEST_PASS(name); \
        } else { \
            TEST_FAIL(name, expected, actual); \
            test_failures++; \
        } \
    } while(0)

#endif /* TEST_CASES_H */
