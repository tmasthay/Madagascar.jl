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

using Libdl

using Madagascar_jll
import Madagascar_jll: libdrsf

export rsf_read,
       rsf_write

# Lib paths
RSFROOT = Madagascar_jll.artifact_dir

# librsf


# Base type for rsf file
struct RSFFile
    tag::String
    rsf::Ptr{UInt8}
    temp::Bool
end

RSFFile(tag, rsf) = RSFFile(tag, rsf, false)

function __init__()
    src = Base.source_path()
    argv = src == nothing ? ["julia"] : [basename(src)]
    if isempty(ARGS)
        push!(argv, "-")
    else
        append!(argv,ARGS)
    end
    na = length(argv)
    @ccall libdrsf.sf_init(na::Int32, argv::Ptr{Ptr{UInt8}})::Cvoid
end

function input(tag::String; temp=false)
    if tag ≠ "in"
        if !isfile(tag)
            throw("SystemError: unable to read file $tag")
        end
    end
    rsf = @ccall libdrsf.sf_input(tag::Ptr{UInt8})::Ptr{UInt8}
    RSFFile(tag, rsf, temp)
end

function output(tag::String)
    rsf = @ccall libdrsf.sf_output(tag::Ptr{UInt8})::Ptr{UInt8}
    RSFFile(tag, rsf)
end

function gettype(file::RSFFile)
    out = @ccall libdrsf.sf_gettype(file.rsf::Ptr{UInt8})::Cuint
    return out + 1
end

function getform(file::RSFFile)
    out = @ccall libdrsf.sf_getform(file.rsf::Ptr{UInt8})::Cuint
    return out + 1
end

function esize(file::RSFFile)
    return @ccall libdrsf.sf_esize(file.rsf::Ptr{UInt8})::Csize_t
end

function setformat(file::RSFFile,format::String)
    @ccall libdrsf.sf_setformat(file.rsf::Ptr{UInt8}, format::Ptr{UInt8})::Cvoid
end

function histint(file::RSFFile,name::String)
    val = Cint[0]
    @ccall libdrsf.sf_histint(file.rsf::Ptr{UInt8}, name::Ptr{UInt8}, val::Ref{Cint})::Bool
    return convert(Int, val[])
end

function histfloat(file::RSFFile,name::String)
    val = Cfloat[0]
    @ccall libdrsf.sf_histfloat(file.rsf::Ptr{UInt8}, name::Ptr{UInt8}, val::Ref{Cfloat})::Bool
    return convert(Float32, val[])
end

function histstring(file::RSFFile,name::String)
    val = @ccall libdrsf.sf_histstring(file.rsf::Ptr{UInt8}, name::Ptr{UInt8})::Ptr{Cchar}
    if val == C_NULL
        return ""
    end
    return unsafe_string(val)
end

function getint(name::String, val::Integer)
    val = Cint[val]
    @ccall libdrsf.sf_getint(name::Ptr{UInt8}, val::Ref{Cint})::Bool
    return convert(Int, val[])
end

getint(name::String; val::Integer = 0) = getint(name, val)

function getfloat(name::String, val::Real)
    val = Cfloat[val]
    @ccall libdrsf.sf_getfloat(name::Ptr{UInt8}, val::Ref{Cfloat})::Bool
    return convert(Float32, val[])
end

getfloat(name::String; val::Real = 0) = getfloat(name, val)

function getstring(name::String, val::String)
    v = @ccall libdrsf.sf_getstring(name::Ptr{UInt8})::Ptr{Cchar}
    if v == C_NULL
        return val
    end
    return unsafe_string(v)
end

getstring(name::String; val::String = "") = getstring(name, val)

function getbool(name::String, val::Bool)
    val = Bool[val]
    @ccall libdrsf.sf_getbool(name::Ptr{UInt8}, val::Ref{Bool})::Bool
    return val[]
end

getbool(name::String; val::Bool = true) = getbool(name, val)

