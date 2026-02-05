/**
 * Windows x64 C/Assembly Interop Test
 */

#include <stdio.h>

extern int asm_add(int a, int b);
extern long long asm_multiply(long long a, long long b);
extern double asm_add_doubles(double a, double b);
extern void asm_swap(int *a, int *b);

int main(void) {
    int result;
    long long result64;
    double resultf;
    int x = 10, y = 20;
    
    printf("=== Windows x64 C/ASM Interop Test ===\n\n");
    
    result = asm_add(10, 20);
    printf("asm_add(10, 20) = %d %s\n", result,
           result == 30 ? "[PASS]" : "[FAIL]");
    
    result64 = asm_multiply(1000000LL, 1000000LL);
    printf("asm_multiply = %lld %s\n", result64,
           result64 == 1000000000000LL ? "[PASS]" : "[FAIL]");
    
    resultf = asm_add_doubles(1.5, 2.5);
    printf("asm_add_doubles = %.1f %s\n", resultf,
           (resultf > 3.9 && resultf < 4.1) ? "[PASS]" : "[FAIL]");
    
    printf("Before swap: x=%d, y=%d\n", x, y);
    asm_swap(&x, &y);
    printf("After swap: x=%d, y=%d %s\n", x, y,
           (x == 20 && y == 10) ? "[PASS]" : "[FAIL]");
    
    return 0;
}
