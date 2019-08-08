#!/usr/bin/env julia
using DelimitedFiles, GLM, DataFrames, Plots

interval = 2.36   # the average generation interval

tmp = readdlm("deltaf.yr")
dat = DataFrame(yr=tmp[:,1], lh=tmp[:,2])
ols = lm(@formula(lh ~ yr), dat)

α, β = coef(ols)[1: 2]

ne = -1/β/2/interval

println(β, ' ', ne)

p1=plot(dat.yr, dat.lh, xlabel="Year", ylabel="log(Het)", legend=false, dpi=300)
a, b=dat.yr[1], dat.yr[end]
plot!(p1, [a,b], [α+β*a, α+β*b])

rct = dat[(dat[:yr].>1999),:]
ols = lm(@formula(lh ~ yr), rct)

α, β = coef(ols)[1: 2]

ne = -1/β/2/interval

println(β, ' ', ne)

a, b=rct.yr[1], rct.yr[end]
plot!(p1, [a,b], [α+β*a, α+β*b])

savefig(p1, "ne.pdf")
