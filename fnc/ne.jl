#!/usr/bin/env julia
using DelimitedFiles, GLM, DataFrames

tdt = readdlm("deltaf.yr")
dat = DataFrame(yr=tdt[:,1], lhet=tdt[:,2])
ols = lm(@formula(lhet ~ yr), dat)

interval = 2.36   # the average generation interval

dfy = -coef(ols)[2]

ne = 1/dfy/2/interval

println(dfy, ' ', ne)
