using Madagascar

c0 = -30.f0/12.f0
c1 = +16.f0/12.f0
c2 = - 1.f0/12.f0

verb = Madagascar.getbool("verb", false) # verbosity
vel = Madagascar.getstring("vel")
ref = Madagascar.getstring("ref")

# Read file data and axes
ww, nw, dw, ow, lw, uw = Madagascar.rsf_read("in")
vv, nv, dv, ov, lv, uv = Madagascar.rsf_read(vel)
rr, nr, dr, or, lr, ur = Madagascar.rsf_read(ref)

nt = nw[]
dt = dw[]
ot = ow[]
lt = lw[]
ut = uw[]
(nz, nx) = nv
(dz, dx) = dv
(oz, ox) = ov
(lz, lx) = lv
(uz, ux) = uv

# Write axes
nout = [nz nx nt]
dout = [dz dx dt]
oout = [oz ox ot]
lout = [lz lx lt]
uout = [uz ux ut]
Fo = Madagascar.output("out")
for i in 1:length(nout)
    Madagascar.putint(Fo, "n$i", nout[i])
    Madagascar.putfloat(Fo, "d$i", dout[i])
    Madagascar.putfloat(Fo, "o$i", oout[i])
    Madagascar.putstring(Fo, "label$i", lout[i])
    Madagascar.putstring(Fo, "unit$i", uout[i])
end

dt2 = dt*dt
idz = 1.f0/(dz*dz)
idx = 1.f0/(dx*dx)

# allocate temporary arrays
function run_afdm()
    um = zero(vv)
    uo = zero(vv)
    up = zero(vv)
    ud = zero(vv)

    for it in 1:nt
        if verb
            print(stderr, "\b\b\b\b\b $it")
        end
        @views @. ud[3:end-2, 3:end-2] = c0 * uo[3:end-2, 3:end-2] * (idx+idz) +
            c1*(uo[3:end-2, 2:end-3] + uo[3:end-2, 4:end-1])*idx +
            c2*(uo[3:end-2, 1:end-4] + uo[3:end-2, 5:end  ])*idx +
            c1*(uo[2:end-3, 3:end-2] + uo[4:end-1, 3:end-2])*idz +
            c2*(uo[1:end-4, 3:end-2] + uo[5:end,   3:end-2])*idz

        # inject wavelet
        ud = @. ud - ww[it] * rr

        # scale by velocity
        ud = @. ud * vv * vv

	# time step
        up = @. 2f0uo - um + ud * dt2
        um = uo
        uo = up

        Madagascar.floatwrite(vec(uo), nz*nx, Fo)
    end
end
@fastmath @inbounds run_afdm()

if verb
    println(stderr, "\n")
end

