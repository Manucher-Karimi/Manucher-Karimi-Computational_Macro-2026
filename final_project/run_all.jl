# run_all.jl: every figure and table of the write-up, from scratch, into output/. About a minute, most of it
# compilation on the first run.
#
#     julia --project=. run_all.jl
#
# Writes output/figures/wealth.pdf, output/tables/equilibrium.tex, output/tables/numbers.tex, output/log.txt.
# Every seed of the project is set here.

using Pkg: Pkg
Pkg.activate(@__DIR__)                          # the environment of this repository: Project and Manifest
Pkg.instantiate()                               # installs what is missing, the exact versions of the Manifest

ENV["GKSwstype"] = "100"                        # Plots writes files without opening a window
using LinearAlgebra
using Printf
using Random
using SparseArrays
using Statistics
using Plots

include("src/model.jl")
include("src/household.jl")
include("src/aggregation.jl")
include("src/simulation.jl")
include("src/equilibrium.jl")
include("src/figures.jl")

const OUT = joinpath(@__DIR__, "output")
const SEEDS = 0:4            # the seeds of the Monte Carlo check: five runs, the standard error across them
const N_SIM, T_SIM = 10_000, 500   # households and periods per simulation

function main()
    t_start = time()
    par, mpar = EconomicParameters(), NumericalParameters()
    report = String[]

    # 1. The Aiyagari equilibrium: bisection on r between 0 and the complete markets rate 1/β - 1
    eco = aiyagari_economy(par, mpar)
    r_cm = 1 / par.β - 1
    r_star, agg, steps = stationary_equilibrium(eco, par, mpar, 0.0, r_cm - 1e-4)
    K_star = agg.A
    push!(
        report, @sprintf("Aiyagari: r* = %.3f percent after %d steps, K* = %.3f", 100 * r_star, steps, K_star)
    )

    # 2. The Monte Carlo check at r*: the simulated mean against Young's, with its standard error across seeds
    A_sim, se_sim, _ = mean_assets_by_simulation(agg.G, eco.gri, N_SIM, T_SIM, SEEDS)
    n_seeds = length(SEEDS)
    push!(report, @sprintf("simulation at r*: mean %.3f, s.e. over %d seeds %.3f", A_sim, n_seeds, se_sim))

    # 3. The figure and the tables of the write-up
    wealth_figure(agg.lam, eco.gri, joinpath(OUT, "figures", "wealth.pdf"))
    K_cm = eco.demand(r_cm)
    rows = [
        ("Interest rate \$r^*\$ (percent)", 100 * r_star, "%.2f"),
        ("Capital \$K^*\$", K_star, "%.2f"),
        ("Capital to output \$K^* / Y^*\$", K_star / output(K_star, par, eco.gri), "%.2f"),
        ("Wage \$w^*\$", eco.wage(r_star), "%.3f"),
        ("Share of households at the borrowing limit", sum(agg.lam[1, :]), "%.3f"),
        ("Capital under complete markets", K_cm, "%.2f"),
        ("Simulated mean assets at \$r^*\$ (\$N = 10{,}000\$, \$5\$ seeds)", A_sim, "%.3f"),
        ("Standard error across seeds", se_sim, "%.3f"),
    ]
    equilibrium_table(rows, joinpath(OUT, "tables", "equilibrium.tex"))
    numbers_file(
        [
            ("rstar", 100 * r_star, "%.2f"),
            ("Kstar", K_star, "%.2f"),
            ("Kcm", K_cm, "%.2f"),
            ("Kgain", 100 * (K_star / K_cm - 1), "%.0f"),
            ("bisectionsteps", steps, "%d"),
        ],
        joinpath(OUT, "tables", "numbers.tex"),
    )

    push!(report, @sprintf("run_all.jl finished in %.1f s, Julia %s", time() - t_start, VERSION))
    write(joinpath(OUT, "log.txt"), join(report, "\n") * "\n")
    println(join(report, "\n"))
    return nothing
end

main()
