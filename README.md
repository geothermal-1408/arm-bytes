# ARM64(MAC Silicon) Assembly examples

Some toy examples for ARM64 assembly i have done during learning process.

## Overview

- Target: ARM64 (Apple Silicon) on macOS
- Toolchain: `as` (Apple/LLVM assembler) and `clang` for linking
- Output: One binary per `.s` source under `bin/`

## Examples

The repository includes the following programs:

- `0_hello.s`: Minimal "hello" style program demonstrating entry and exit.
- `1_basic.s`: Basics: registers, simple arithmetic, and control flow.
- `2_0_sum_of_natural.s`: Iterative sum of natural numbers (loops, counters).
- `2_1_fibo.s`: Fibonacci calculation (iteration; register usage).
- `2_2_recursive.s`: Recursion example (stack frames, `blr`, link register).
- `3_0_heap_mem.s`: Heap memory allocation and usage via libc.
- `3_2_dynamic_echo.s`: Echo-like I/O using libc calls.
- `3_3_calc.s`: A minimal calculator skeleton (parsing and operations).

> [!NOTE]
>
> More examples yet to add as I explore more

## Prerequisites

- macOS on Apple Silicon (ARM64)
- Xcode Command Line Tools (provides `clang` and `as`)

Install CLT if needed:

```bash
xcode-select --install
```

## Build

Build all examples and create `bin/` outputs:

```bash
make
```

Build particular example and create `bin/` output:

```bash
make <file_base_name>
```

Add debug info (`-g`) by setting `DBG=1`:

```bash
make DBG=1
```

Clean build outputs:

```bash
make clean
```

## Run

Each binary can be run via a Make target or directly from `bin/`.

Run using Make:

```bash
make run-<file_base_name>
```

Or run directly:

```bash
./bin/<file_base_name>
```

## Debugging (Optional)

Use `lldb` to step through instructions:

```bash
lldb ./bin/2_2_recursive
```

Recommended flags when debugging:

```bash
make DBG=1
```

## How It Works

- Assembly is compiled with `as -arch arm64` into `obj/*.o`.
- Binaries are linked with `clang -lc` into `bin/*`.
- Pattern rules in the Makefile ensure any new `.s` file is automatically built.

## Project Structure

- Root `.s` files: Source for each example program.
- `obj/`: Intermediate object files produced by the assembler.
- `bin/`: Final runnable binaries linked by `clang`.
- `Makefile`: Build rules for assembling and linking.

## Acknowledgements

- [ARM64 Assembly guide](https://cybersandeep.gitbook.io/arm64basicguide)

- [macos-system-call-table](https://github.com/rewired-gh/macos-system-call-table)
