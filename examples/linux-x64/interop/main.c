/**
 * Linux x64 C/Assembly Interop Test
 */

#include <stdio.h>

extern long asm_add(long a, long b);
extern long asm_multiply(long a, long b);
extern double asm_add_doubles(double a, double b);
extern void asm_swap(long *a, long *b);

int main(void) {
    long result;
    double resultf;
    long x = 10, y = 20;
    
    printf("=== Linux x64 C/ASM Interop Test ===\n\n");
    
    result = asm_add(10, 20);
    printf("asm_add(10, 20) = %ld %s\n", result,
           result == 30 ? "[PASS]" : "[FAIL]");
    
    result = asm_multiply(1000000L, 1000000L);
    printf("asm_multiply = %ld %s\n", result,
           result == 1000000000000L ? "[PASS]" : "[FAIL]");
    
    resultf = asm_add_doubles(1.5, 2.5);
    printf("asm_add_doubles = %.1f %s\n", resultf,
           (resultf > 3.9 && resultf < 4.1) ? "[PASS]" : "[FAIL]");
    
    printf("Before swap: x=%ld, y=%ld\n", x, y);
    asm_swap(&x, &y);
    printf("After swap: x=%ld, y=%ld %s\n", x, y,
           (x == 20 && y == 10) ? "[PASS]" : "[FAIL]");
    
    return 0;
}
