/**
 * =============================================================================
 * ARM32 AAPCS 调用约定验证 - 测试程序
 * =============================================================================
 *
 * 本程序测试 ARM32 AAPCS 调用约定的汇编实现，验证:
 * - 整数参数传递 (R0, R1, R2, R3)
 * - 栈参数传递 (第5个及以后)
 * - 64位参数对齐规则
 * - 浮点参数传递 (S0-S15/D0-D7，硬浮点模式)
 * - 混合整数/浮点参数
 * - 汇编调用C函数
 * - 返回值 (R0/R0-R1 整数, S0/D0 浮点)
 * - Callee-saved 寄存器保存
 *
 * 编译命令: arm-linux-gnueabihf-gcc -mfpu=vfpv3 -mfloat-abi=hard -c -o main.o main.c
 * 链接命令: arm-linux-gnueabihf-gcc -mfpu=vfpv3 -mfloat-abi=hard -o test_calling_conv main.o calling_conv.o -lm
 * =============================================================================
 */

#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <inttypes.h>

/* =============================================================================
 * 汇编函数声明
 * =============================================================================
 */

/**
 * 四个整数参数相加
 * 参数: R0=a, R1=b, R2=c, R3=d
 * 返回: a + b + c + d
 */
extern int sum_four(int a, int b, int c, int d);

/**
 * 六个整数参数相加 - 前4个通过寄存器，后2个通过栈
 * 参数: R0=a, R1=b, R2=c, R3=d, [SP]=e, [SP+4]=f
 * 返回: a + b + c + d + e + f
 */
extern int sum_six(int a, int b, int c, int d, int e, int f);

/**
 * 64位参数对齐验证
 * 参数: R0=a, R2-R3=b (跳过R1), [SP]=c
 * 返回: a + b + c
 */
extern long long add64(int a, long long b, int c);

/**
 * 四个单精度浮点参数相加
 * 参数: S0=a, S1=b, S2=c, S3=d
 * 返回: a + b + c + d
 */
extern float sum_floats(float a, float b, float c, float d);

/**
 * 两个双精度浮点参数相加
 * 参数: D0=a, D1=b
 * 返回: a + b
 */
extern double sum_doubles(double a, double b);

/**
 * 混合整数和浮点参数
 * 参数: R0=n, D0=x, R1=m, D1=y
 * 返回: n * x + m * y
 */
extern double mixed_params(int n, double x, int m, double y);

/**
 * 汇编函数调用C函数
 * 参数: R0=x, R1=y
 * 返回: c_add(x, y)
 */
extern int asm_calls_c(int x, int y);

/**
 * 返回32位魔数
 * 返回: 0x12345678
 */
extern int get_magic_number(void);

/**
 * 返回64位大数
 * 返回: 0x123456789ABCDEF0
 */
extern long long get_big_value(void);

/**
 * 返回单精度π值
 * 返回: 3.14159265...
 */
extern float get_pi_float(void);

/**
 * 返回双精度π值
 * 返回: 3.14159265358979...
 */
extern double get_pi_double(void);

/**
 * 验证 callee-saved 寄存器保存
 * 参数: R0=a, R1=b, R2=c, R3=d
 * 返回: a + b + c + d
 */
extern int verify_callee_saved(int a, int b, int c, int d);

/**
 * 乘法累加
 * 参数: R0=a, R1=b, R2=c, R3=d, [SP]=e, [SP+4]=f
 * 返回: (a*b) + (c*d) + (e*f)
 */
extern int multiply_accumulate(int a, int b, int c, int d, int e, int f);

/**
 * 八个单精度浮点参数相加
 * 参数: S0-S7
 * 返回: a + b + c + d + e + f + g + h
 */
extern float many_float_params(float a, float b, float c, float d,
                               float e, float f, float g, float h);

/* =============================================================================
 * 被汇编调用的C函数
 * =============================================================================
 */

/**
 * 简单加法函数，被汇编代码调用
 * 验证汇编可以正确调用C函数
 */
int c_add(int a, int b) {
    return a + b;
}

/* =============================================================================
 * 测试工具
 * =============================================================================
 */

static int tests_passed = 0;
static int tests_failed = 0;

#define TEST_INT(name, actual, expected) do { \
    int _actual = (actual); \
    int _expected = (expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got %d, expected %d)\n", _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

