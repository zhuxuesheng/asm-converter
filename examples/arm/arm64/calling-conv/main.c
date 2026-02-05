/**
 * =============================================================================
 * ARM64 AAPCS64 调用约定验证 - 测试程序
 * =============================================================================
 *
 * 本程序测试 ARM64 AAPCS64 调用约定的汇编实现，验证:
 * - 整数参数传递 (X0-X7)
 * - 栈参数传递 (第9个及以后)
 * - 浮点参数传递 (D0-D7，独立计数)
 * - 混合整数/浮点参数（独立计数！）
 * - 汇编调用C函数
 * - 返回值 (X0/X0-X1 整数, D0 浮点)
 * - Callee-saved 寄存器保存 (X19-X28)
 * - 16字节栈对齐
 *
 * 编译命令: aarch64-linux-gnu-gcc -c -o main.o main.c
 * 链接命令: aarch64-linux-gnu-gcc -o test_calling_conv main.o calling_conv.o -lm
 * =============================================================================
 */

#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <inttypes.h>
#include <string.h>

/* =============================================================================
 * 汇编函数声明
 * =============================================================================
 */

/**
 * 八个整数参数相加
 * 参数: X0-X7
 * 返回: a + b + c + d + e + f + g + h
 */
extern long sum_eight(long a, long b, long c, long d, long e, long f, long g, long h);

/**
 * 十个整数参数相加 - 前8个通过寄存器，后2个通过栈
 * 参数: X0-X7, [SP], [SP+8]
 * 返回: a + b + c + d + e + f + g + h + i + j
 */
extern long sum_ten(long a, long b, long c, long d, long e, long f, long g, long h, long i, long j);

/**
 * 四个双精度浮点参数相加
 * 参数: D0=a, D1=b, D2=c, D3=d
 * 返回: a + b + c + d
 */
extern double sum_doubles(double a, double b, double c, double d);

/**
 * 四个单精度浮点参数相加
 * 参数: S0=a, S1=b, S2=c, S3=d
 * 返回: a + b + c + d
 */
extern float sum_floats(float a, float b, float c, float d);

/**
 * 混合整数和浮点参数（独立计数）
 * 参数: X0=n, D0=x, X1=m, D1=y
 * 返回: n * x + m * y
 */
extern double mixed_params(long n, double x, long m, double y);

/**
 * 汇编函数调用C函数
 * 参数: X0=x, X1=y
 * 返回: c_add(x, y)
 */
extern long asm_calls_c(long x, long y);

/**
 * 返回64位魔数
 * 返回: 0x123456789ABCDEF0
 */
extern long get_magic_number(void);

/**
 * 返回128位大数
 * 返回: X0=低64位, X1=高64位
 */
extern __int128 get_big_value(void);

/**
 * 返回双精度π值
 * 返回: 3.14159265358979...
 */
extern double get_pi(void);

/**
 * 返回单精度π值
 * 返回: 3.14159265...
 */
extern float get_pi_float(void);

/**
 * 验证 callee-saved 寄存器保存
 * 参数: X0=a, X1=b, X2=c, X3=d
 * 返回: a + b + c + d
 */
extern long verify_callee_saved(long a, long b, long c, long d);

/**
 * 验证16字节栈对齐
 * 参数: X0=a, X1=b
 * 返回: a + b
 */
extern long verify_stack_alignment(long a, long b);

/**
 * 乘法累加
 * 参数: X0=a, X1=b, X2=c, X3=d, X4=e, X5=f
 * 返回: (a*b) + (c*d) + (e*f)
 */
extern long multiply_accumulate(long a, long b, long c, long d, long e, long f);

/**
 * 八个双精度浮点参数相加
 * 参数: D0-D7
 * 返回: a + b + c + d + e + f + g + h
 */
extern double many_float_params(double a, double b, double c, double d,
                                double e, double f, double g, double h);

/**
 * 演示零寄存器使用
 * 参数: X0=a
 * 返回: a + 0
 */
extern long use_zero_register(long a);

/**
 * SIMD向量加法
 * 参数: X0=dst, X1=a, X2=b, X3=n
 * 功能: dst[i] = a[i] + b[i]
 */
extern void simd_vector_add(float* dst, float* a, float* b, long n);

/* =============================================================================
 * 被汇编调用的C函数
 * =============================================================================
 */

/**
 * 简单加法函数，被汇编代码调用
 * 验证汇编可以正确调用C函数
 */
long c_add(long a, long b) {
    return a + b;
}

