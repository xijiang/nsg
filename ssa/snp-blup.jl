#!/usr/bin/env julia
using DelimitedFiles, LinearAlgebra, Serialization, Statistics
nth = 18
if size(ARGS)[1] == 5
    nth = parse(Int, ARGS[5])
    if nth<1
        nth = 1
    end
else
    if size(ARGS)[1] !=4
        println("Usage: ", PROGRAM_FILE, " trainging-Z y h2 validation-Z num-threads[op]")
        exit()
    end
end

BLAS.set_num_threads(nth)

function save_bin(var, file)
    ostream = open(file, "w")
    serialize(ostream, var)
    close(ostream)
end

@time begin
    T = readdlm(ARGS[1])            # genotypes of training set
    y = readdlm(ARGS[2])            # phenotypes of training set

    nid, nlc = size(T)

    h2 = parse(Float64, ARGS[3])
    λ = (1-h2)/h2*nlc

    lhs  = [ nid ones(nid)'T;   T'ones(nid) T'T + λ.*I ]
    rhs  = [sum(y); T'y]
    bhat = lhs\rhs

    # validation
    V = readdlm(ARGS[4])            # genotypes of validation set
    ebvv = [ones(size(V)[1]) V]*bhat
    ebvt = [ones(size(T)[1]) T]*bhat
    println(cor(ebvt, y))

    # regression
    println([ones(length(ebvt)) ebvt]\y)
    println([ones(length(y)) y]\ebvt)

    #write some results
    writedlm("snp-blup.bhat", bhat)
    writedlm("EBV", ebvv)
    writedlm("t3679.ebv", ebvt)
end
