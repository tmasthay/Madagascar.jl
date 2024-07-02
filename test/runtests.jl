#!/usr/bin/env julia
using Test

Base.append!(ARGS, ["int1=1", "float1=1e-99", "str1=ḉ", "bool1=n"])

using Madagascar

if "RSFROOT" in keys(ENV)
    println("UNIT TESTS: Using Madagascar built from source, RSFROOT=$(ENV["RSFROOT"])")
    include("runtests_from_source.jl")
else
    println("UNIT TESTS: Using precompiled Madagascar")
    include("runtests_precompiled.jl")
end