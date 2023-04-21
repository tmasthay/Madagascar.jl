#!/usr/bin/env julia
using Test

Base.append!(ARGS, ["int1=1", "float1=1e-99", "str1=ḉ", "bool1=n"])

using Madagascar

println("RSFROOT")
@test Madagascar.RSFROOT ≠ nothing

println("getfloat")
@test Madagascar.getfloat("float1") ≈ 0
@test Madagascar.getfloat("float2", 2) ≈  2
@test Madagascar.getfloat("float3", val=3) ≈ 3
@test Madagascar.getfloat("float4") ≈ 0

println("getint")
@test Madagascar.getint("int1") == 1
@test Madagascar.getint("int2", 2) == 2
@test Madagascar.getint("int3", val=3) == 3
@test Madagascar.getint("int4") == 0

println("getstring")
@test Madagascar.getstring("str1") == "ḉ"
@test Madagascar.getstring("str2", "2") == "2"
@test Madagascar.getstring("str3", val="3") == "3"
@test Madagascar.getstring("str4") == ""

println("getbool")
@test Madagascar.getbool("bool1") == false
@test Madagascar.getbool("bool2", false) == false
@test Madagascar.getbool("bool3", val=false) == false
@test Madagascar.getbool("bool4") == true

println("input uchar")
run(pipeline(`echo "a bA?"`, stdout="$(@__DIR__)/test_inp_uchar.txt"))
run(pipeline(`echo n1=5 data_format=ascii_uchar in=$(@__DIR__)/test_inp_uchar.txt
              out=stdout`,
             stdout="$(@__DIR__)/test_inp_uchar.rsf"))
inp = Madagascar.input("$(@__DIR__)/test_inp_uchar.rsf")
@test Madagascar.size(inp) == (5,)
@test Madagascar.gettype(inp) == 1
@test Madagascar.getform(inp) == 1
dat, = rsf_read(inp)
@test dat == UInt8[97, 32, 98, 65, 63]
@test Madagascar.histint(inp, "n1") == 5
@test Madagascar.histfloat(inp, "d1") ≈ 0
@test Madagascar.histfloat(inp, "o1") ≈ 0
@test Madagascar.histstring(inp, "label1") == ""
@test Madagascar.histstring(inp, "unit1") == ""
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_inp_uchar.rsf`)

println("output uchar")
out = Madagascar.output("$(@__DIR__)/test_out_uchar.rsf")
Madagascar.setformat(out, "uchar")
@test Madagascar.gettype(out) == 1
Madagascar.putint(out, "n1", 1)
Madagascar.putint(out, "n2", 2)
Madagascar.putfloat(out, "d1", 3)
Madagascar.putfloat(out, "d2", 4)
Madagascar.putfloat(out, "o1", 5)
Madagascar.putfloat(out, "o2", 6)
Madagascar.putstring(out, "label1", "a")
Madagascar.putstring(out, "label2", "é")
Madagascar.putstring(out, "unit1", "普通话")
Madagascar.putstring(out, "unit2", "µm")

Madagascar.ucharwrite(UInt8[1; 2], Madagascar.leftsize(out, 0), out)

@test Madagascar.histint(out, "n1") == 1
@test Madagascar.histint(out, "n2") == 2
@test Madagascar.histfloat(out, "d1") ≈ 3
@test Madagascar.histfloat(out, "d2") ≈ 4
@test Madagascar.histfloat(out, "o1") ≈ 5
@test Madagascar.histfloat(out, "o2") ≈ 6
@test Madagascar.histstring(out, "label1") == "a"
@test Madagascar.histstring(out, "label2") == "é"
@test Madagascar.histstring(out, "unit1") == "普通话"
@test Madagascar.histstring(out, "unit2") == "µm"
Madagascar.close(out)

old_stdout = stdout
(rout, wout) = redirect_stdout()
run(pipeline(`$(Madagascar.RSF_jll.sfdisfil())`, stdin="$(@__DIR__)/test_out_uchar.rsf", stdout=wout))
data = String(readavailable(rout))
close(rout)
redirect_stdout(old_stdout)
@test data == "   0:    1    2 \n"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_out_uchar.rsf`)

