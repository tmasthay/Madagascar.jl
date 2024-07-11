const FORCE_SOURCE = get(ENV, "RSF_FORCE_JULIA_SOURCE", "0") == "1"
const use_precompiled = !FORCE_SOURCE && Sys.islinux()

if use_precompiled
    include("src/Madagascar_precompiled.jl")
else
    include("src/Madagascar_source.jl")