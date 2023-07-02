"""
    PythonStruct{T, M <: Modifier}(arg::T)
    PythonStruct{T, M <: Modifier}(args...)
    PythonStruct(string::AbstractString)

Wrap a type `T` with [`Modifier`](@ref) parameters or construct a `PythonStruct`
type from an `AbstractString`.
"""
struct PythonStruct{T, M <: Modifier}
    s::T
    PythonStruct{T,M}(arg::T) where {T,M <: Modifier} = new{T,M}(arg)
    PythonStruct{T,M}(arg::T2) where {T <: Tuple, M <: Modifier, T2 <: Tuple} = new{T,M}(convert_args(T, arg))
    PythonStruct{T,M}(arg::T2) where {T, M <: Modifier, T2 <: Tuple} = new{T,M}(convert_args(T, arg))
end
PythonStruct{T,M}(args...) where {T <: Tuple,M <: Modifier} = PythonStruct{T,M}(args)
PythonStruct{T,M}(args...) where {T,M <: Modifier} = PythonStruct{T,M}(args)
PythonStruct(str::AbstractString; modifier::Union{Nothing,Modifier,Type{<:Modifier}} = nothing) =
    isnothing(modifier) ? python_struct_to_type(str) : python_struct_to_type(str, modifier)
PythonStruct(str::AbstractString, args...; kwargs...) = python_struct_to_type(str; kwargs...)(args...)
Base.eltype(::Type{PythonStruct{T,M}}) where {T,M} = T 

"""
    python_struct_to_type(pystruct_string::AbstractString)
    python_struct_to_type(pystruct_string::AbstractString, m::Modifier)
    python_struct_to_type(pystruct_symbol::Symbol, modifier = default_modifier)

Convert a Python struct string to a `PythonStruct` type.

*Private API*
"""
function python_struct_to_type(pystruct_string::AbstractString, m::Modifier)
    pystruct_string_lowered = python_struct_lower(pystruct_string)
    type = if m.size == :standard
        python_struct_to_standard_type(pystruct_string_lowered)
    else
        python_struct_to_native_type(pystruct_string_lowered)
    end
    return PythonStruct{type, typeof(m)}
end
function python_struct_to_type(pystruct_string::AbstractString)
    c = pystruct_string[begin]
    if c in keys(modifier_dict)
        m = modifier_dict[c]
        pystruct_string = @view pystruct_string[2:end]
    else
        m = default_modifier
    end 
    python_struct_to_type(pystruct_string, m)
end
function python_struct_to_type(pystruct_symbol::Symbol, modifier = default_modifier)
    python_struct_to_type(String(pystruct_symbol), modifier)
end

"""
    pystruct""

Create a `PythonStruct` type from type characters.
"""
macro pystruct_str(ex)
     ps = python_struct_to_type(ex)
     quote
         $ps
     end
end

function insert_args(::Type{T}, args::Tuple) where T
    counter = 0
    ntuple(fieldcount(T)) do i
        F = fieldtype(T, i)
        if F == NullByte
            nullbyte
        elseif F <: ZeroCount
            F()
        else
            counter += 1
            args[counter]
        end
    end
end
function convert_args(::Type{T}, args::Tuple) where T
    convert(T, insert_args(T, args))
end
