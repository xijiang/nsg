#!/usr/bin/env julia
using DelimitedFiles, SparseArrays, LinearAlgebra, Statistics, Serialization
BLAS.set_num_threads(18)

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
    Zt  = readdlm("training.zmt")
    Zv  = readdlm("validation.zmt");
    tp  = mean([Zt; Zv], dims=1) # = 2p already
    tmp = sqrt.(tp.*(1 .- .5tp)) # sqrt(2pq)
    Zt  = (Zt.-tp)./tmp
    Zv  = (Zv.-tp)./tmp

    # phenotypes
    y1 = readdlm("1.y")[:, 1]
    y2 = readdlm("2.y")[:, 1]
end;                            # note the semicolon to supress middle results

@time begin
    println("Calculate the sparse matrix of A inverse")
    D   = readdlm("D.vec")[:,1]
    tmp = readdlm("T.mat")
    T   = sparse(Int.(tmp[:,1]), Int.(tmp[:,2]), tmp[:,3])
    
    tmp = T'Diagonal(D)T
    Ai  = tmp[idx, idx]
end;

@time begin
    println("Calculate β, etc")
    A11 = Ai[1:nl, 1:nl]
    A12 = Ai[1:nl, nl+1:nt]
    β   = A11\Matrix(-A12)      # around 9 min on nmbu.org
    P   = X1'X1
    Q   = X2'X2
end;

@time begin                     # around R^-1 
    C   = P + A11 .* λ
    r1  = P*β                   # r1 and r2 are the right hand side of C
    r2  = X1'y1                 #   in both LHS and RHS in the big equations
    sol = C\[r1 r2]
end;

@time begin                     # RHS and LHS
    tmp = β - sol[:, 1:nr]
    tmp = P*tmp
    tmp = β'tmp
    tmp = tmp + Q
    tmp = Zt'tmp
    tmp = tmp*Zt
    lhs = tmp + λ.*I
    
    tmp = X1'y1 - P*sol[:, nr+1]
    tmp = β'tmp + X2'y2
    rhs = Zt'tmp
end;                            # key point here is to write one matrix operation a time

@time begin                     # bhat and GEBV
    bhat = lhs\rhs
    gbvt = Zt*bhat
    gbvv = Zv*bhat
    writedlm("training.ebv", gbvt)
    writedlm("validation.ebv", gbvv)
end;
