#!/usr/bin/env julia
using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics

# dtpth = "./"
# if length(ARGS) == 1
#     dtpth = ARGS[1]
# end
# use dtpth*filename for string operation.

h2 = 0.15                       # Or, read from command line later

@time begin
    println("Calculate the sparse matrix of A inverse")
    D   = readdlm(dpath*"D.vec")[:,1]
    tmp = readdlm(dpath*"T.mat")
    T   = sparse(Int.(tmp[:,1]), Int.(tmp[:,2]), tmp[:,3])
    
    Ai  = T'Diagonal(D)T
end

# Note ID should in 4 groups:
# -- 0: pedigree only
# -- 1: pedigree, phenotypes.  Information that single-step wants to utilize.
# -- 2: pedigree, genotypes, phenotypes.  Or, the training
# -- 3: pedigree, genotypes.  Or, the validation set

@time begin
    println(Dealing with phenotypes)
    λ = (1-h2)/h2
    
end