println("input char")
run(pipeline(`echo "a bA?"`, stdout="$(@__DIR__)/test_inp_char.txt"))
run(pipeline(`echo n1=5 data_format=ascii_char in=$(@__DIR__)/test_inp_char.txt out=stdout`,
             stdout="$(@__DIR__)/test_inp_char.rsf"))
inp = Madagascar.input("$(@__DIR__)/test_inp_char.rsf")
@test Madagascar.size(inp) == (5,)
@test Madagascar.gettype(inp) == 2
dat, = rsf_read(inp)
@test dat == UInt8[97, 32, 98, 65, 63]
@test Madagascar.histint(inp, "n1") == 5
@test Madagascar.histfloat(inp, "d1") ≈ 0
@test Madagascar.histfloat(inp, "o1") ≈ 0
@test Madagascar.histstring(inp, "label1") == ""
@test Madagascar.histstring(inp, "unit1") == ""
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_inp_char.rsf`)

println("output char")
out = Madagascar.output("$(@__DIR__)/test_out_char.rsf")
Madagascar.setformat(out, "char")
@test Madagascar.gettype(out) == 2
Madagascar.putint(out, "n1", 1)
Madagascar.putint(out, "n2", 2)
Madagascar.putfloat(out, "d1", 3)
Madagascar.putfloat(out, "d2", 4)
Madagascar.putfloat(out, "o1", 5)
Madagascar.putfloat(out, "o2", 6)
Madagascar.putstring(out, "label1", "a")
Madagascar.putstring(out, "label2", "é")
Madagascar.putstring(out, "unit1", "普通话")
Madagascar.putstring(out, "unit2", "µm")

Madagascar.charwrite(UInt8[1; 2], Madagascar.leftsize(out, 0), out)

@test Madagascar.histint(out, "n1") == 1
@test Madagascar.histint(out, "n2") == 2
@test Madagascar.histfloat(out, "d1") ≈ 3
@test Madagascar.histfloat(out, "d2") ≈ 4
@test Madagascar.histfloat(out, "o1") ≈ 5
@test Madagascar.histfloat(out, "o2") ≈ 6
@test Madagascar.histstring(out, "label1") == "a"
@test Madagascar.histstring(out, "label2") == "é"
@test Madagascar.histstring(out, "unit1") == "普通话"
@test Madagascar.histstring(out, "unit2") == "µm"
Madagascar.close(out)

old_stdout = stdout
(rout, wout) = redirect_stdout()
run(pipeline(`$(Madagascar.RSF_jll.sfdisfil())`, stdin="$(@__DIR__)/test_out_char.rsf", stdout=wout))
data = String(readavailable(rout))
close(rout)
redirect_stdout(old_stdout)
@test data == "   0:    1    2 \n"
run(`$(Madagascar.RSF_jll.sfrm()) test_out_char.rsf`)

println("input int")
run(pipeline(pipeline(`$(Madagascar.RSF_jll.sfspike()) n1=2 k1=1,2,2
                               n2=3 k2=1,2,3
                               nsp=3 mag=1,4,2`,
                      `$(Madagascar.RSF_jll.sfdd())  type=int`),
             stdout="$(@__DIR__)/test_inp_int.rsf"))
inp = Madagascar.input("test_inp_int.rsf")
@test Madagascar.size(inp) == (2, 3)
@test Madagascar.gettype(inp) == 3
@test Madagascar.getform(inp) in [2, 3]
@test Madagascar.esize(inp) == 4
dat, = rsf_read(inp)
@test dat == Int32[1 0 0; 0 4 2]
@test Madagascar.histint(inp, "n1") == 2
@test Madagascar.histint(inp, "n2") == 3
@test Madagascar.histfloat(inp, "d1") ≈ 0.004
@test Madagascar.histfloat(inp, "d2") ≈ 0.1
@test Madagascar.histfloat(inp, "o1") ≈ 0
@test Madagascar.histfloat(inp, "o2") ≈ 0
@test Madagascar.histstring(inp, "label1") == "Time"
@test Madagascar.histstring(inp, "label2") == "Distance"
@test Madagascar.histstring(inp, "unit1") == "s"
@test Madagascar.histstring(inp, "unit2") == "km"
run(`$(Madagascar.RSF_jll.sfrm()) test_inp_int.rsf`)

println("output int")
out = Madagascar.output("$(@__DIR__)/test_out_int.rsf")
Madagascar.setformat(out, "int")
@test Madagascar.gettype(out) == 3
Madagascar.putint(out, "n1", 1)
Madagascar.putint(out, "n2", 2)
Madagascar.putfloat(out, "d1", 3)
Madagascar.putfloat(out, "d2", 4)
Madagascar.putfloat(out, "o1", 5)
Madagascar.putfloat(out, "o2", 6)
Madagascar.putstring(out, "label1", "a")
Madagascar.putstring(out, "label2", "é")
Madagascar.putstring(out, "unit1", "普通话")
Madagascar.putstring(out, "unit2", "µm")

Madagascar.intwrite(Int32[1; 2], Int32[Madagascar.leftsize(out, 0)][], out)

@test Madagascar.histint(out, "n1") == 1
@test Madagascar.histint(out, "n2") == 2
@test Madagascar.histfloat(out, "d1") ≈ 3
@test Madagascar.histfloat(out, "d2") ≈ 4
@test Madagascar.histfloat(out, "o1") ≈ 5
@test Madagascar.histfloat(out, "o2") ≈ 6
@test Madagascar.histstring(out, "label1") == "a"
@test Madagascar.histstring(out, "label2") == "é"
@test Madagascar.histstring(out, "unit1") == "普通话"
@test Madagascar.histstring(out, "unit2") == "µm"
Madagascar.close(out)

old_stdout = stdout
(rout, wout) = redirect_stdout()
run(pipeline(`$(Madagascar.RSF_jll.sfdisfil())`, stdin="$(@__DIR__)/test_out_int.rsf", stdout=wout))
data = String(readavailable(rout))
close(rout)
redirect_stdout(old_stdout)
@test data == "   0:    1    2 \n"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_out_int.rsf`)


