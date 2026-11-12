# One smoke test: a number you know. It catches the change that broke everything.
#
#     julia --project=. test/runtests.jl
#
# The baseline Aiyagari economy of the course has r* = 2.53 percent and K* = 7.57 (session 6, slide 21).

using Test
using LinearAlgebra
using SparseArrays
using Statistics

const SRC = joinpath(@__DIR__, "..", "src")
include(joinpath(SRC, "model.jl"))
include(joinpath(SRC, "household.jl"))
include(joinpath(SRC, "aggregation.jl"))
include(joinpath(SRC, "equilibrium.jl"))

@testset "Aiyagari equilibrium matches class" begin
    par, mpar = EconomicParameters(), NumericalParameters()
    eco = aiyagari_economy(par, mpar)
    r_star, agg, _ = stationary_equilibrium(eco, par, mpar, 0.0, 1 / par.β - 1 - 1e-4)
    @test abs(r_star - 0.0253) < 2e-4
    @test abs(agg.A - 7.57) < 2e-2
    @test abs(sum(agg.lam) - 1.0) < 1e-10      # the distribution is a distribution
end
