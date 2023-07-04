using PythonStructs
using StaticStrings
using Test

@testset "PythonStructs.jl" begin
    if Sys.iswindows()
        @test calcsize(pystruct"@lhl") == 12
        @test calcsize(pystruct"@llh") == 10
        @test calcsize(pystruct"@llh0l") == 12
        @test pack(pystruct"qh6xq", 1, 2, 3) == pack(pystruct"@qhq", 1, 2, 3)
        @test pack(pystruct"@llh", 1, 2, 3) == pack(pystruct"<llh", 1, 2, 3)
        @test pack(pystruct"@llh0l", 1, 2, 3) == pack(pystruct"<llh2x", 1, 2, 3)
    else
        @test calcsize(pystruct"@lhl") == 24
        @test calcsize(pystruct"@llh") == 18
        @test calcsize(pystruct"@llh0l") == 24
        @test pack(pystruct"qh6xq", 1, 2, 3) == pack(pystruct"@lhl", 1, 2, 3)
        @test pack(pystruct"@llh", 1, 2, 3) == pack(pystruct"<qqh", 1, 2, 3)
        @test pack(pystruct"@llh0l", 1, 2, 3) == pack(pystruct"<qqh6x", 1, 2, 3)
    end
    @test pack(pystruct">bhl", 1, 2, 3) == [0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x03]
    @test calcsize(pystruct">bhl") == 7
    @test_throws InexactError pack(pystruct">h", 99999)
    @test pack(pystruct"@ccc", '1', '2', '3') == UInt8['1', '2', '3']
    @test pack(pystruct"@3s", "123") == UInt8['1', '2', '3']
    
    record = UInt8['r','a','y','m','o','n','d',' ',' ',' ', 0x32,0x12,0x08,0x01,0x08]
    # name, serialnum, school, gradelevel = unpack(pystruct"<10sHHb", record)

    @test pack(pystruct"@ci", UInt8('#'), 0x12131415) == UInt8['#',0x00,0x00,0x00,0x15,0x14,0x13,0x12]
    @test calcsize(pystruct"@ci") == 8
    @test calcsize(pystruct"@ic") == 5

    # 64-bit dependence?
    @test calcsize(pystruct"<qh6xq") == 24
    @test calcsize(pystruct"<qqh6x") == 24

    # Unpacking
    ps = pystruct"@llh0l"
    x = (1,2,3)
    @test pack(ps, x) |> unpack(ps) == (1,2,3)

    # Strings
    @test pystruct"5sc"("Hello",5)  |> pack == UInt8[0x48,0x65,0x6c,0x6c,0x6f,0x05]
    @test UInt8[0x48,0x65,0x6c,0x6c,0x6f,0x05] |> unpack("5sc") === (static"Hello", Int8(5))
    ps = pystruct"q5sq"(6,"Hello",9)
    @test pack(ps) |> unpack(typeof(ps)) == (6, "Hello", 9)
end