println("input float")
run(pipeline(`$(Madagascar.RSF_jll.sfspike()) n1=2 k1=1,2,2
                      n2=3 k2=1,2,3
                      nsp=3 mag=1,4,2 out=stdout`,
             stdout="$(@__DIR__)/test_inp_float.rsf"))
inp = Madagascar.input("$(@__DIR__)/test_inp_float.rsf")
@test Madagascar.size(inp) == (2, 3)
@test Madagascar.gettype(inp) == 4
dat, = rsf_read(inp)
@test dat == Float32[1 0 0; 0 4 2]

@test Madagascar.histint(inp, "n1") == 2
@test Madagascar.histint(inp, "n2") == 3
@test Madagascar.histfloat(inp, "d1") ≈ 0.004
@test Madagascar.histfloat(inp, "d2") ≈ 0.1
@test Madagascar.histfloat(inp, "o1") ≈ 0
@test Madagascar.histfloat(inp, "o2") ≈ 0
@test Madagascar.histstring(inp, "label1") == "Time"
@test Madagascar.histstring(inp, "label2") == "Distance"
@test Madagascar.histstring(inp, "unit1") == "s"
@test Madagascar.histstring(inp, "unit2") == "km"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_inp_float.rsf`)

println("output float")
out = Madagascar.output("$(@__DIR__)/test_out_float.rsf")
Madagascar.putint(out, "n1", 1)
Madagascar.putint(out, "n2", 2)
Madagascar.putfloat(out, "d1", 3)
Madagascar.putfloat(out, "d2", 4)
Madagascar.putfloat(out, "o1", 5)
Madagascar.putfloat(out, "o2", 6)
Madagascar.putstring(out, "label1", "a")
Madagascar.putstring(out, "label2", "é")
Madagascar.putstring(out, "unit1", "普通话")
Madagascar.putstring(out, "unit2", "µm")

Madagascar.floatwrite(Float32[1.5; 2.5], Int32[Madagascar.leftsize(out, 0)][], out)

@test Madagascar.histint(out, "n1") == 1
@test Madagascar.histint(out, "n2") == 2
@test Madagascar.histfloat(out, "d1") ≈ 3
@test Madagascar.histfloat(out, "d2") ≈ 4
@test Madagascar.histfloat(out, "o1") ≈ 5
@test Madagascar.histfloat(out, "o2") ≈ 6
@test Madagascar.histstring(out, "label1") == "a"
@test Madagascar.histstring(out, "label2") == "é"
@test Madagascar.histstring(out, "unit1") == "普通话"
@test Madagascar.histstring(out, "unit2") == "µm"
Madagascar.close(out)

old_stdout = stdout
(rout, wout) = redirect_stdout()
run(pipeline(`$(Madagascar.RSF_jll.sfdisfil())`, stdin="$(@__DIR__)/test_out_float.rsf", stdout=wout))
data = String(readavailable(rout))
close(rout)
redirect_stdout(old_stdout)
@test data == "   0:           1.5          2.5\n"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_out_float.rsf`)

