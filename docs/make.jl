using PythonStructs
using Documenter

DocMeta.setdocmeta!(PythonStructs, :DocTestSetup, :(using PythonStructs); recursive=true)

makedocs(;
    modules=[PythonStructs],
    authors="Mark Kittisopikul <markkitt@gmail.com> and contributors",
    repo="https://github.com/mkitti/PythonStructs.jl/blob/{commit}{path}#{line}",
    sitename="PythonStructs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mkitti.github.io/PythonStructs.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mkitti/PythonStructs.jl",
    devbranch="main",
)
