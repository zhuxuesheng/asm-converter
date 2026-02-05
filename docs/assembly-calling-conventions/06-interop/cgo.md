# cgo 互操作规范

> Go通过cgo调用C函数的规范，包含调用开销和注意事项

## 概述

cgo允许Go程序调用C代码。本章节涵盖：

- cgo基本用法
- 从Go汇编调用C函数
- cgo调用开销
- 最佳实践

---

## cgo 基本用法

### 导入C代码

```go
package main

/*
#include <stdio.h>
#include <stdlib.h>

int c_add(int a, int b) {
    return a + b;
}
*/
import "C"

func main() {
    result := C.c_add(10, 20)
    println(result)
}
```

### 类型映射

| Go类型 | C类型 |
|--------|-------|
| C.char | char |
| C.schar | signed char |
| C.uchar | unsigned char |
| C.short | short |
| C.int | int |
| C.long | long |
| C.longlong | long long |
| C.float | float |
| C.double | double |

### 字符串转换

```go
// Go string → C string
cstr := C.CString(goStr)
defer C.free(unsafe.Pointer(cstr))

// C string → Go string
goStr := C.GoString(cstr)

// C string with length → Go string
goStr := C.GoStringN(cstr, length)
```

---

## 从Go汇编调用C

### 使用runtime·cgocall

Go汇编不能直接调用C函数，必须通过runtime：

```asm
// 不推荐：直接调用会破坏Go运行时
// CALL    c_function      // 错误！

// 正确方式：通过cgo包装
TEXT ·callCFunction(SB), $0-16
    MOVQ    arg+0(FP), DI
    CALL    ·cgoWrapper(SB)
    MOVQ    AX, ret+8(FP)
    RET
```

### cgo包装函数

```go
package main

/*
extern int c_process(int x);
*/
import "C"

//go:noinline
func cgoWrapper(x int) int {
    return int(C.c_process(C.int(x)))
}
```


---

## cgo 调用开销

### 开销来源

cgo调用比纯Go调用慢约100-1000倍，原因包括：

1. **栈切换**：从Go栈切换到系统栈
2. **调度器交互**：通知调度器当前goroutine阻塞
3. **参数转换**：Go类型到C类型的转换
4. **信号处理**：设置信号掩码

### 开销测量

```go
// 基准测试
func BenchmarkPureGo(b *testing.B) {
    for i := 0; i < b.N; i++ {
        goAdd(1, 2)
    }
}

func BenchmarkCgo(b *testing.B) {
    for i := 0; i < b.N; i++ {
        C.c_add(1, 2)
    }
}

// 典型结果:
// BenchmarkPureGo    1000000000    0.3 ns/op
// BenchmarkCgo       10000000      150 ns/op
```

### 减少开销的策略

1. **批量调用**：一次cgo调用处理多个数据
2. **减少调用频率**：在C侧完成更多工作
3. **使用unsafe**：某些场景可避免cgo

```go
// 不好：频繁调用
for i := 0; i < 1000; i++ {
    C.process_one(C.int(data[i]))
}

// 好：批量调用
C.process_batch((*C.int)(unsafe.Pointer(&data[0])), C.int(len(data)))
```

---

## 内存管理

### Go指针规则

cgo有严格的指针规则：

1. **Go指针不能传给C长期持有**
2. **C不能存储Go指针**
3. **Go指针指向的内存不能含有Go指针**

```go
// 错误：传递Go指针给C存储
var goData []byte
C.store_pointer(unsafe.Pointer(&goData[0])) // 危险！

// 正确：使用C分配的内存
cData := C.malloc(C.size_t(len(goData)))
defer C.free(cData)
C.memcpy(cData, unsafe.Pointer(&goData[0]), C.size_t(len(goData)))
C.store_pointer(cData)
```

### 内存分配

```go
// C分配，Go使用
ptr := C.malloc(100)
defer C.free(ptr)

// 转换为Go slice（不复制）
slice := (*[100]byte)(ptr)[:]

// 复制到Go内存
goSlice := C.GoBytes(ptr, 100)
```

---

## 回调函数

### C调用Go

```go
/*
extern void goCallback(int value);

void c_function_with_callback() {
    goCallback(42);
}
*/
import "C"

//export goCallback
func goCallback(value C.int) {
    println("Callback with:", value)
}
```

### 注意事项

1. **导出函数必须使用//export注释**
2. **回调中不能阻塞太久**
3. **回调中的panic会导致程序崩溃**

---

## 最佳实践

### 何时使用cgo

✓ 适合使用cgo：
- 调用成熟的C库（如OpenSSL、SQLite）
- 性能关键代码已有C实现
- 硬件接口需要C

✗ 避免使用cgo：
- 简单功能可用纯Go实现
- 高频调用的小函数
- 需要交叉编译

### 替代方案

| 场景 | 替代方案 |
|------|----------|
| 系统调用 | syscall包 |
| 简单C函数 | 纯Go重写 |
| 高性能计算 | Go汇编 |
| 外部进程 | os/exec |

---

## 参考资料

### 官方文档

- [cgo documentation](https://pkg.go.dev/cmd/cgo)
- [cgo wiki](https://github.com/golang/go/wiki/cgo)

### 相关文档

- 参见: [Go与汇编互操作](./go-assembly.md)
- 参见: [C/C++与汇编互操作](./c-cpp.md)
