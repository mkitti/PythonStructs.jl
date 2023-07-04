"""
    python_struct_to_native_type(pystruct_string::AbstractString)

Use [`python_struct_to_type`](@ref) with the native format dictionary.

*Private API*
"""
function python_struct_to_native_type(pystruct_string::AbstractString)
    return python_struct_lower_to_tuple_type(pystruct_string, format_dict)
end

"""
    python_struct_to_standard_type(pystruct_string::AbstractString)

Use [`python_struct_to_type`](@ref) with the standard format dictionary.

*Private API*
"""
function python_struct_to_standard_type(pystruct_string::AbstractString)
    return python_struct_lower_to_tuple_type(pystruct_string, format_standard_dict)
end

"""
    python_struct_lower_to_tuple_type(pystruct_string::AbstractString, dict::AbstractDict)

Convert python struct string to a Tuple{...} type by encoding each character
or string as a component type.
"""
function python_struct_lower_to_tuple_type(pystruct_string::AbstractString, dict::AbstractDict)
    types = DataType[]
    num_buffer = IOBuffer()
    for c in pystruct_string
        if isdigit(c)
            write(num_buffer, c)
        else
            seekstart(num_buffer)
            if eof(num_buffer)
                n = 1
            else
                n = parse(Int, read(num_buffer, String))
            end
            truncate(num_buffer, 0)
            if n == 0
                push!(types, ZeroCount{dict[c]})
            else
                if c == 's'
                    push!(types, NTuple{n,UInt8})
                else
                    for i in 1:n
                        push!(types, dict[c])
                    end
                end
            end
        end
    end
    Tuple{types...}
end


function filter_tuple(t::Tuple)
    filter(t) do e
        !(e isa NullByte || e isa ZeroCount)
    end
end
filter_tuple(x) = x

function filter_tuple_type(T::Type{<: Tuple})
    t = filter(fieldtypes(T)) do F
        !(F == NullByte || F <: ZeroCount)
    end
    return Tuple{t...}
end
filter_tuple_type(T::Type) = T