println("input complex")
run(pipeline(pipeline(`$(Madagascar.RSF_jll.sfspike()) n1=2 k1=1,2,2
                               n2=3 k2=1,2,3
                               nsp=3 mag=1,4,2`,
                      `$(Madagascar.RSF_jll.sfrtoc())`,
                      `$(Madagascar.RSF_jll.sfmath()) output='input + I' out=stdout`),
    stdout="$(@__DIR__)/test_inp_complex.rsf"))
inp = Madagascar.input("$(@__DIR__)/test_inp_complex.rsf")
@test Madagascar.size(inp) == (2, 3)
@test Madagascar.gettype(inp) == 5
dat, = rsf_read(inp)
@test dat == ComplexF32[1+im im im; im 4+im 2+im]

@test Madagascar.histint(inp, "n1") == 2
@test Madagascar.histint(inp, "n2") == 3
@test Madagascar.histfloat(inp, "d1") ≈ 0.004
@test Madagascar.histfloat(inp, "d2") ≈ 0.1
@test Madagascar.histfloat(inp, "o1") ≈ 0
@test Madagascar.histfloat(inp, "o2") ≈ 0
@test Madagascar.histstring(inp, "label1") == "Time"
@test Madagascar.histstring(inp, "label2") == "Distance"
@test Madagascar.histstring(inp, "unit1") == "s"
@test Madagascar.histstring(inp, "unit2") == "km"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_inp_complex.rsf`)

println("output complex")
out = Madagascar.output("$(@__DIR__)/test_out_complex.rsf")
Madagascar.setformat(out, "complex")
@test Madagascar.gettype(out) == 5
Madagascar.putint(out, "n1", 1)
Madagascar.putint(out, "n2", 2)
Madagascar.putfloat(out, "d1", 3)
Madagascar.putfloat(out, "d2", 4)
Madagascar.putfloat(out, "o1", 5)
Madagascar.putfloat(out, "o2", 6)
Madagascar.putstring(out, "label1", "a")
Madagascar.putstring(out, "label2", "é")
Madagascar.putstring(out, "unit1", "普通话")
Madagascar.putstring(out, "unit2", "µm")

Madagascar.complexwrite(ComplexF32[0.5+im; 2+im], Int32[Madagascar.leftsize(out, 0)][], out)

@test Madagascar.histint(out, "n1") == 1
@test Madagascar.histint(out, "n2") == 2
@test Madagascar.histfloat(out, "d1") ≈ 3
@test Madagascar.histfloat(out, "d2") ≈ 4
@test Madagascar.histfloat(out, "o1") ≈ 5
@test Madagascar.histfloat(out, "o2") ≈ 6
@test Madagascar.histstring(out, "label1") == "a"
@test Madagascar.histstring(out, "label2") == "é"
@test Madagascar.histstring(out, "unit1") == "普通话"
@test Madagascar.histstring(out, "unit2") == "µm"
Madagascar.close(out)

old_stdout = stdout
(rout, wout) = redirect_stdout()
run(pipeline(`$(Madagascar.RSF_jll.sfdisfil())`, stdin="$(@__DIR__)/test_out_complex.rsf", stdout=wout))
data = String(readavailable(rout))
close(rout)
redirect_stdout(old_stdout)
@test data == "   0:        0.5,         1i         2,         1i\n"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_out_complex.rsf`)