#define TEST_INT64(name, actual, expected) do { \
    long long _actual = (actual); \
    long long _expected = (expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got 0x%llX, expected 0x%llX)\n", \
               (unsigned long long)_actual, (unsigned long long)_expected); \
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
    unsigned int _actual = (unsigned int)(actual); \
    unsigned int _expected = (unsigned int)(expected); \
    if (_actual == _expected) { \
        printf("  ... PASSED\n"); \
        tests_passed++; \
    } else { \
        printf("  ... FAILED (got 0x%X, expected 0x%X)\n", _actual, _expected); \
        tests_failed++; \
    } \
} while(0)

/* =============================================================================
 * 主测试程序
 * =============================================================================
 */

int main(void) {
    printf("=== ARM32 AAPCS Calling Convention Verification ===\n\n");

    /* -------------------------------------------------------------------------
     * 测试 1: 整数参数 (R0, R1, R2, R3)
     * ------------------------------------------------------------------------- */
    printf("[Test 1] Integer Parameters (R0, R1, R2, R3)\n");
    {
        int result = sum_four(10, 20, 30, 40);
        printf("  sum_four(10, 20, 30, 40) = %d\n", result);
        printf("  Expected: 100");
        TEST_INT("sum_four", result, 100);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 2: 栈参数 (第5个及以后)
     * ------------------------------------------------------------------------- */
    printf("[Test 2] Stack Parameters (5th and beyond)\n");
    {
        int result = sum_six(1, 2, 3, 4, 5, 6);
        printf("  sum_six(1, 2, 3, 4, 5, 6) = %d\n", result);
        printf("  Expected: 21");
        TEST_INT("sum_six", result, 21);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 3: 64位参数对齐
     * ------------------------------------------------------------------------- */
    printf("[Test 3] 64-bit Parameter Alignment\n");
    {
        // add64(a, b, c) = a + b + c
        // a=1, b=0x100000002 (4294967298), c=3
        // 结果 = 1 + 4294967298 + 3 = 4294967302 = 0x100000006
        long long result = add64(1, 0x100000002LL, 3);
        printf("  add64(1, 0x100000002, 3) = 0x%llX\n", (unsigned long long)result);
        printf("  Expected: 0x100000006");
        TEST_INT64("add64", result, 0x100000006LL);
        printf("  Note: 64-bit param 'b' uses R2-R3 (R1 skipped for alignment)\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 4: 单精度浮点参数 (S0-S15)
     * ------------------------------------------------------------------------- */
    printf("[Test 4] Floating Point Parameters (S0-S15)\n");
    {
        float result = sum_floats(1.5f, 2.5f, 3.5f, 4.5f);
        printf("  sum_floats(1.5, 2.5, 3.5, 4.5) = %f\n", result);
        printf("  Expected: 12.0");
        TEST_FLOAT("sum_floats", result, 12.0f, 0.0001f);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 5: 双精度浮点参数 (D0-D7)
     * ------------------------------------------------------------------------- */
    printf("[Test 5] Double Precision Parameters (D0-D7)\n");
    {
        double result = sum_doubles(1.5, 2.5);
        printf("  sum_doubles(1.5, 2.5) = %f\n", result);
        printf("  Expected: 4.0");
        TEST_DOUBLE("sum_doubles", result, 4.0, 0.0001);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 6: 混合整数/浮点参数
     * ------------------------------------------------------------------------- */
    printf("[Test 6] Mixed Integer/Float Parameters\n");
    {
        // mixed_params(n, x, m, y) = n * x + m * y
        // mixed_params(2, 3.0, 4, 5.0) = 2 * 3.0 + 4 * 5.0 = 6.0 + 20.0 = 26.0
        double result = mixed_params(2, 3.0, 4, 5.0);
        printf("  mixed_params(2, 3.0, 4, 5.0) = %f\n", result);
        printf("  Expected: 26.0 (2*3.0 + 4*5.0)");
        TEST_DOUBLE("mixed_params", result, 26.0, 0.0001);
        printf("  Note: Integer params use R0,R1; Float params use D0,D1\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 7: 汇编调用C函数
     * ------------------------------------------------------------------------- */
    printf("[Test 7] Assembly Calling C Function\n");
    {
        int result = asm_calls_c(100, 200);
        printf("  asm_calls_c(100, 200) = %d\n", result);
        printf("  Expected: 300");
        TEST_INT("asm_calls_c", result, 300);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 8: 返回值 (R0, R0-R1, S0, D0)
     * ------------------------------------------------------------------------- */
    printf("[Test 8] Return Values\n");
    {
        int magic = get_magic_number();
        printf("  get_magic_number() = 0x%X\n", (unsigned int)magic);
        printf("  Expected: 0x12345678");
        TEST_HEX("get_magic_number", magic, 0x12345678);

        long long big = get_big_value();
        printf("  get_big_value() = 0x%llX\n", (unsigned long long)big);
        printf("  Expected: 0x123456789ABCDEF0");
        TEST_INT64("get_big_value", big, 0x123456789ABCDEF0LL);

        float pi_f = get_pi_float();
        printf("  get_pi_float() = %.10f\n", pi_f);
        printf("  Expected: 3.14159265...");
        TEST_FLOAT("get_pi_float", pi_f, 3.14159265f, 0.0000001f);

        double pi_d = get_pi_double();
        printf("  get_pi_double() = %.15f\n", pi_d);
        printf("  Expected: 3.14159265358979...");
        TEST_DOUBLE("get_pi_double", pi_d, 3.14159265358979, 0.00000000001);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 9: Callee-saved 寄存器保存
     * ------------------------------------------------------------------------- */
    printf("[Test 9] Callee-saved Register Preservation\n");
    {
        int result = verify_callee_saved(1000, 2000, 3000, 4000);
        printf("  verify_callee_saved(1000, 2000, 3000, 4000) = %d\n", result);
        printf("  Expected: 10000");
        TEST_INT("verify_callee_saved", result, 10000);
        printf("  Note: R4-R11 must be preserved across function calls\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 10: 乘法累加
     * ------------------------------------------------------------------------- */
    printf("[Test 10] Multiply Accumulate\n");
    {
        // multiply_accumulate(a, b, c, d, e, f) = (a*b) + (c*d) + (e*f)
        // = (2*3) + (4*5) + (6*7) = 6 + 20 + 42 = 68
        int result = multiply_accumulate(2, 3, 4, 5, 6, 7);
        printf("  multiply_accumulate(2, 3, 4, 5, 6, 7) = %d\n", result);
        printf("  Expected: 68 ((2*3) + (4*5) + (6*7))");
        TEST_INT("multiply_accumulate", result, 68);
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 11: 多个浮点参数 (8个S寄存器)
     * ------------------------------------------------------------------------- */
    printf("[Test 11] Many Float Parameters (8 S registers)\n");
    {
        // Sum of 1.0 + 2.0 + 3.0 + 4.0 + 5.0 + 6.0 + 7.0 + 8.0 = 36.0
        float result = many_float_params(1.0f, 2.0f, 3.0f, 4.0f, 5.0f, 6.0f, 7.0f, 8.0f);
        printf("  many_float_params(1.0, 2.0, ..., 8.0) = %f\n", result);
        printf("  Expected: 36.0");
        TEST_FLOAT("many_float_params", result, 36.0f, 0.0001f);
        printf("  Note: ARM32 supports up to 16 float params in S0-S15\n");
    }
    printf("\n");

    /* -------------------------------------------------------------------------
     * 测试 12: 边界情况
     * ------------------------------------------------------------------------- */
    printf("[Test 12] Edge Cases\n");
    {
        // 测试零值
        int result1 = sum_four(0, 0, 0, 0);
        printf("  sum_four(0, 0, 0, 0) = %d\n", result1);
        printf("  Expected: 0");
        TEST_INT("sum_four_zeros", result1, 0);

        // 测试负数
        int result2 = sum_four(-10, 20, -30, 40);
        printf("  sum_four(-10, 20, -30, 40) = %d\n", result2);
        printf("  Expected: 20");
        TEST_INT("sum_four_negative", result2, 20);

        // 测试大数
        int result3 = sum_four(0x10000000, 0x20000000, 0x30000000, 0x40000000);
        printf("  sum_four(large values) = 0x%X\n", (unsigned int)result3);
        printf("  Expected: 0xA0000000");
        TEST_HEX("sum_four_large", result3, 0xA0000000);
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
