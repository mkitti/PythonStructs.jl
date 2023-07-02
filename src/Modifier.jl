"""
    Modifier{byte_order, size, alignment}()

Modifier indicates how a Python struct string is interpreted. It is usually
determined by the first character of the string.

# Arguments
* `byte_order` is either :native (default), :little_endian, or :big_endian
* `size` is either :native (default) or :standard
* `alignment` is either :native (default) or :none

# Accessing Parameters
Modifier parameters can be accessed via the following access methods applied
to either the `Modifier` type or an instance.
* `byte_order_param`
* `size_param`
* `alignment_param`

Modifier parameters can also be accessed via the following properties of
a `Modifier` instance.
* `.byte_order`
* `.size`
* `.alignment`

# Constants
* `NativeModifier`, `'@'`, corresponds to Modifier{:native, :native, :native}
* `NativeStandardModifier`, `'='`, corresponds to Modifier{:native, :standard, :none}
* `LittleEndianModifier`, `<`, corresponds to Modifier{:little_endian, :standard, :none}
* `BigEndianModifier`, `<`, corresponds to Modifier{:big_endian, :standard, :none}
* `NetworkModifier`, `!`, is the same as `BigEndianModifier`

# Examples

```jldoctest
julia> LittleEndianModifier
LittleEndianModifier (alias for PythonStructs.Modifier{:little_endian, :standard, :none})

julia> m = LittleEndianModifier()
LittleEndianModifier()

julia> m.byte_order
:little_endian

julia> m.size
:standard

julia> m.alignment
:none

julia> PythonStructs.byte_order_param(PythonStructs.NativeModifier)
:native
```

# Extended Help

## Endianness

Endianness indicates the order of the bytes for multiple byte number types.
* Little endian order has the least significant byte (LSB) come first.
* Big endian order has the most significant byte (MSB) come first.

## Size

Size influences how the type characters are mapped to machine types.
* Native size corresponds to C types on the current system.
  For example, 'l' corresponds to `Clong`, or `Int64` on 64-bit systems.
* Standard size corresponds to fixed-size machine types that may  differ
  from their native size counterparts. For example, 'l' corresponds to `Int32`.

## Alignment

Alignment influences whether padding bytes are employed or not.
* Native alignment corresponds with how C and Julia use padding bytes.
* No alignment (none) does not use padding bytes.
"""
struct Modifier{byte_order, size, alignment}
    # byte_order::Symbol
    # size::Symbol
    # alignment::Symbol
    function Modifier{byte_order, size, alignment}() where {byte_order, size, alignment}
        byte_order in (:native, :little_endian, :big_endian) ||
            throw(ArgumentError("byte_order must be one of :native, :little_endian, or :big_endian"))
        size in (:native, :standard) ||
            throw(ArgumentError("size must be one of :native or :standard"))
        alignment in (:native, :none) ||
            throw(ArgumentError("alignment must be one of :native or :none"))
        new{byte_order, size, alignment}()
    end
end
Modifier(byte_order::Symbol, size::Symbol, alignment::Symbol) =
    Modifier{byte_order, size, alignment}()
Modifier() = Modifier(:native, :native, :native)
const default_modifier = Modifier() # '@'

# Add properties to Modifier instances
function Base.getproperty(m::Modifier{byte_order, size, alignment}, property::Symbol) where {byte_order, size, alignment}
    property == :byte_order ? byte_order :
    property == :size       ? size       :
    property == :alignment  ? alignment  :
    error("PythonStructs.Modifier has no property named $property.")
end
Base.propertynames(m::Modifier) = (:byte_order, :size, :alignment)

# Access Modifier instance parameters
byte_order_param(::Modifier{B}) where B = B
size_param(::Modifier{<: Any,S}) where {S} = S
alignment_param(::Modifier{<: Any, <: Any,A}) where {A} = A

# Access Modifier type parameters
byte_order_param(::Type{<: Modifier{B}}) where B = B
size_param(::Type{<: Modifier{<: Any,S}}) where {S} = S
alignment_param(::Type{<: Modifier{<: Any, <: Any,A}}) where {A} = A

#=
# Adding properties to the Modifier type adds unncessary compilatoin lag
function Base.getproperty(m::Type{Modifier{byte_order, size, alignment}}, property::Symbol) where {byte_order, size, alignment}
    property == :byte_order ? byte_order :
    property == :size       ? size       :
    property == :alignment  ? alignment  :
    getfield(m, property)
end
=#

"""
    NativeModifier = Modifier{:native, :native, :native}

This constant is the default [`Modifier`](@ref).
* `byte_order` :native
* `size` :native
* `alignment` :native
"""
const NativeModifier = Modifier{:native, :native, :native}
"""
    NativeStandardModifier = Modifier{:native, :standard, :none}}

* `byte_order` :native
* `size` :standard
* `alignment` :none
"""
const NativeStandardModifier = Modifier{:native, :standard, :none}
"""
    LittleEndianModifier = Modifier{:little_endian, :standard, :none}

* `byte_order` :little_endian
* `size` :standard
* `alignment` :none
"""
const LittleEndianModifier = Modifier{:little_endian, :standard, :none}
"""
    BigEndianModifier = Modifier{:big_endian, :standard, :none}

* `byte_order` :big_endian
* `size` :standard
* `alignment` :none
"""
const BigEndianModifier = Modifier{:big_endian, :standard, :none}
"""
    NetworkModifier = BigEndianModifier

Alias for [`BigEndianModifier`](@ref)
"""
const NetworkModifier = BigEndianModifier # Assuming network is IETF RFC 1700 compliant

const modifier_dict = Base.ImmutableDict(
    convert.(Pair{Char,Modifier},(
        '@' => Modifier(:native,        :native,   :native),
        '=' => Modifier(:native,        :standard, :none),
        '<' => Modifier(:little_endian, :standard, :none),
        '>' => Modifier(:big_endian,    :standard, :none),
        '!' => Modifier(:big_endian,    :standard, :none) # network order = big_endian
    ))...
)

"""
    modifier(c::Char)
    modifier(str::AbstractString)

Obtain the [`Modifier`](@ref) from a character.
If an `AbstractString` is provided, the first character is sued.

* '@' corresponds to `Modifier(:native,        :native,   :native)`
* `=` corresponds to `Modifier(:native,        :standard, :none)`
* `<` corresponds to `Modifier(:little_endian, :standard, :none)`
* `>` corresponds to `Modifier(:big_endian,    :standard, :none)`
* `!` corresponds to `Modifier(:big_endian,    :standard, :none)`
"""
function modifier(c::Char = '@')
    modifier_dict[c]
end
function modifier(str::AbstractString)
    modifier(first(str))
end