println("input short")
run(pipeline(pipeline(`$(Madagascar.RSF_jll.sfspike()) n1=2 k1=1,2,2
                               n2=3 k2=1,2,3
                               nsp=3 mag=1,4,2`,
                      `$(Madagascar.RSF_jll.sfdd())  type=short out=stdout`),
    stdout="$(@__DIR__)/test_inp_short.rsf"))
inp = Madagascar.input("$(@__DIR__)/test_inp_short.rsf")
@test Madagascar.size(inp) == (2, 3)
@test Madagascar.gettype(inp) == 6
dat, = rsf_read(inp)
@test dat == Int16[1 0 0; 0 4 2]

@test Madagascar.histint(inp, "n1") == 2
@test Madagascar.histint(inp, "n2") == 3
@test Madagascar.histfloat(inp, "d1") ≈ 0.004
@test Madagascar.histfloat(inp, "d2") ≈ 0.1
@test Madagascar.histfloat(inp, "o1") ≈ 0
@test Madagascar.histfloat(inp, "o2") ≈ 0
@test Madagascar.histstring(inp, "label1") == "Time"
@test Madagascar.histstring(inp, "label2") == "Distance"
@test Madagascar.histstring(inp, "unit1") == "s"
@test Madagascar.histstring(inp, "unit2") == "km"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_inp_short.rsf`)

println("output short")
out = Madagascar.output("$(@__DIR__)/test_out_short.rsf")
Madagascar.setformat(out, "short")
@test Madagascar.gettype(out) == 6
Madagascar.putint(out, "n1", 1)
Madagascar.putint(out, "n2", 2)
Madagascar.putfloat(out, "d1", 3)
Madagascar.putfloat(out, "d2", 4)
Madagascar.putfloat(out, "o1", 5)
Madagascar.putfloat(out, "o2", 6)
Madagascar.putstring(out, "label1", "a")
Madagascar.putstring(out, "label2", "é")
Madagascar.putstring(out, "unit1", "普通话")
Madagascar.putstring(out, "unit2", "µm")

Madagascar.shortwrite(Int16[5; 2], Int32[Madagascar.leftsize(out, 0)][], out)

@test Madagascar.histint(out, "n1") == 1
@test Madagascar.histint(out, "n2") == 2
@test Madagascar.histfloat(out, "d1") ≈ 3
@test Madagascar.histfloat(out, "d2") ≈ 4
@test Madagascar.histfloat(out, "o1") ≈ 5
@test Madagascar.histfloat(out, "o2") ≈ 6
@test Madagascar.histstring(out, "label1") == "a"
@test Madagascar.histstring(out, "label2") == "é"
@test Madagascar.histstring(out, "unit1") == "普通话"
@test Madagascar.histstring(out, "unit2") == "µm"
Madagascar.close(out)

old_stdout = stdout
(rout, wout) = redirect_stdout()
run(pipeline(`$(Madagascar.RSF_jll.sfdisfil())`, stdin="$(@__DIR__)/test_out_short.rsf", stdout=wout))
data = String(readavailable(rout))
close(rout)
redirect_stdout(old_stdout)
@test data == "   0:    5    2 \n"
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_out_short.rsf`)

