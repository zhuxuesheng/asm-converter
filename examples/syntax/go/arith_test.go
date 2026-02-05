package main

import "testing"

// Test arithmetic operations
func TestAdd(t *testing.T) {
	tests := []struct {
		a, b, expected int64
	}{
		{10, 20, 30},
		{50, 30, 80},
		{6, 7, 13},
		{0, 100, 100},
		{-5, 3, -2},
		{100, -50, 50},
	}

	for _, tc := range tests {
		result := Add(tc.a, tc.b)
		if result != tc.expected {
			t.Errorf("Add(%d, %d) = %d; expected %d", tc.a, tc.b, result, tc.expected)
		}
	}
}

func TestSub(t *testing.T) {
	tests := []struct {
		a, b, expected int64
	}{
		{50, 30, 20},
		{10, 20, -10},
		{100, 100, 0},
		{-5, -3, -2},
	}

	for _, tc := range tests {
		result := Sub(tc.a, tc.b)
		if result != tc.expected {
			t.Errorf("Sub(%d, %d) = %d; expected %d", tc.a, tc.b, result, tc.expected)
		}
	}
}

func TestMul(t *testing.T) {
	tests := []struct {
		a, b, expected int64
	}{
		{6, 7, 42},
		{10, 20, 200},
		{0, 100, 0},
		{-5, 3, -15},
		{-4, -5, 20},
	}

	for _, tc := range tests {
		result := Mul(tc.a, tc.b)
		if result != tc.expected {
			t.Errorf("Mul(%d, %d) = %d; expected %d", tc.a, tc.b, result, tc.expected)
		}
	}
}

// Test array operations
func TestSumArray(t *testing.T) {
	tests := []struct {
		arr      []int64
		expected int64
	}{
		{[]int64{1, 2, 3, 4, 5}, 15},
		{[]int64{3, 1, 4, 1, 5, 9, 2, 6}, 31},
		{[]int64{-5, -2, -8, -1, -10}, -26},
		{[]int64{100}, 100},
		{[]int64{}, 0},
	}

	for _, tc := range tests {
		result := SumArray(tc.arr)
		if result != tc.expected {
			t.Errorf("SumArray(%v) = %d; expected %d", tc.arr, result, tc.expected)
		}
	}
}

func TestFindMax(t *testing.T) {
	tests := []struct {
		arr      []int64
		expected int64
	}{
		{[]int64{1, 2, 3, 4, 5}, 5},
		{[]int64{3, 1, 4, 1, 5, 9, 2, 6}, 9},
		{[]int64{-5, -2, -8, -1, -10}, -1},
		{[]int64{100}, 100},
		{[]int64{}, 0},
	}

	for _, tc := range tests {
		result := FindMax(tc.arr)
		if result != tc.expected {
			t.Errorf("FindMax(%v) = %d; expected %d", tc.arr, result, tc.expected)
		}
	}
}

// Test factorial
func TestFactorial(t *testing.T) {
	tests := []struct {
		n, expected int64
	}{
		{0, 1},
		{1, 1},
		{5, 120},
		{10, 3628800},
		{12, 479001600},
	}

	for _, tc := range tests {
		result := Factorial(tc.n)
		if result != tc.expected {
			t.Errorf("Factorial(%d) = %d; expected %d", tc.n, result, tc.expected)
		}
	}
}

// Benchmarks
func BenchmarkAdd(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Add(int64(i), int64(i+1))
	}
}

func BenchmarkSumArray(b *testing.B) {
	arr := make([]int64, 1000)
	for i := range arr {
		arr[i] = int64(i)
	}
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		SumArray(arr)
	}
}

func BenchmarkFactorial(b *testing.B) {
	for i := 0; i < b.N; i++ {
		Factorial(12)
	}
}
