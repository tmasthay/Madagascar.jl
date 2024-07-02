"""
    Madagascar.jl

Julia interface to Madagascar

Built on the C API, the Julia API provides most lower level functions for
reading, writing and manipulating various types of RSF files. It also provides
higher level read and write functions, documented in `?rsf_read` and
`?rsf_write`.

The Julia API also provides searmless access to Madagascar programs. These can
be accessed as Julia functions. For example, see `?sfwindow`. These functions
can be piped to each other using Julia's currying (function composition)
operator `|>`. See examples below.

# Examples

## Piping to variable
```julia-repl
julia> data = sfspike(n1=2) |> x -> sfwindow(x; n1=1) |> rsf_read

julia> data
(Float32[1.0], [1], Float32[0.004], Float32[0.0], String["Time"], String["s"])
```

## Piping to disk
```julia-repl
julia> sfspike(n1=2) |> x -> sfwindow(x; n1=1) |> x -> rsf_write(x, "spike.rsf")
```
"""
module Madagascar


export rsf_read,
    rsf_write

if "RSFROOT" in keys(ENV)
    println("Using Madagascar built from source, RSFROOT=$(ENV["RSFROOT"])")
    include("Madagascar_from_source.jl")
else
    println("Using precompiled Madagascar")
    using Libdl
    include("Madagascar_precompiled.jl")
end

end