function leftsize(file::RSFFile,dim::Integer)
    dim::Cint = dim
    @ccall libdrsf.sf_leftsize(file.rsf::Ptr{UInt8},dim::Cint)::Culonglong
end

function ucharread(arr::Array{UInt8,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_ucharread(arr::Ptr{UInt8}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function charread(arr::Array{UInt8,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_charread(arr::Ptr{UInt8}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function intread(arr::Array{Int32,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_intread(arr::Ptr{Cint}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function floatread(arr::Array{Float32,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_floatread(arr::Ptr{Cfloat}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
    return nothing
end

function complexread(arr::Array{ComplexF32,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_complexread(arr::Ptr{ComplexF32}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function shortread(arr::Array{Int16,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_shortread(arr::Ptr{Cshort}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function ucharwrite(arr::Array{UInt8,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_ucharwrite(arr::Ptr{UInt8}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function charwrite(arr::Array{UInt8,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_charwrite(arr::Ptr{UInt8}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function intwrite(arr::Array{Int32,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_intwrite(arr::Ptr{Cint},size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function floatwrite(arr::Array{Float32,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_floatwrite(arr::Ptr{Cfloat}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
    return nothing
end

function complexwrite(arr::Array{ComplexF32,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_complexwrite(arr::Ptr{ComplexF32}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function shortwrite(arr::Array{Int16,1},size::Integer,file::RSFFile)
    size::Csize_t = size
    @ccall libdrsf.sf_shortwrite(arr::Ptr{Cshort}, size::Csize_t, file.rsf::Ptr{UInt8})::Cvoid
end

function putint(file::RSFFile,name::String,val::Integer)
    val::Cint = val
    @ccall libdrsf.sf_putint(file.rsf::Ptr{UInt8}, name::Ptr{UInt8}, val::Cint)::Cvoid
end

function putfloat(file::RSFFile,name::String,val::Real)
    val::Cfloat = val
    @ccall libdrsf.sf_putfloat(file.rsf::Ptr{UInt8}, name::Ptr{UInt8}, val::Cfloat)::Cvoid
end

function putstring(file::RSFFile,name::String,val::String)
    @ccall libdrsf.sf_putstring(file.rsf::Ptr{UInt8}, name::Ptr{UInt8}, val::Ptr{UInt8})::Cvoid
end

function close(file::RSFFile)
    @ccall libdrsf.sf_fileclose(file.rsf::Ptr{UInt8})::Cvoid
end

"""
    Madagascar.size(file::Madagascar.RSFFile) -> Tuple

The size of `file`, an Int array representing the length of each of its
dimensions.

# Examples

```julia-repl
julia> sfspike(;n1=2, n2=3) |> Madagascar.size
(2, 3)
```
"""
function size(file::RSFFile)
    size = leftsize(file, 0)
    dim = 1
    n = histint(file, string("n", dim))
    s = [n]
    size /= n
    dim += 1
    while size > 1
        n = histint(file, string("n", dim))
        push!(s, n)
        size /= n
        dim += 1
    end
    return Tuple(s)
end

"""
    rsf_read(file)

Reads RSF `file`, returning its contents and header. `file` may be file handle 
(`Madagascar.RSFFile`) or filename (`Madagascar.RSFFile.tag`). When called with `headers_only`
keyword argument set to `true`, does not read contents, only headers.

# Examples

## Reading file handle
```julia-repl
julia> sfspike(;n1=2, n2=3) |> x -> rsf_write(x, "spike.rsf")

julia> inp = Madagascar.input("spike.rsf")

julia> dat, n, d, o, l, u = rsf_read(inp)
(Float32[1.0 1.0 1.0; 1.0 1.0 1.0], [2, 3], Float32[0.004, 0.1], Float32[0.0, 0.0], String["Time", "Distance"], String["s", "km"])
```

## Reading file name
```julia-repl
julia> rsf_read("spike.rsf")
(Float32[1.0 1.0 1.0; 1.0 1.0 1.0], [2, 3], Float32[0.004, 0.1], Float32[0.0, 0.0], String["Time", "Distance"], String["s", "km"])
```
"""
function rsf_read(file::RSFFile; headers_only::Bool=false)
    types = [
         UInt8, # SF_UCHAR
         UInt8, # SF_CHAR
         Int32, # SF_INT
         Float32, # SF_FLOAT
         ComplexF32, # SF_COMPLEX
         Int16, # SF_SHORT
         Float64, # SF_DOUBLE
         Clong, # SF_LONG (UNIX: Int, Windows: Int32)
        ]
    n = Int[i for i in size(file)]
    sz = prod(n)

    d = Float32[]
    o = Float32[]
    l = String[]
    u = String[]
    for i in 1:length(n)
        append!(d, [histfloat(file, "d"*string(i))])
        append!(o, [histfloat(file, "o"*string(i))])
        append!(l, [histstring(file, "label"*string(i))])
        append!(u, [histstring(file, "unit"*string(i))])
    end

    if headers_only
        return n, d, o, l, u
    end

    itypes = gettype(file)
    data = zeros(types[itypes], sz)
    if itypes == 1
        ucharread(data, sz, file)
    elseif itypes == 2
        charread(data, sz, file)
    elseif itypes == 3
        intread(data, sz, file)
    elseif itypes == 4
        floatread(data, sz, file)
    elseif itypes == 5
        complexread(data, sz, file)
    elseif itypes == 6
        shortread(data, sz, file)
    else
        throw("Cannot read long, double")
    end

    data = reshape(data, n...)

    if file.temp
        delete_rsf(file.tag)
    end
    return data, n, d, o, l, u
end

rsf_read(name::String; headers_only::Bool=false) =
    rsf_read(input(name); headers_only=headers_only)

function rsf_read(my_stdin::NTuple{2, Base.PipeEndpoint}; headers_only::Bool=false)
    rin, win = my_stdin
    flush(win)
    old_stdin = stdin
    redirect_stdin(rin)
    data = rsf_read("in"; headers_only=headers_only)
    redirect_stdin(old_stdin)
    return data
end

"""
    rsf_write(file, dat, n, d, o, label, unit)

Write RSF `file`. `file` may be file handle (`Madagascar.RSFFile`), filename
(`Madagascar.RSFFile.tag`) or absent:

    rsf_write(dat, n, d, o, label, unit) -> temp_tag::String

In this case, the file is temporary with name `temp_tag`.

In all methods, `n`, `d`, `o`, `label`, and `unit` are optional. If given, they
should be of type `AbstractArray`.

!!! warning "Writing to file handles"

    Do *not* supply the file as an `Madagascar.RSFFile` type unless you know exactly what
    you are doing. Because of how Madagascar is set up, calling `Madagascar.output`
    automatically sets the filetype to whatever was read in the previous
    `Madagascar.input("in")` call. If this function has not yet been called, it
    defaults to `float`. Therefore, it is *impossible* to create a `complex`
    file immediately after reading a `float`-type file. We overcome this
    limitation with other `rsf_write` methods by writing dummy files to dummy
    pipes to "trick" Madagascar into switching file types.

    In addition, do *not* try to write to a file handle which has already been
    written to with `rsf_write`, as `rsf_write` closes the file. Doing so will
    cause a segfault.

# Examples

## Write file by name
```julia-repl
julia> rsf_write("spike.rsf", [1., 2.])

julia> rsf_read("spike.rsf")
(Float32[1.0, 2.0], [2], Float32[1.0], Float32[0.0], String[""], String[""])
```

## Write to temporary file
```julia-repl
julia> rsf_write([1. im]) |> sfreal |> rsf_read
(Complex{Float32}[1.0+0.0im 0.0+1.0im], [1, 2], Float32[1.0, 1.0], Float32[0.0, 0.0], String["", ""], String["", ""])
```

## Write from pipe
```julia-repl
julia> sfspike(;n1=1) |> x -> rsf_write(x, "spike.rsf")

julia> rsf_read("spike.rsf")
(Float32[1.0, 2.0], [2], Float32[1.0], Float32[0.0], String[""], String[""])
```

## Writing file handle (avoid this!)
```julia-repl
julia> out = Madagascar.output("test.rsf")
Madagascar.File("test.rsf", Ptr{UInt8} @0x0000000003847880, false)

julia> rsf_write(out, [1., 2]) # rsf_write(out, [im, 2]) will not work due to warning

julia> rsf_read(out.tag)
(Float32[1.0, 2.0], [2], Float32[1.0], Float32[0.0], String[""], String[""])
```
"""
function rsf_write(file::RSFFile, dat::AbstractArray, n=nothing, d=nothing,
                   o=nothing, l=nothing, u=nothing)
    if n == nothing
        n = Base.size(dat)
    end
    dim = length(n)
    d = d == nothing ? [1 for i in 1:dim] : d
    o = o == nothing ? [0 for i in 1:dim] : o
    l = l == nothing ? ["" for i in 1:dim] : l
    u = u == nothing ? ["" for i in 1:dim] : u
    for i in 1:dim
        typeof(n[i]) <: Integer || throw("All n must be `Integer`")
        typeof(d[i]) <: Real    || throw("All d must be `Real`")
        typeof(o[i]) <: Real    || throw("All o must be `Real`")
        typeof(l[i]) <: String  || throw("All l must be `String`")
        typeof(u[i]) <: String  || throw("All u must be `String`")
        putint(file, "n$i", n[i])
        putfloat(file, "d$i", d[i])
        putfloat(file, "o$i", o[i])
        putstring(file, "label$i", l[i])
        putstring(file, "unit$i", u[i])
    end

    if eltype(dat) <: UInt8
        charwrite(Array{UInt8}(vec(dat)), leftsize(file, 0), file)
    elseif eltype(dat) <: AbstractFloat
        floatwrite(Array{Float32}(vec(dat)), leftsize(file, 0), file)
    elseif eltype(dat) <: Complex
        complexwrite(Array{ComplexF32}(vec(dat)), leftsize(file, 0), file)
    elseif eltype(dat) <: Int16
        shortwrite(Array{Int16}(vec(dat)), leftsize(file, 0), file)
    elseif eltype(dat) <: Integer
        intwrite(Array{Int32}(vec(dat)), leftsize(file, 0), file)
    else
        throw("Cannot write long, double")
    end
    close(file)
end

function rsf_write(name::String, dat::AbstractArray, n=nothing, d=nothing,
                   o=nothing, l=nothing, u=nothing)
    # Madagascar's output function inherits the type of the previous input.
    # Therefore, in order to have the correct output type, one must create a
    # dummy input of the correct type.
    old_stdin = stdin
    (rin, win) = redirect_stdin()
    Madagascar_jll.sfspike() do spike
        if eltype(dat) <: Int16
            pipe = pipeline(`$spike n1=1`, `$(Madagascar_jll.sfdd()) type=short`)
        elseif eltype(dat) <: Complex
            pipe = pipeline(`$spike n1=1`, `$(Madagascar_jll.sfrtoc()) out=stdout`)
        elseif eltype(dat) <: Integer
            pipe = pipeline(`$spike n1=1`, `$(Madagascar_jll.sfdd()) type=int`)
        else
            pipe = `$spike n1=1 out=stdout`
        end
        Base.wait(run(pipeline(pipe, stdout=win), wait=false))
    end
    redirect_stdin(old_stdin)
    rsf_read((rin, win))

    rsf_write(output(name), dat, n, d, o, l, u)
end

rsf_write(file::Union{String, RSFFile}, dat::AbstractArray; n=nothing, d=nothing,
          o=nothing, l=nothing, u=nothing) = rsf_write(file, dat, n, d, o, l, u)

function rsf_write(dat::AbstractArray, n, d, o, l, u)
    tag = temporary_rsf()
    rsf_write(tag, dat, n, d, o, l, u)
    return tag
end

rsf_write(dat::AbstractArray; n=nothing, d=nothing, o=nothing, l=nothing,
          u=nothing) = rsf_write(dat, n, d, o, l, u)

function rsf_write(file::RSFFile, tag::String)
    fname = String[file.tag, tag]
    Madagascar_jll.sfmv() do sfmv
        run(`$sfmv $fname`)
    end
end

function rsf_write(tag::String, file::RSFFile)
    return rsf_write(file, tag)
end

function process_args(;kwargs...)
    args = String[]
    for (key, val) in kwargs
        if typeof(val) <: Tuple
            val = join(["$v" for v in val], ",")
        elseif typeof(val) <: Bool
            val = val ? "y" : "n"
        end
        push!(args, "$key=$val")
    end
    return args
end

function delete_rsf(tag::String)
    fname = String[tag]
    return run(`$(Madagascar_jll.sfrm()) $fname`, wait=false)
end

function temporary_rsf()
    if haskey(ENV, "TMPDATAPATH")
        return joinpath(ENV["TMPDATAPATH"], tempname() * ".rsf")
    elseif haskey(ENV, "DATAPATH")
        return joinpath(ENV["DATAPATH"], tempname() * ".rsf")
    else
        return tempname() * ".rsf"
    end
end

progs = filter(x -> startswith(x, "sf"),
                readdir(joinpath(RSFROOT, "bin")))
for (F, S) = [ (Symbol(p), p) for p in progs ]
    @eval export $F
    @eval begin
        progname = $S
        manfile = joinpath(@__DIR__, "../docs", "libdoc", progname*".1")
        if isfile(manfile)
            old_stdout = stdout
            (rout, wout) = redirect_stdout()
            run(pipeline(`man $manfile`, stdout=wout, stdin=devnull,
                            stderr=devnull))
            Base.close(wout)
            manpage = String(readavailable(rout))
            manpage = replace(manpage, "\n" => "\n\t")
            manpage = "\n# RSF Documentation\n"*manpage
            Base.close(rout)
            redirect_stdout(old_stdout)
        else
            manpage = ""
        end

"""
    $progname(input; kwargs...) -> Madagascar.RSFFile

Runs RSF program `$progname` on the data provided by `input`. This may be an
`Madagascar.RSFFile` or an array (and optionally, positional and keyword arguments
n, d, o, l, u). If the program requires no input, it may be absent.

It is also possible to pass keyword arguments to the `$progname`. See `?Madagascar`
for examples.

$manpage"""
        function ($F)(;kwargs...)
            out_tag = temporary_rsf()
            args = process_args(;kwargs...)
            Madagascar_jll.$F() do exe
                pipe = `$exe $args`
                run(pipeline(pipe, stdout=out_tag))
            end
            return input(out_tag; temp=true)
        end
    end
    
    @eval function ($F)(in_file::RSFFile; kwargs...)
        out_tag = temporary_rsf()
        args = process_args(;kwargs...)
        Madagascar_jll.$F() do exe
            pipe = `$exe $args`
            run(pipeline(pipe, stdin=in_file.tag, stdout=out_tag))
        end
        if in_file.temp
            delete_rsf(in_file.tag)
        end
        return input(out_tag; temp=true)
    end
    
    @eval function ($F)(dat::AbstractArray, n=nothing, d=nothing, o=nothing,
        l=nothing, u=nothing; kwargs...)
        out = rsf_write(dat, n, d, o, l, u) |> x -> $F(x; kwargs...)
        println("write done")
        return out
    end
    
    @eval function ($F)(tag::String; kwargs...)
        return $F(input(tag); kwargs...)
    end
end

end
