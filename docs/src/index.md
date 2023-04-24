# Madagascar.jl documentation

```@contents
```

# RSF I/O interface


## Writing RSF file

```@docs
rsf_write
```

## Reading RSF file

```@docs
rsf_read
```

# Madagascar executables API

```@autodocs
Modules = [Madagascar]
Filter = t -> startswith(string(t), "sf")
```