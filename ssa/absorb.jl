#!/usr/bin/env julia
using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics

# dtpth = "./"
# if length(ARGS) == 1
#     dtpth = ARGS[1]
# end
# use dtpth*filename for string operation.

h2 = 0.15                       # Or, read from command line later
λ = (1-h2)/h2

# Note ID should in 4 groups:
# -- 0: pedigree only
# -- 1: pedigree, phenotypes.  Information that single-step wants to utilize.
# -- 2: pedigree, genotypes, phenotypes.  Or, the training
# -- 3: pedigree, genotypes.  Or, the validation set

@time begin
    println("Dealing with data groups")
    # ID list
    ix0 = readdlm("0.id", Int)[:, 1]
    ix1 = readdlm("1.id", Int)[:, 1]
    ix2 = readdlm("2.id", Int)[:, 1]
    ix3 = readdlm("3.id", Int)[:, 1]
    idx = [ix0; ix1; ix2; ix3]
    # Training genotypes
    Z   = readdlm("training.zmt")
    n0  = length(ix0)
    n1  = length(ix1)
    n2  = length(ix2)
    n3  = length(ix3)
    nl  = n0 + n1               # number of non genotyped animals
    X1  = sparse(1:n1, n0+1:nl, ones(n1))
    nr  = n2 + n3
    X2  = sparse(1:n3, n2+1:nr, ones(n3))
    nt  = n0 + n1 + n2 + n3
end

@time begin
    println("Calculate the sparse matrix of A inverse")
    D   = readdlm("D.vec")[:,1]
    tmp = readdlm("T.mat")
    T   = sparse(Int.(tmp[:,1]), Int.(tmp[:,2]), tmp[:,3])
    
    tmp = T'Diagonal(D)T
    Ai  = tmp[idx, idx]
end

@time begin
    println("Calculate β, etc")
    A11 = Ai[1:nl, 1:nl]
    A12 = Ai[1:nl, nl+1:nt]
    β   = A11\Matrix(-A12)      # around 9 min on nmbu.org
    P   = X1'X1
    Q   = X2'X2
end

@time begin                     # RHS and LHS
    rhs = Z'(β'X1'y1 - β'P(P
    lhs = Z'(β'P*β - β'P(P+λ.*A11
