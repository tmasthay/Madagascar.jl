using Madagascar

inp = Madagascar.input("in")
out = Madagascar.output("out")

n1 = Madagascar.histint(inp, "n1")
n2 = Madagascar.leftsize(inp, 1)

clip = Madagascar.getfloat("clip")

trace = Array{Float32}(undef, n1)

for i2 in 1:n2
    Madagascar.floatread(trace, n1, inp)
    clamp!(trace, -clip, clip)
    Madagascar.floatwrite(trace, n1, out)
end

