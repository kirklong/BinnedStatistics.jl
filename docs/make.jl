using BinnedStatistics
using Documenter

DocMeta.setdocmeta!(BinnedStatistics, :DocTestSetup, :(using BinnedStatistics); recursive=true)

makedocs(;
    modules=[BinnedStatistics],
    authors="Kirk Long",
    repo="https://github.com/kirklong/BinnedStatistics.jl/blob/{commit}{path}#{line}",
    sitename="BinnedStatistics.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kirklong.github.io/BinnedStatistics.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kirklong/BinnedStatistics.jl",
    devbranch="main",
)
