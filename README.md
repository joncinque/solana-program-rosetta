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

| Language | CU Usage |
| --- | --- |
| Rust | 105 |
| Zig | 105 |
| C | 105 |
| Assembly | 104 |

Since this is just doing a syscall, all the languages behave the same. The only
difference is that the Assembly version *doesn't* set the return code to 0, and
lets the VM assume it worked.

* Transfer-Lamports: moves lamports from a source account to a destination, with
the amount given by a little-endian u64 in instruction data.

| Language | CU Usage |
| --- | --- |
| Rust | 459 |
| Zig | 44 |
| C | 104 |
| Assembly | 30 |
| Rust (pinocchio) | 32 |

This one starts to get interesting since it requires parsing the instruction
input. Since the assembly version knows exactly where to find everything, it can
be hyper-optimized. The pinocchio version performs very closely to the assembly
implementation!

* CPI: allocates a PDA given by the seed "You pass butter" and a bump seed in
the instruction data. This requires a call to `create_program_address` to check
the address and `invoke_signed` to CPI to the system program.

| Language | CU Usage | CU Usage (minus syscalls) |
| --- | --- | --- |
| Rust | 3698 | 1198 |
| Zig | 2825 | 325 |
| C | 3122 | 622 |
| Rust (pinocchio) | 2816 | 316 |

Note: `create_program_address` consumes 1500 CUs, and `invoke` consumes 1000, so
we can subtract 2500 CUs from each program to see the actual cost of the program
logic.

* Token: a reduced instruction set from SPL-Token. Includes an entrypoint,
instruction deserialization, and account serde. The Rust version is the full SPL
Token program.

  * Initialize Mint

| Language | CU Usage |
| --- | --- |
| Rust | 1115 |

  * Initialize Account

| Language | CU Usage |
| --- | --- |
| Rust | 2071 |

  * Mint To

| Language | CU Usage |
| --- | --- |
| Rust | 2189 |

  * Transfer

| Language | CU Usage |
| --- | --- |
| Rust | 2208 |

  * Burn

| Language | CU Usage |
| --- | --- |
| Rust | 2045 |

  * Close Account

| Language | CU Usage |
| --- | --- |
| Rust | 1483 |
