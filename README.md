# PythonStruct.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mkitti.github.io/PythonStruct.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mkitti.github.io/PythonStruct.jl/dev/)
[![Build Status](https://github.com/mkitti/PythonStruct.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mkitti/PythonStruct.jl/actions/workflows/CI.yml?query=branch%3Amain)

PythonStruct.jl implements a similar API to Python's [`struct` standard library](https://docs.python.org/3/library/struct.html) in Julia. This package does not use any Python components and does not depend on PyCall.jl or PythonCall.jl.

The current design centers around the `PythonStruct{T,M}` type. `T` represents the underlying Julia struct type. `M` is a `PythonStructs.Modifier` type that has type parameters for byte order, size mapping, and alignment.

## Demonstration

```julia
julia> using PythonStructs

julia> pack("llh", 1, 2, 3)
18-element Vector{UInt8}:
 0x01
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x02
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x00
 0x03
 0x00

julia> pack("<llh", 1, 2, 3)
10-element Vector{UInt8}:
 0x01
 0x00
 0x00
 0x00
 0x02
 0x00
 0x00
 0x00
 0x03
 0x00

julia> pack(">llh", 1, 2, 3)
10-element Vector{UInt8}:
 0x00
 0x00
 0x00
 0x01
 0x00
 0x00
 0x00
 0x02
 0x00
 0x03

julia> pystruct"<llh"(1,2,3)
pystruct"<llh"((1, 2, 3))

julia> pystruct"<llh"(1,2,3) |> pack
10-element Vector{UInt8}:
 0x01
 0x00
 0x00
 0x00
 0x02
 0x00
 0x00
 0x00
 0x03
 0x00

julia> pystruct"<llh"(1,2,3) |> pack |> unpack("<llh")
(1, 2, 3)

julia> print(pystruct"<llh"(1,2,3))
PythonStruct{Tuple{Int32, Int32, Int16}, LittleEndianModifier}((1, 2, 3))
```

## Modifiers

| Python struct character | Byte order | Size | Alignment | Constant Name |
|---|---|---|
| @ | `:native`        | `:native`   | `:native` | NativeModifier         |
| = | `:native`        | `:standard` | `:none`   | NativeStandardModifier |
| < | `:little_endian` | `:standard `| `:none`   | LittleEndianModifier   |
| > | `:big_endian`    | `:standard` | `:none`   | BigEndianModifier      |
| ! | `:big_endian`    | `:standard` | `:none`   | NetworkModifier        |

## Type Mappings

| Python struct character | Native size type | Standard size type | * |
|---|---|---|
| x | PythonStructs.NullByte | PythonStructs.NullByte | |
| c | `Cchar`            | `Int8`            | |
| b | `Cchar`            | `Int8`            | |
| B | `Cuchar`           | `UInt8`           | |
| ? | `Cchar`            | `Int8`            | |
| h | `Cshort`           | `Int16`           | |
| H | `Cushort`          | `UInt16`          | |
| i | `Cint`             | `Int32`           | |
| I | `Cuint`            | `UInt32`          | |
| l | `Clong`            | `Int32`           |*|
| L | `Culong`           | `UInt32`          |*|
| q | `Clonglong`        | `Int64`           | |
| Q | `Culonglong`       | `UInt64`          | |
| n | `Cssize_t`         | `Cssize_t`        | |
| N | `Csize_t`          | `Csize_t`         | |
| e | `Float16`          | `Float16`         | |
| f | `Cfloat`           | `Float32`         | | 
| d | `Cdouble`          | `Float64`         | |
| s | `NTuple{1, Cchar}` | `NTuple{1, Int8}` | |
| p | `NTuple{1, Cchar}` | `NTuple{1, Int8}` | |
| P | `Ptr{Cvoid}`       | `Ptr{Nothing}`    | |

*The native and standard type mappings differ on 64-bit systems. `Clong` is `Int64`. `Culong` is `UInt64` in Julia.

## Development Stage

This is an early prototype. Currently, the fixed length string types are not implemented. I'm considering using https://github.com/mkitti/StaticStrings.jl for this purpose.

## Other packages of interest

* https://github.com/JuliaIO/StructIO.jl (new implementation of StrPack.jl)
* https://strpackjl.readthedocs.io/en/latest/ (old)
* https://github.com/JuliaInterop/Clang.jl (generates Julia structs from C headers)
* https://github.com/analytech-solutions/CBinding.jl (generates Julia structs from C headers)
