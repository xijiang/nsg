#!/usr/bin/env julia
using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics, Serialization
BLAS.set_num_threads(18)

function save_bin(var, file)
    ostream = open(file, "w")
    serialize(ostream, var)
    close(ostream)
end

# dtpth = "./"
# if length(ARGS) == 1
#     dtpth = ARGS[1]
# end
# use dtpth*filename for string operation.

h2 = 0.15                       # Or, read from command line later
λ  = (1-h2)/h2

# Note ID should in 4 groups:
# -- 0: pedigree only
# -- 1: pedigree, phenotypes.  Information that single-step wants to utilize.
# -- 2: pedigree, genotypes, phenotypes.  Or, the training
# -- 3: pedigree, genotypes.  Or, the validation set
# Above are put into idx, to re-order A inverse matrix.

@time begin
    println("Dealing with data groups")
    # ID list
    ix0 = readdlm("0.id", Int)[:, 1]
    ix1 = readdlm("1.id", Int)[:, 1]
    ix2 = readdlm("2.id", Int)[:, 1]
    ix3 = readdlm("3.id", Int)[:, 1]
    idx = [ix0; ix1; ix2; ix3]

    n0  = length(ix0)
    n1  = length(ix1)
    n2  = length(ix2)
    n3  = length(ix3)
    nl  = n0 + n1               # number of non genotyped animals
    X1  = sparse(1:n1, n0+1:nl, ones(n1))
    nr  = n2 + n3
    X2  = sparse(1:n3, n2+1:nr, ones(n3))
    nt  = n0 + n1 + n2 + n3

    # Read genotypes and standardize them
    Zt = deserialize(open("zt.bin"))
    Zv = deserialize(open("zv.bin"))

    # phenotypes
    y1 = readdlm("1.y")[:, 1]
    y2 = readdlm("2.y")[:, 1]
    save_bin(Zt, "zt.bin")
    save_bin(Zv, "zv.bin")
end;                            # note the semicolon to supress middle results

Ai  = deserialize(open("Ai.bin"))
A11 = Ai[1:nl, 1:nl]
A12 = Ai[1:nl, nl+1:nt]
P   = X1'X1
Q   = X2'X2
β   = deserialize(open("beta.bin"))

sol = deserialize(open("sol.bin"))
lhs = deserialize(open("lhs.bin"))

s2  = sol[:, nr+1]
tmp = P*s2
tmp = X1'y1 - tmp
tmp = β'tmp
tmp = tmp + X2'y2
rhs = Zt'tmp
save_bin(rhs, "rhs.bin")
