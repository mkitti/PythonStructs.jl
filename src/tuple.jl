"""
    python_struct_to_type(pystruct_string::AbstractString, dict::AbstractDict)

Convert a Python struct string to be a Julia `Tuple` type.

*Private API*
"""
function python_struct_to_type(pystruct_string::AbstractString, dict::AbstractDict)
    types = DataType[]
    skip = false
    for format_char in pystruct_string
        if format_char == '0'
            skip = true
            continue
        end
        if skip
            push!(types, ZeroCount{dict[format_char]})
            skip = false
            continue
        end
        push!(types, dict[format_char])
    end
    return Tuple{types...}
end

"""
    python_struct_to_native_type(pystruct_string::AbstractString)

Use [`python_struct_to_type`](@ref) with the native format dictionary.

*Private API*
"""
function python_struct_to_native_type(pystruct_string::AbstractString)
    return python_struct_to_type(pystruct_string, format_dict)
end

"""
    python_struct_to_standard_type(pystruct_string::AbstractString)

Use [`python_struct_to_type`](@ref) with the standard format dictionary.

*Private API*
"""
function python_struct_to_standard_type(pystruct_string::AbstractString)
    return python_struct_to_type(pystruct_string, format_standard_dict)
end

"""
    python_struct_lower(pythonstruct_string::AbstractString)

Convert a general Python struct string into a simpler form. Numbers are parsed
and are translated into repeated type characters. Zero count types are retained.

*Private API*
"""
function python_struct_lower(pystruct_string::AbstractString)
    output_buffer = IOBuffer()
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
                write(output_buffer, '0')
                write(output_buffer, c)
            else
                for i in 1:n
                    write(output_buffer, c)
                end
            end
        end
    end
    return String(take!(output_buffer))
end

function filter_tuple(t::Tuple)
    filter(t) do e
        !(e isa NullByte || e isa ZeroCount)
    end
end

function filter_tuple_type(T::Type{<: Tuple})
    t = filter(fieldtypes(T)) do F
        !(F == NullByte || F <: ZeroCount)
    end
    return Tuple{t...}
end
