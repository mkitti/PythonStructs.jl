"""
    NullByte

Represents `0x00` corresponding with `'x'`.
"""
struct NullByte
    z::UInt8
    NullByte() = new(0x00)
end
const nullbyte = NullByte()
Base.convert(::Type{NullByte}, x) = x == 0 ? nullbyte : error("Cannot convert $x to `NullByte`")
Base.convert(::Type{NullByte}, x::NullByte) = x
Base.write(io::IO, ::NullByte) = write(io, 0x00)
Base.bswap(::NullByte) = nullbyte
function Base.read(io::IO, ::Type{NullByte})
    byte = read(io, UInt8)
    byte == 0x00 ?
        nullbyte :
        error("Expected to read a null byte, but read $byte instead.")
end

"""
    ZeroCount{T}

Represents a `0` count of a type, which has some special meanings.
"""
struct ZeroCount{T}
end
Base.write(io::IO, ::ZeroCount) = 0
function Base.read(io::IO, Z::Type{<: ZeroCount})
    # do nothing
    Z()
end
Base.bswap(z::ZeroCount) = z
Base.eltype(::ZeroCount{T}) where T = T
Base.eltype(::Type{<: ZeroCount{T}}) where T = T


