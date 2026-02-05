// Package main provides arithmetic functions implemented in Go assembly.
// This demonstrates Go Plan9 assembly syntax for Windows x64.
package main

// Add returns the sum of two int64 values.
// Implemented in arith_amd64.s
//
//go:noescape
func Add(a, b int64) int64

// Sub returns the difference of two int64 values (a - b).
// Implemented in arith_amd64.s
//
//go:noescape
func Sub(a, b int64) int64

// Mul returns the product of two int64 values.
// Implemented in arith_amd64.s
//
//go:noescape
func Mul(a, b int64) int64

// SumArray returns the sum of all elements in the slice.
// Implemented in arith_amd64.s
//
//go:noescape
func SumArray(arr []int64) int64

// FindMax returns the maximum value in the slice.
// Returns 0 for empty slices.
// Implemented in arith_amd64.s
//
//go:noescape
func FindMax(arr []int64) int64

// Factorial returns n! (n factorial).
// Implemented in arith_amd64.s using iteration.
//
//go:noescape
func Factorial(n int64) int64

func main() {
	// Basic arithmetic tests
	println("=== Go Plan9 Assembly Syntax Demo ===")
	println()

	println("=== Arithmetic Operations ===")
	println("Add(10, 20) =", Add(10, 20))
	println("Sub(50, 30) =", Sub(50, 30))
	println("Mul(6, 7) =", Mul(6, 7))
	println()

	// Array operations
	println("=== Memory Access (Array Operations) ===")
	arr1 := []int64{1, 2, 3, 4, 5}
	println("SumArray([1,2,3,4,5]) =", SumArray(arr1))

	arr2 := []int64{3, 1, 4, 1, 5, 9, 2, 6}
	println("FindMax([3,1,4,1,5,9,2,6]) =", FindMax(arr2))
	println()

	// Function calls (factorial)
	println("=== Function Calls (Factorial) ===")
	println("Factorial(5) =", Factorial(5))
	println("Factorial(10) =", Factorial(10))
}