println("prog")
println("    read")
dat, n, d, o, l, u = sfspike(n1=4, n2=2, nsp=2, k1=(1,2), mag=(1,3)) |>
                     x -> sfwindow(x; n1=1, squeeze=false) |>
                     rsf_read
@test dat ≈ [1. 1.]
@test n == [1, 2]
@test d ≈ [0.004, 0.1]
@test o ≈ [0, 0]
@test l == ["Time", "Distance"]
@test u == ["s", "km"]

dat, n, d, o, l, u = sfspike(n1=4, nsp=2, k1=(1,2), mag=(1,3)) |>
                     sfrtoc |>
                     x -> sfmath(x; output="input + I") |>
                     x -> sfwindow(x; n1=3) |>
                     rsf_read
@test dat ≈ [1.0+1.0im, 3.0+1.0im, 1.0im]
@test n == [3]
@test d ≈ [0.004]
@test o ≈ [0]
@test l == ["Time"]
@test u == ["s"]

dat, n, d, o, l, u = sfwindow([1 2; 2 3; 4 5]; n1=1) |> rsf_read
@test [1, 2] == dat
@test n == [2]
@test d ≈ [1.0]
@test o ≈ [0.0]
@test l == [""]
@test u == [""]

println("    write")
dat, n, d, o, l, u = rsf_write([1.1; 0; 0.5], [1 3], [.1 .2 .3], [.4 .5 .5],
                               ["a" "b" "c"], ["d" "e" "f"]) |>
                     rsf_read
@test dat ≈ [1.1 0 0.5]
@test n == [1, 3]
@test d ≈ [0.1, 0.2]
@test o ≈ [0.4, 0.5]
@test l == ["a", "b"]
@test u == ["d", "e"]

dat, n, d, o, l, u = rsf_write([im; 0; 0.5], [1 3], [.1 .2 .3], [.4 .5 .5],
                               ["a" "b" "c"], ["d" "e" "f"]) |>
                     x -> sfadd(x; scale=2) |>
                     rsf_read
@test dat ≈ [2im 0 1]
@test n == [1, 3]
@test d ≈ [0.1, 0.2]
@test o ≈ [0.4, 0.5]
@test l == ["a", "b"]
@test u == ["d", "e"]

sfspike(;n1=1) |> x -> rsf_write("$(@__DIR__)/test_write.rsf", x)
dat, n, d, o, l, u = rsf_read("$(@__DIR__)/test_write.rsf")
@test dat ≈ [1.]
@test n == [1]
@test d ≈ [0.004]
@test o ≈ [0]
@test l == ["Time"]
@test u == ["s"]
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_write.rsf`)

sfspike(;n1=1) |> x -> rsf_write(x, "$(@__DIR__)/test_write.rsf")
dat, n, d, o, l, u = rsf_read("$(@__DIR__)/test_write.rsf")
@test dat ≈ [1.]
@test n == [1]
@test d ≈ [0.004]
@test o ≈ [0]
@test l == ["Time"]
@test u == ["s"]
run(`$(Madagascar.RSF_jll.sfrm()) $(@__DIR__)/test_write.rsf`)

dat, n, d, o, l, u = rsf_write([5 2; 3 4], d=[0.1, 0.2], o=[1,2], l=["t", "x"],
                               u=["s", "m"]) |> rsf_read
@test dat ≈ [5 2; 3 4]
@test n == [2, 2]
@test d ≈ [0.1, 0.2]
@test o ≈ [1,2]
@test l == ["t", "x"]
@test u == ["s", "m"]


println("all good!")