/* =============================================================================
 * 测试工具
 * =============================================================================
 */

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST_LONG(name, actual, expected) do { \
    long _actual = (actual); \
    long _expected = (expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got %ld, expected %ld)\n", _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

#define TEST_FLOAT(name, actual, expected, epsilon) do { \
    float _actual = (actual); \
    float _expected = (expected); \
    if (fabsf(_actual - _expected) < (epsilon)) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got %f, expected %f)\n", _actual, _expected); \
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
    unsigned long _actual = (unsigned long)(actual); \
    unsigned long _expected = (unsigned long)(expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got 0x%lX, expected 0x%lX)\n", _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

/* =============================================================================
 * 主测试程序
 * =============================================================================
 */

int main(void) {
    printf("=== ARM64 AAPCS64 Calling Convention Verification ===\n\n");

    /* -------------------------------------------------------------------------
     * 测试 1: 整数参数 (X0-X7)
     * ------------------------------------------------------------------------- */
    printf("[Test 1] Integer Parameters (X0-X7)\n");
    {
        long result = sum_eight(1, 2, 3, 4, 5, 6, 7, 8);
        printf("  sum_eight(1, 2, 3, 4, 5, 6, 7, 8) = %ld\n", result);
        printf("  Expected: 36");
        TEST_LONG("sum_eight", result, 36);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 2: 栈参数 (第9个及以后)
     * ------------------------------------------------------------------------- */
    printf("[Test 2] Stack Parameters (9th and beyond)\n");
    {
        long result = sum_ten(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
        printf("  sum_ten(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) = %ld\n", result);
        printf("  Expected: 55");
        TEST_LONG("sum_ten", result, 55);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 3: 双精度浮点参数 (D0-D7)
     * ------------------------------------------------------------------------- */
    printf("[Test 3] Double Precision Parameters (D0-D7)\n");
    {
        double result = sum_doubles(1.5, 2.5, 3.5, 4.5);
        printf("  sum_doubles(1.5, 2.5, 3.5, 4.5) = %f\n", result);
        printf("  Expected: 12.0");
        TEST_DOUBLE("sum_doubles", result, 12.0, 0.0001);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 4: 单精度浮点参数 (S0-S7)
     * ------------------------------------------------------------------------- */
    printf("[Test 4] Single Precision Parameters (S0-S7)\n");
    {
        float result = sum_floats(1.5f, 2.5f, 3.5f, 4.5f);
        printf("  sum_floats(1.5, 2.5, 3.5, 4.5) = %f\n", result);
        printf("  Expected: 12.0");
        TEST_FLOAT("sum_floats", result, 12.0f, 0.0001f);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 5: 混合整数/浮点参数（独立计数）
     * ------------------------------------------------------------------------- */
    printf("[Test 5] Mixed Integer/Float Parameters (Independent Counting)\n");
    {
        // mixed_params(n, x, m, y) = n * x + m * y
        // mixed_params(2, 3.0, 4, 5.0) = 2 * 3.0 + 4 * 5.0 = 6.0 + 20.0 = 26.0
        double result = mixed_params(2, 3.0, 4, 5.0);
        printf("  mixed_params(2, 3.0, 4, 5.0) = %f\n", result);
        printf("  Expected: 26.0 (2*3.0 + 4*5.0)");
        TEST_DOUBLE("mixed_params", result, 26.0, 0.0001);
        printf("  Note: Integer params use X0,X1; Float params use D0,D1\n");
        printf("        (Independent counting in ARM64!)\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 6: 汇编调用C函数
     * ------------------------------------------------------------------------- */
    printf("[Test 6] Assembly Calling C Function\n");
    {
        long result = asm_calls_c(100, 200);
        printf("  asm_calls_c(100, 200) = %ld\n", result);
        printf("  Expected: 300");
        TEST_LONG("asm_calls_c", result, 300);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 7: 返回值 (X0, X0-X1, D0)
     * ------------------------------------------------------------------------- */
    printf("[Test 7] Return Values\n");
    {
        long magic = get_magic_number();
        printf("  get_magic_number() = 0x%lX\n", (unsigned long)magic);
        printf("  Expected: 0x123456789ABCDEF0");
        TEST_HEX("get_magic_number", magic, 0x123456789ABCDEF0UL);

        double pi = get_pi();
        printf("  get_pi() = %.15f\n", pi);
        printf("  Expected: 3.14159265358979...");
        TEST_DOUBLE("get_pi", pi, 3.14159265358979, 0.00000000001);

        float pi_f = get_pi_float();
        printf("  get_pi_float() = %.10f\n", pi_f);
        printf("  Expected: 3.14159265...");
        TEST_FLOAT("get_pi_float", pi_f, 3.14159265f, 0.0000001f);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 8: Callee-saved 寄存器保存
     * ------------------------------------------------------------------------- */
    printf("[Test 8] Callee-saved Register Preservation\n");
    {
        long result = verify_callee_saved(1000, 2000, 3000, 4000);
        printf("  verify_callee_saved(1000, 2000, 3000, 4000) = %ld\n", result);
        printf("  Expected: 10000");
        TEST_LONG("verify_callee_saved", result, 10000);
        printf("  Note: X19-X28 must be preserved across function calls\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 9: 16字节栈对齐
     * ------------------------------------------------------------------------- */
    printf("[Test 9] 16-byte Stack Alignment\n");
    {
        long result = verify_stack_alignment(100, 200);
        printf("  verify_stack_alignment(100, 200) = %ld\n", result);
        printf("  Expected: 300");
        TEST_LONG("verify_stack_alignment", result, 300);
        printf("  Note: SP must always be 16-byte aligned in AAPCS64\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 10: 乘法累加
     * ------------------------------------------------------------------------- */
    printf("[Test 10] Multiply Accumulate\n");
    {
        // multiply_accumulate(a, b, c, d, e, f) = (a*b) + (c*d) + (e*f)
        // = (2*3) + (4*5) + (6*7) = 6 + 20 + 42 = 68
        long result = multiply_accumulate(2, 3, 4, 5, 6, 7);
        printf("  multiply_accumulate(2, 3, 4, 5, 6, 7) = %ld\n", result);
        printf("  Expected: 68 ((2*3) + (4*5) + (6*7))");
        TEST_LONG("multiply_accumulate", result, 68);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 11: 多个浮点参数 (8个D寄存器)
     * ------------------------------------------------------------------------- */
    printf("[Test 11] Many Float Parameters (8 D registers)\n");
    {
        // Sum of 1.0 + 2.0 + 3.0 + 4.0 + 5.0 + 6.0 + 7.0 + 8.0 = 36.0
        double result = many_float_params(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0);
        printf("  many_float_params(1.0, 2.0, ..., 8.0) = %f\n", result);
        printf("  Expected: 36.0");
        TEST_DOUBLE("many_float_params", result, 36.0, 0.0001);
        printf("  Note: ARM64 supports 8 float params in D0-D7\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 12: 零寄存器使用
     * ------------------------------------------------------------------------- */
    printf("[Test 12] Zero Register (XZR) Usage\n");
    {
        long result = use_zero_register(42);
        printf("  use_zero_register(42) = %ld\n", result);
        printf("  Expected: 42 (a + 0, XZR reads as 0)");
        TEST_LONG("use_zero_register", result, 42);
        printf("  Note: XZR always reads as 0, writes are discarded\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 13: SIMD向量操作
     * ------------------------------------------------------------------------- */
    printf("[Test 13] SIMD Vector Operations\n");
    {
        float a[8] = {1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f};
        float b[8] = {0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f, 0.5f};
        float dst[8] = {0};
        
        simd_vector_add(dst, a, b, 8);
        
        printf("  simd_vector_add: a[0..7] + b[0..7] = dst[0..7]\n");
        printf("  dst = [%.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f, %.1f]\n",
               dst[0], dst[1], dst[2], dst[3], dst[4], dst[5], dst[6], dst[7]);
        printf("  Expected: [1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5]");
        
        int simd_passed = 1;
        float expected[8] = {1.5f, 2.5f, 3.5f, 4.5f, 5.5f, 6.5f, 7.5f, 8.5f};
        for (int i = 0; i < 8; i++) {
            if (fabsf(dst[i] - expected[i]) > 0.0001f) {
                simd_passed = 0;
                break;
            }
        }
        if (simd_passed) {
            printf("  ... PASSED\n");
            tests_passed++;
        } else {
            printf("  ... FAILED\n");
            tests_failed++;
        }
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 14: 边界情况
     * ------------------------------------------------------------------------- */
    printf("[Test 14] Edge Cases\n");
    {
        // 测试零值
        long result1 = sum_eight(0, 0, 0, 0, 0, 0, 0, 0);
        printf("  sum_eight(0, 0, 0, 0, 0, 0, 0, 0) = %ld\n", result1);
        printf("  Expected: 0");
        TEST_LONG("sum_eight_zeros", result1, 0);

        // 测试负数
        long result2 = sum_eight(-10, 20, -30, 40, -50, 60, -70, 80);
        printf("  sum_eight(-10, 20, -30, 40, -50, 60, -70, 80) = %ld\n", result2);
        printf("  Expected: 40");
        TEST_LONG("sum_eight_negative", result2, 40);

        // 测试大数
        long result3 = sum_eight(0x1000000000L, 0x2000000000L, 0x3000000000L, 0x4000000000L,
                                 0x5000000000L, 0x6000000000L, 0x7000000000L, 0x8000000000L);
        printf("  sum_eight(large values) = 0x%lX\n", (unsigned long)result3);
        printf("  Expected: 0x24000000000");
        TEST_HEX("sum_eight_large", result3, 0x24000000000L);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试总结
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
