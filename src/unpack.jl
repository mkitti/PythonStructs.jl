# Unpack

function unpack(PS::Type{<: PythonStruct}, bytes::Vector{UInt8})
    iob = IOBuffer(bytes)
    _unpack(iob, PS)
end
unpack(python_struct::AbstractString, bytes::Vector{UInt8}) = unpack(PythonStruct(python_struct), bytes)
unpack(PS::Type{<: PythonStruct}, io::IO) = _unpack(io, PS)
unpack(python_struct::AbstractString, io::IO) = _unpack(io, PythonStruct(python_struct))
unpack(io::IO, PS::Type{<: PythonStruct}) = _unpack(io, PS)
unpack(io::IO, python_struct::AbstractString) = _unpack(io, PythonStruct(python_struct))
unpack(PS::Type{<: PythonStruct}) = Base.Fix1(unpack, PS)
unpack(python_struct::AbstractString, args...) = unpack(PythonStruct(python_struct), args...)

@inline unpack(io::IO, x) = Base.read(io, x)

# padding
function _unpack(io::IO, ::Type{<:PythonStruct{T,NativeModifier}}) where T
    start = position(io)
    n = fieldcount(T)
    t = ntuple(n) do i
        o = fieldoffset(T, i)
        seek(io, o + start)
        
        F = fieldtype(T, i)
        unpack(io, F)
    end
    t = convert(T, t)
    return filter_tuple(t)
end

# no padding
function _unpack(io::IO, ::Type{<:PythonStruct{T,NativeStandardModifier}}) where T
    start = position(io)
    n = fieldcount(T)
    t = ntuple(n) do i
        F = fieldtype(T, i)
        unpack(io, F)
    end
    t = convert(T, t)
    return filter_tuple(t)
end
function _unpack(io::IO, ::Type{<:PythonStruct{T,LittleEndianModifier}}) where T
    start = position(io)
    n = fieldcount(T)
    t = ntuple(n) do i
        F = fieldtype(T, i)
        ltoh(unpack(io, F))
    end
    t = convert(T, t)
    return filter_tuple(t)
end
function _unpack(io::IO, ::Type{<:PythonStruct{T,BigEndianModifier}}) where T
    start = position(io)
    n = fieldcount(T)
    t = ntuple(n) do i
        F = fieldtype(T, i)
        ntoh(unpack(io, F))
    end
    t = convert(T, t)
    return filter_tuple(t)
end

function unpack_from(ps, io::IO, offset=0)
    seek(io, offset)
    unpack(io, ps)
end
