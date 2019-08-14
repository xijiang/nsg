#!/usr/bin/env julia
using DelimitedFiles, Plots

im = readdlm("imp.3c")
ld = readdlm("ild.3c")
hd = readdlm("345.3c")

p1 = scatter(ld[:,3],
             hd[:,3],
             ms=1,
             color=1,
             xlabel="G matrix with LD genotypes",
             ylabel="G matrix with HD genotypes",
             label="",
             fontsize=16,
             dpi=300)
p2 = scatter(ld[:,3],
             im[:,3],
             ms=1,
             color=2,
             xlabel="G matrix with LD genotypes",
             ylabel="G matrix with imputed HD genotypes",
             label="",
             fontsize=16,
             dpi=300)

qqp = plot(p1, p2, layout=(1,2), size=(960, 480))

savefig(qqp, "qqp.pdf")
