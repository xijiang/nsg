#!/usr/bin/env julia
#=
This is to simplify the situation, where there are only 2 blocks of ID

ID block |  pedigree | phenotype | genotypes |
1:trng      y          y           n
2:trng      y          y           y

verification will be done in block 2.
=#

using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics, Serialization
BLAS.set_num_threads(18)

function save_bin(var, file)
    ostream = open(file, "w")
    serialize(ostream, var)
    close(ostream)
end;

h2 = 0.15                       # Or, read from command line later
λ  = (1-h2)/h2

@time begin
    ix1 = readdlm("1.id", Int)[:, 1]
    ix2 = readdlm("3.id", Int)[:, 1]

    n1 = length(ix1)
    n2 = length(ix2)
    nt = n1+n2
    Z  = readdlm("t.cln")
    tp = mean(Z, dims=1)        # == 2p
    # tmp= sqrt.(tp.*(1 .- .5tp)) # == 2pq
    # Z  = (Z .- tp)./tmp         # standardization
    
    y1 = readdlm("1.y")[:,1]
    y2 = readdlm("2.y")[:,1]
    # save_bin(Z, "z.bin")
end;

@time begin
    println("Calculate the sparse matrix of A inverse")
    D   = readdlm("D.vec")[:,1]
    tmp = readdlm("T.mat")
    T   = sparse(Int.(tmp[:,1]), Int.(tmp[:,2]), tmp[:,3])
    
    Ai  = T'Diagonal(D)T
    save_bin(Ai, "ai.bin")
end;

@time begin                     # β
    println("Calculate β, etc")
    A11 = Ai[ix1, ix1]
    A12 = Ai[ix1, ix2]
    β   = A11\Matrix(-A12)      # around 9 min on nmbu.org
    save_bin(β, "beta.bin")
end;

@time begin                     # comman items
    println("Common matrices")
    C  = I - A11.*λ
    bz = β*Z
    save_bin(bz, "bz.bin")
end

println("LHS")
@time begin                     # LHS
    println("-- item 1.1: bz'bz")
    # item 1.1
    lhs = bz'bz
end

@time begin
    println("-- item 1.2: +bz's1")
    # item 1.2
    s1 = C\bz
    lhs = lhs - bz's1
end

@time begin
    println("-- item 2: +Z'Z")
    # item 2
    lhs = lhs + Z'Z
end

@time begin
    println("-- item 3: + I.*λ")
    # item 3
    lhs = lhs + I.*λ
    save_bin(lhs, "lhs.bin")
end;

@time begin                     # RHS
    println("RHS")
    s2  = C\y1
    rhs = bz'*(y1-s2) + Z'y2
    save_bin(rhs, "rhs.bin")
end

@time begin
    bhat = lhs\rhs
    ebv  = Z*bhat
    save_bin(ebv,  "ebv.bin")
    save_bin(bhat, "bhat.bin")
end
