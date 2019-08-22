#!/usr/bin/env julia
using DelimitedFiles, Plots, GLM, DataFrames, Plots.PlotMeasures
Plots.scalefontsizes(1.5)

imd = readdlm("imp.diag")
imo = readdlm("imp.offd")
ldd = readdlm("ild.diag")
ldo = readdlm("ild.offd")
hdd = readdlm("345.diag")
hdo = readdlm("345.offd")

mxy = findmax([imd; ldd; hdd])[1]+0.02

p1 = scatter(
             ldo,
             hdo,
             ms=1,
             xlabel="G matrix with LD genotypes",
             ylabel="G matrix with HD genotypes",
             label="",
             dpi=300,
             ylims=(-0.2, mxy),
             xlims=(-0.2, mxy)
             )
scatter!(p1, ldd, hdd, ms=1, label="", dpi=300)

p2 = scatter(ldo,
             imo,
             ms=1,
             xlabel="G matrix with LD genotypes",
             ylabel="G matrix with imputed HD genotypes",
             label="",
             dpi=300,
             ylims=(-0.2, mxy),
             xlims=(-0.2, mxy)
             )

scatter!(p2, ldd, imd, ms=1, label="", dpi=300)

dat = DataFrame(x=ldo[:, 1], y=imo[:, 1])
ols = lm(@formula(y~x), dat)

intercept, coef = coeftable(ols).cols[1]
x12 = [findmin([imo; ldo])[1], findmax([imo; ldo])[1]]
y12 = intercept .+ coef.*x12
plot!(p2, x12, y12, color=3, lw=2, label="")
println(intercept, coef)

dat = DataFrame(x=ldd[:, 1], y=imd[:, 1])
ols = lm(@formula(y~x), dat)

intercept, coef = coeftable(ols).cols[1]
x12 = [findmin([imd; ldd])[1], findmax([imd; ldd])[1]]
y12 = intercept .+ coef.*x12
plot!(p2, x12, y12, color=3, lw=2, label="")
println(intercept, coef)

qqp = plot(p1, p2, layout=(1,2), size=(960, 480), bottom_margin=15px)

savefig(qqp, "qqp.pdf")
