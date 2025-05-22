# [Lambda Mountain](https://github.com/andrew-johnson-4/-/wiki)

λ☶ (pronounced Lambda Mountain) is a typed macro assembler that provides a relatively clean implementation of **System F<: with Specialization**.

* [TUTORIAL](https://github.com/andrew-johnson-4/LSTS/wiki)
* [WIKI](https://github.com/andrew-johnson-4/-/wiki)
* [DOCS](https://lambda-mountain-compiler-backend.github.io/lsts-language-reference/)
* [DISCORD](https://discord.gg/sW2ksPY9jj)

### Not Your Average Assembler

Despite being an assembler, LM provides
* self-hosting (LM is written in LM)
* algebraic data types
* parameterized code and data
* hygienic macros
* platform agnostic standard libraries

### Why Such a Small Codebase?

LM is currently about 4000 lines of code.
LM solves an N by M Problem with language frontends vs language backends.
The LM project might interface with larger codebases that define frontends or backends, but the core LM Calculus can stay small.

### What is a Fragment Assembler?

An assembler takes pieces of data and sticks them together. Assemblers don't always understand the meaning of what they do, they just do it.

A fragment is a Key-Value Map of Strings to S-Expressions. This data structure permits more detailed manipulation of code than a typical assembler.

### IDE Support

Currently, there is only Vim and NeoVim syntax highlighting.
[instructions](./vim/README.md)
