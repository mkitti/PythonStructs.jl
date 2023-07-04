# Map Python struct characters to C types
const format_dict = Base.ImmutableDict(
    'x' => NullByte,
    'c' => Cchar,
    'b' => Cchar,
    'B' => Cuchar,
    '?' => Cchar, # C99, maybe Cuchar according to Julia
    'h' => Cshort,
    'H' => Cushort,
    'i' => Cint,
    'I' => Cuint,
    'l' => Clong,
    'L' => Culong,
    'q' => Clonglong,
    'Q' => Culonglong,
    'n' => Cssize_t,
    'N' => Csize_t,
    'e' => Float16,
    'f' => Cfloat,
    'd' => Cdouble,
    's' => StaticString{1},
    'p' => NTuple{1, Cchar}, # Pascal string, count length as bytes
    'P' => Ptr{Cvoid}
)

# Map Python struct characters to standard types
const format_standard_dict = Base.ImmutableDict(
    'x' => NullByte,
    'c' => Int8,
    'b' => Int8,
    'B' => UInt8,
    '?' => Int8, # C99, maybe Cuchar according to Julia
    'h' => Int16,
    'H' => UInt16,
    'i' => Int32,
    'I' => UInt32,
    'l' => Int32,
    'L' => UInt32,
    'q' => Int64,
    'Q' => UInt64,
    'n' => Cssize_t,
    'N' => Csize_t,
    'e' => Float16,
    'f' => Float32,
    'd' => Float64,
    's' => StaticString{1},
    'p' => NTuple{1, Int8}, # Pascal string, count length as bytes
    'P' => Ptr{Nothing}
)

# Map standard types to Python struct characters
const reverse_standard_dict = Base.ImmutableDict(
    NullByte => 'x',
    Int8 => 'b',
    UInt8 => 'B',
    Int16 => 'h',
    UInt16 => 'H',
    Int32 => 'l',
    UInt32 => 'L',
    Int64 => 'q',
    UInt64 => 'Q',
    Float16 => 'e',
    Float32 => 'f',
    Float64 => 'd',
    StaticString{1} => 's',
    Ptr{Cvoid} => 'P'
)
