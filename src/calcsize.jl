"""
    calcsize(::Type{<: PythonStruct})

Calculate the size of a [`PythonStruct`](@ref) type.
This differs from `sizeof` in the following ways.
* The inclusion of padding bytes depends on the `Modifier` `alignment`.
* Trailing padding bytes are not included.
"""
function calcsize(s::Type{<: PythonStruct{T,M}}) where {T, M <: Modifier{<:Any, <:Any, :native}}
    n = fieldcount(T)
    Z = fieldtype(T,n)
    if Z <: ZeroCount
        T2 = Tuple{fieldtypes(T)[1:end-1]..., eltype(Z)}
        return fieldoffset(T2, n)
    else
        return Int(fieldoffset(T, n) + sizeof(fieldtype(T,n)))
    end
end
function calcsize(s::Type{<: PythonStruct{T,<: Modifier{<:Any, <:Any, :none}}}) where {T}
    n = fieldcount(T)
    s = 0
    for i in 1:n
        s += sizeof(fieldtype(T,i))
    end
    return s
end
calcsize(x::Type{T}; modifier = default_modifier) where T = calcsize(PythonStruct{T,typeof(modifier)})
calcsize(x; modifier = default_modifier) = calcsize(typeof(x); modifier)
calcsize(str::AbstractString) = calcsize(PythonStruct(str))
