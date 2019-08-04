#!/usr/bin/env julia

using DelimitedFiles, Plots

ld = readdlm("ld.frq")
md = readdlm("md.frq")
hd = readdlm("hd.frq")

p1 = histogram(ld, bins=50, normalize=true, label="Chip LD")
p2 = histogram(md, bins=50, normalize=true, label="Chip MD", ylabel="Distribution of allele frequencies")
p3 = histogram(hd, bins=50, normalize=true, label="Chip HD", xlabel="Allele frequencies")
frq = plot(p1,p2,p3, layout=(3,1))

savefig(frq, "frq.ps")

convert frq.ps frq.eps
