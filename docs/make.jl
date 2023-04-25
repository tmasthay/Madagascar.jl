using Documenter, Madagascar

makedocs(sitename="Madagascar julia wrapper",
         doctest=false, clean=true,
         authors="Mathias Louboutin",
         pages = Any[
             "Home" => "index.md",
         ])

deploydocs(repo="github.com/mloubout/Madagascar.jl", devbranch="main")
