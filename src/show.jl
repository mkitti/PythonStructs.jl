function show_modifier(io::IO, M::Type{<: Modifier})
    M == NativeModifier ? print(io, "NativeModifier") :
    M == NativeStandardModifier ? print(io, "NativeStandardModifier") :
    M == LittleEndianModifier ? print(io, "LittleEndianModifier") :
    M == BigEndianModifier ? print(io, "BigEndianModifier") :
    print(io, M)
end

#Base.show(io::IO, ::MIME"text/plain", M::Type{<: Modifier}) = show_modifier(io, M)

function show_python_struct(io::IO, PS::Type{<: PythonStruct})
    print(io, "pystruct\"")
    print(io, string(PS))
    print(io, "\"")
end
function show_python_struct(io::IO, ps::PythonStruct)
    show_python_struct(io, typeof(ps))
    print(io, "(")
    print(io, filter_tuple(ps.s))
    print(io, ")")
end

Base.show(io::IO, ::MIME"text/plain", PS::Type{<: PythonStruct}) = show_python_struct(io, PS)
Base.show(io::IO, ::MIME"text/plain", ps::PythonStruct) = show_python_struct(io, ps)
