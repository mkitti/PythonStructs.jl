using PythonStruct
using Documenter

DocMeta.setdocmeta!(PythonStruct, :DocTestSetup, :(using PythonStruct); recursive=true)

makedocs(;
    modules=[PythonStruct],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/mkitti/PythonStruct.jl/blob/{commit}{path}#{line}",
    sitename="PythonStruct.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/PythonStruct.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/PythonStruct.jl",
    devbranch="main",
)
