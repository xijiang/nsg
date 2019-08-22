#!/usr/bin/env julia

using DelimitedFiles, Plots, Plots.PlotMeasures
Plots.scalefontsizes(1.5)

ld = readdlm("ld.frq")
md = readdlm("md.frq")
hd = readdlm("hd.frq")

h1 = histogram(ld,
               bins=50,
               normalize=true,
               title="LD",
               color=1,
               dpi=300,
               ylabel="Density of allele frequencies"
               )
#h2 = histogram(md, bins=50, normalize=true, title="MD", color=2, xlabel="Allele frequencies")
h3 = histogram(hd,
               bins=50,
               normalize=true,
               title="HD",
               color=3,
               dpi=300,
               xlabel="Allele frequencies of the SNP markers"
               )
hst = plot(h1, h3, layout=(1,2), size=(960,480), left_margin=10px, bottom_margin=15px, leg=false)

savefig(hst, "hst.pdf")

# s1 = stephist(ld, bins=50, normalize=true, title="LD", color=1, ylabel="Distribution of allele frequencies")
# s2 = stephist(md, bins=50, normalize=true, title="MD", color=2, xlabel="Allele frequencies")
# s3 = stephist(hd, bins=50, normalize=true, title="HD", color=3)
# stp = plot(s1, s2, s3, layout=(1,3), dpi=300, size=(1380, 480), left_margin=10px, bottom_margin=15px, leg=false)
# 
# savefig(stp, "stp.pdf")
# 
# using StatsPlots
# 
# v1 = violin(ld, title="LD", color=1, ylabel="Allele frequencies")
# v2 = violin(md, title="MD", color=2, xlabel="Distribution of allele frequencies")
# v3 = violin(hd, title="HD", color=3)
# vln = plot(v1,v2,v3,layout=(1,3),dpi=300,size=(1380,480), left_margin=10px, bottom_margin=15px, leg=false)
# 
# savefig(vln, "vln.pdf")
