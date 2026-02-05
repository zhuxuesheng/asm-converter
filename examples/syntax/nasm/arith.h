/*
 * NASM Assembly Functions Header
 * Declares functions implemented in arith.asm (Intel syntax)
 */

#ifndef ARITH_NASM_H
#define ARITH_NASM_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Basic arithmetic operations */
int64_t add_numbers(int64_t a, int64_t b);
int64_t sub_numbers(int64_t a, int64_t b);
int64_t mul_numbers(int64_t a, int64_t b);

/* Array operations */
int64_t sum_array(int64_t* arr, size_t len);
int64_t find_max(int64_t* arr, size_t len);

/* Function call demonstration */
int64_t factorial(int64_t n);

#ifdef __cplusplus
}
#endif

#endif /* ARITH_NASM_H */
