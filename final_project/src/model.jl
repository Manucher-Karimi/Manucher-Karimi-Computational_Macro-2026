# The model: parameters, grids, and the income process.
#
# Everything that defines the economy before any solution method is applied. Nothing in this file runs when
# it is included, the launch file calls these functions. Replace the contents with your own model and keep the
# shape: parameters in keyword structs, grids built by one function.

Base.@kwdef struct EconomicParameters
    γ::Float64 = 2.0          # relative risk aversion
    β::Float64 = 0.96         # discount factor
    ρ::Float64 = 0.9          # persistence of ln z
    sig_eps::Float64 = 0.2    # standard deviation of the innovation to ln z
    α::Float64 = 0.36         # capital share (Aiyagari)
    δ::Float64 = 0.08         # depreciation rate (Aiyagari)
end

Base.@kwdef struct NumericalParameters
    na::Int = 200             # asset grid points N_a
    nz::Int = 7               # income grid points N_z
    amax::Float64 = 100.0     # upper grid bound a_{N_a}
    crit_pol::Float64 = 1e-8  # the EGM stops when the policy moves by less
    crit_dist::Float64 = 1e-12  # the distribution iteration stops when lam moves by less
    crit_r::Float64 = 1e-6    # the bisection on r stops when the bracket is narrower
    maxiter::Int = 100_000    # iteration cap, the safety net
end

struct Grids
    a::Vector{Float64}        # asset grid, N_a
    z::Vector{Float64}        # income grid, N_z
    Pi::Matrix{Float64}       # transition matrix, N_z x N_z
    lam_z::Vector{Float64}    # stationary distribution of the income chain, N_z
end

"""
    rouwenhorst(n, ρ, σ)

Rouwenhorst's chain for ln z' = ρ ln z + e, e ~ N(0, σ²), on n states (week 5, part 1). Returns the grid
for ln z and the n x n transition matrix: the same numbers as QuantEcon's `rouwenhorst(n, ρ, σ)`, written
out so that the template has no dependency beyond the standard library.
"""
function rouwenhorst(n, ρ, σ)
    p = (1 + ρ) / 2
    Pi = [p (1 - p); (1 - p) p]                 # the two-state chain
    for k in 3:n                                # one state more each round
        big = zeros(k, k)
        big[1:(k - 1), 1:(k - 1)] .+= p .* Pi
        big[1:(k - 1), 2:k] .+= (1 - p) .* Pi
        big[2:k, 1:(k - 1)] .+= (1 - p) .* Pi
        big[2:k, 2:k] .+= p .* Pi
        big[2:(k - 1), :] ./= 2                 # the middle rows were added twice
        Pi = big
    end
    ψ = σ * sqrt((n - 1) / (1 - ρ^2))           # the grid matches the unconditional variance
    return collect(range(-ψ, ψ; length=n)), Pi
end

"""
    stationary_distribution(Pi)

The stationary distribution of a Markov chain: lam = Pi' lam with sum(lam) = 1 (week 4).
"""
function stationary_distribution(Pi)
    n = size(Pi, 1)
    A = [Pi' - I; ones(1, n)]                   # n equations of the fixed point, plus the normalization
    b = [zeros(n); 1.0]
    return A \ b                                # the system is consistent, least squares returns the solution
end

"""
    make_grids(amin, par, mpar)

The income chain on N_z Rouwenhorst states and the quadratically spaced asset grid on [amin, amax].
"""
function make_grids(amin, par, mpar)
    lnz, Pi = rouwenhorst(mpar.nz, par.ρ, par.sig_eps)
    s = range(0.0, 1.0; length=mpar.na)         # N_a equidistant points on [0, 1]
    a = amin .+ (mpar.amax - amin) .* s .^ 2    # squared: dense near amin, sparse near amax
    return Grids(collect(a), exp.(lnz), Pi, stationary_distribution(Pi))
end
