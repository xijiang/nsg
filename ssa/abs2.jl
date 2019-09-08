#!/usr/bin/env julia

using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics, Serialization
BLAS.set_num_threads(18)
h2=.15
λ  = (1-h2)/h2

@time begin
    ix1 = readdlm("1.id", Int)[:, 1]
    ix2 = readdlm("3.id", Int)[:, 1]
    
    n1 = length(ix1)
    n2 = length(ix2)
    nt = n1+n2
    Z  = readdlm("t.cln")
    
    y1 = readdlm("1.y")[:,1]
    y2 = readdlm("2.y")[:,1]
end;

@time begin
    println("LHS")
    ai = deserialize("ai.bin")
    a11 = ai[ix1, ix1]
    a12 = ai[ix1, ix2]
    β = deserialize("beta.bin")
    C = I - a11 .*λ
    bz = β*Z
    lhs = bz'bz
    s1 = C\bz
    lhs = lhs -bz's1
    tmp = bz's1
    lhs = lhs - tmp
    tmp = Z'Z
    lhs = lhs + tmp
    lhs = lhs + I .*λ
end

@time begin
    println("RHS")
    s2 =  C\y1
    rhs = bz'* (y1-s2) + Z'y2
    bhat = lhs\rhs
    ebv = Z*bhat
    writedlm("abs2.ebv", ebv)
end
