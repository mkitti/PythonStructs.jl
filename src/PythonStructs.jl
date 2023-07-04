"""
    PythonStructs

The PythonStructs package implements the Python `structs` standard
library in Julia.
"""
module PythonStructs

export PythonStruct, pack, calcsize, unpack
export pack_into, unpack_from
# Modifiers
export NativeModifier, NativeStandardModifier
export LittleEndianModifier, BigEndianModifier
# String macro
export @pystruct_str

using StaticStrings

include("Modifier.jl")
include("PythonStruct.jl")
include("accessory_types.jl")
include("dicts.jl")
include("tuple.jl")
include("pack.jl")
include("unpack.jl")
include("string.jl")
include("calcsize.jl")
include("show.jl")

end
