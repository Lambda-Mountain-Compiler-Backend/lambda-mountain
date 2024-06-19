
### Hello World, from scratch

LM is a fragment assembler, which means it produces object files or flat human-readable assembly.
For this lesson we will be producing human-readable assembly files.

### Prerequisites

LM currently only supports the x86-64 Linux platform. So you will need access to a Linux box to complete the tutorial.

### Desired Output

The goal of this project will be to produce the following file:

```
.global _start
.text
_start:
  jmp main
main:
    mov $1, %rax
    mov $1, %rdi
    mov $hello_world_string, %rsi
    mov $11, %rdx
    syscall
    mov $60, %rax
    mov $0, %rdi
    syscall
.data
hello_world_string:
    .ascii "hello world"
```

This file contains GNU Assembly describing a file with two sections.
The data section contains an ASCII literal value for the string "hello world".
The text section contains a short program that prints the string to STDOUT then exits.

### Installing LM

First, to use LM we should install the compiler on our system.
To build and install LM we can move into the project directory and run `make install`.

```
git clone https://github.com/andrew-johnson-4/lambda-mountain.git
cd lambda-mountain
sudo make install
```

### The simplest LM Program

The simplest program in LM is an empty file.
Let's create a file called `hello_world.lm`.

```
# there is nothing here except for this comment
```

To compile this we should first run `lm` to produce the assembly file.

```
lm -o hello_world.s hello_world.lm
```

Now the compiler should produce the output `hello_world.s` assembly file.
Let's look inside:


```
.global _start
.text
_start:
        mov $60, %rax
        mov $0, %rdi
        syscall
```

We can see that the code loads the value `$60` into register `%rax`, this corresponds to the Linux x86-64 system call `sys-exit`.
The value `$0` into register `%rdi` will indicate a successful exit.
The `syscall` interrupt will invoke the operating system to perform the system call.
This is the shortest possible LM program that exits successfully.

### Including a Main Function

A `main` function is a function that will be called after initialization.
We don't need to handle command line arguments so our new file is pretty simple.

```
main := λ. (: () Nil);
```

This line is a little bit complicated so let's unpack this.
The first token is variable that will become the function name: `main`.
The next token `:=` is called a "binding" and is used to declare global variables.
The rest of the line is the function definition.
Functions are also called lambdas, and are declared with a λ (lambda) token, followed by the left-hand-side, a `.` dot, then the right hand side.
Our main function does not need to accept any arguments so the left-hand-side is left blank.
The right-hand-side is defined as an empty `()` Nil term that has been ascripted `(: term Type)` with the type Nil.
All global bindings must be explicitly typed, this is a limitation of the type inference algorithm.

Compiling this we will get:
```
.global _start
.text
_start:
        push %rbp
        mov %rsp, %rbp
        call main
        mov %rbp, %rsp
        pop %rbp
        mov $60, %rax
        mov $0, %rdi
        syscall
main:
        mov %rbp, %rsp
        sub $8, %rsp
        ret
```

The main function itself is pretty simple, it just returns immediately.
The pushing and popping from `%rbp` (base pointer) and `%rsp` (stack pointer) are part of the standard cdecl calling convention.
This calling convention allows us to store local variable in functions.
