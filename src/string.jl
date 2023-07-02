# Convert from a PythonStruct to a character or string

"""
    modifier_char(s::Type{<: PythonStruct})

Get the modifier character for a particular [`Modifier`](@ref) constant.
"""
function modifier_char(s::Type{<: PythonStruct{T,M}}) where {T,M}
    M == NativeModifier ? '@' :
    M == NativeStandardModifier ? '!' :
    M == LittleEndianModifier ? '<' :
    M == BigEndianModifier ? '>' :
    error("Unknown modifier character for $M")
end
function pystruct_string(s::Type{<: PythonStruct{T}}) where T
    modifier_char(s) * pystruct_string(T)
end
function pystruct_string(s::Type{T}) where T
    iob = IOBuffer()
    n = fieldcount(T)
    for i in 1:n
        F = fieldtype(T, i)
        if F <: ZeroCount
            write(iob, '0')
            write(iob, reverse_standard_dict[eltype(F)])
        else
            write(iob, reverse_standard_dict[F])
        end
    end
    return String(take!(iob))
end
"""
    string(s::Type{<: PythonStruct})

Convert a [`PythonStruct`](@ref) to a Python struct format string.
The conversion is done with standard types.
"""
Base.string(s::Type{<: PythonStruct}) = pystruct_string(s)

