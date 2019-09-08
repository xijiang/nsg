#!/usr/bin/env julia

#=
This is to calculate g_2 with no absorption procedure.
The short-coming is that when SNP for new ID come, we have to reculculate the whole
procedure.

Here, it is only for demonstration purpose.

Also, this program uses mid-results of other procedure, i.e., Ai, β
=#
using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics, Serialization
BLAS.set_num_threads(18)

h2 = 0.15
λ = (1-h2)/h2

@time begin
    println("Read data")
    # G inverse
    z  = readdlm("t.cln");
    tp = mean(z, dims=1);
    z  = z .- tp
    g  = z*z'
    tmp = sum(tp.*(1 .- .5 .*tp))
    g  = g./tmp + I              # as g is of rank n2-1, not full rank here
    gi = inv(g)
end

@time begin
    println("Final equations")
    # LHS
    lhs = I + λ.*gi

    # RHS
    y = readdlm("2.y")[:, 1]

    # EBV
    ebv = lhs\y
    writedlm("gblup.ebv", ebv)
end
