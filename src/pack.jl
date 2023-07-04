# Julian API, IO first, instantiate the PythonStruct directly

"""
    pack([io::IO], s::PS) where PS <: PythonStruct
    pack(PythonStruct{T,M}, [io::IO], args...)
    pack(s::AbstractString, [io::IO], args...)

Pack a [`PythonStruct`](@ref) into bytes. If `io` is provided, the bytes are
written the `IO` object. Otherwise, the bytes are returned as a `Vector{UInt8}`.
"""
function pack(io::IO, s::PS) where PS <: PythonStruct
    _pack(io, s)
end
pack(s::PS) where PS = take!(pack(IOBuffer(; sizehint = calcsize(PS)), s))

# Pythonic API, use the Type, IO optionally second (why?), args after

function pack(S::Type{PythonStruct{T, M}}, args...) where {T,M}
    iob = IOBuffer(; sizehint = calcsize(S))
    pack(S, iob, args...)
    return take!(iob)
end
function pack(S::Type{PythonStruct{T, M}}, io::IO, args...) where {T, M} 
    #if length(args) != fieldcount(T)
    #    throw(ArgumentError("The number of arguments must match the $(fieldcount(T)) arguments of $T, but $(length(args)) were provided."))
    #end
    _pack(io, S(args...))
end
function pack(s::AbstractString, args...)
    pack(PythonStruct(s), args...)
end
function pack(S::Type{<: PythonStruct})
    Base.Fix1(pack, S)
end
@inline pack(io::IO, x) = Base.write(io, x)
function pack(io::IO, x::NTuple{N,T}) where {N,T}
    sum(x) do element
        pack(io, element)
    end
end

# Internal packing machinery

# With alignment padding
function _pack(io::IO, s::PythonStruct{T, NativeModifier}) where T
    args = s.s
    n = fieldcount(T)
    start = position(io)
    for i in 1:n
        # Pad between fields
        o = fieldoffset(T, i)
        if o != 0
            # fieldoffset(T, i) is assumed to be 0
            for _ in (position(io) - start):(o-1)
                write(io, 0x00)
            end
        end

        pack(io, args[i])
    end
    Z = fieldtype(T,n)
    if Z <: ZeroCount
        T2 = Tuple{fieldtypes(T)[1:end-1]..., eltype(Z)}
        for _ in (position(io) - start):(fieldoffset(T2, n) + start - 1)
            write(io, 0x00)
        end
    end
    return io
end

# No alignment padding
function _pack(io::IO, s::PythonStruct{T, NativeStandardModifier}) where T
    args = s.s
    n = fieldcount(T)
    for i in 1:n
        pack(io, getfield(args, i))
    end
    return io
end
function _pack(io::IO, s::PythonStruct{T, LittleEndianModifier}) where T
    args = s.s
    n = fieldcount(T)
    for i in 1:n
        # htol should just be the identity in little endian systems
        pack(io, htol(getfield(args, i)))
    end
    return io
end
function _pack(io::IO, s::PythonStruct{T, BigEndianModifier}) where T
    args = s.s
    n = fieldcount(T)
    for i in 1:n
        # hton should just be the identity in big endian systems
        pack(io, hton(getfield(args, i)))
    end
    return io
end


function pack_into(ps, io::IO, offset, args...)
    seek(io, offset)
    pack(ps, io, args...)
end
