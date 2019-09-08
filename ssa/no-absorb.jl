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
    # A inverse
    ix1 = readdlm("1.id", Int)[:, 1]
    ix2 = readdlm("3.id", Int)[:, 1]
    Ai = deserialize(open("ai.bin"));
    a11 = Ai[ix1, ix1];
    a12 = Ai[ix1, ix2]

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
    lhs11 = I + λ.*a11;
    lhs12 = λ.*a12;
    β = deserialize(open("beta.bin"))
    β = sparse(β)               # as β is sparse here, to save time
    lhs22 = I + λ.*gi
    tmp   = β'a12
    lhs22 = lhs22 - λ.*tmp
    lhs = [lhs11 lhs12; lhs12' lhs22]

    # RHS
    y1 = readdlm("1.y")[:, 1]
    y2 = readdlm("2.y")[:, 1]
    y  = [y1; y2]

    # EBV
    g  = lhs\y
    g2 = g[end-length(y2)+1:end]
    bv = readdlm("blup.ebv")[:, 1]
    println("Correlation between GEBV, y:        ", cor(g2, y2))
    println("correlation between GEBV, BLUP-EBV: ", cor(bv, g2))
    println("Correlation between    y, BLUP-EBV: ", cor(y2, bv))
    writedlm("no-absorb.ebv", g2)
end
