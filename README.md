# solana-program-rosetta

Multiple implementations of Solana programs across languages: Rust, Zig, C, and
even assembly.

More programs will be added over time!

## Getting started

### Prerequisite for all languages

* Install Rust: https://www.rust-lang.org/tools/install

### Rust

* Install Solana tools

```console
./install-solana.sh
```

* Go to a program directory

```console
cd helloworld
```

* Build a program

```console
cargo build-sbf
```

* Test a program

```console
cargo test-sbf
```

### Zig

* Get the compiler

```console
./install-solana-zig.sh
```

* Go to the Zig implementation of a program

```console
cd helloworld/zig
```

* Build the program

```console
../../solana-zig/zig build
```

* Test it

```console
cd ..
SBF_OUT_DIR="./zig/zig-out/lib" cargo test
```

* OR use the helper from the root of this repo to build and test

```console
./test-zig.sh helloworld
```

### C

* Install Solana C compiler

```console
./install-solana-c.sh
```

* Install Solana tools

```console
./install-solana.sh
```

* Go to a program directory

```console
cd helloworld/c
```

* Build a program

```console
make
```

* Test it

```console
cd ..
SBF_OUT_DIR="./c/out" cargo test
```

* OR use the helper from the root of this repo to build and test

```console
./test-c.sh helloworld
```

### Assembly

* Install Solana LLVM tools

```console
./install-solana-llvm.sh
```

* Go to a program directory

```console
cd helloworld/asm
```

* Build a program

```console
make
```

* Test it

```console
cd ..
SBF_OUT_DIR="./asm/out" cargo test
```

* OR use the helper from the root of this repo to build and test

```console
./test-asm.sh helloworld
```

## Current Programs

* Helloworld: logs a static string using the `sol_log_` syscall
