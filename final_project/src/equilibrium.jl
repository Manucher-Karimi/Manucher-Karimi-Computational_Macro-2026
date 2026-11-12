# The stationary equilibrium: one wrapper for Huggett (1993) and Aiyagari (1994), as in week 8.
#
# An economy is a borrowing limit (in its grids), a wage function w(r), and a demand function D(r). The
# distribution block `aggregate` turns (r, w) into asset supply A(r), and `stationary_equilibrium` bisects on
# the excess supply A(r) - D(r), passing the solution of one step to the next as a warm start.

struct Aggregates
    A::Float64                # mean assets A(r), the households' asset supply
    lam::Matrix{Float64}      # the stationary distribution, N_a x N_z
    C::Matrix{Float64}        # consumption policy
    G::Matrix{Float64}        # savings policy
end

struct Economy
    name::String
    gri::Grids                # the grids, with the borrowing limit of this economy
    wage::Function            # w(r)
    demand::Function          # D(r): what absorbs the households' assets at the rate r
end

"""
    aggregate(r, w, par, mpar, gri; warm=nothing)

The distribution block at prices (r, w): household -> policy chain -> stationary distribution -> A(r). warm:
the Aggregates of a nearby r, used as the starting point, or nothing for a cold start.
"""
function aggregate(r, w, par, mpar, gri; warm=nothing)
    C, G, _ = solve_household(r, w, par, mpar, gri; C0=warm === nothing ? nothing : warm.C)
    Q = transition_matrix(G, gri)
    lam, _ = stationary_dist(Q, mpar, gri; lam0=warm === nothing ? nothing : warm.lam)
    return Aggregates(mean_assets(lam, gri), lam, C, G)
end

"""
    stationary_equilibrium(eco, par, mpar, lo, hi)

Bisection on the excess supply A(r) - D(r), which increases in r. Returns r*, the aggregates at r*, and the
number of steps.
"""
function stationary_equilibrium(eco, par, mpar, lo, hi)
    warm, k = nothing, 0
    while hi - lo > mpar.crit_r
        mid = (lo + hi) / 2
        warm = aggregate(mid, eco.wage(mid), par, mpar, eco.gri; warm=warm)   # A(mid), warm start
        excess = warm.A - eco.demand(mid)
        lo, hi = excess < 0 ? (mid, hi) : (lo, mid)   # negative excess supply: the root is above mid
        k += 1
    end
    return (lo + hi) / 2, warm, k
end

"""
    huggett_economy(par, mpar; amin=-2.0)

Huggett: a bond in zero net supply between households, wage 1, borrowing down to amin.
"""
function huggett_economy(par, mpar; amin=-2.0)
    return Economy("Huggett", make_grids(amin, par, mpar), r -> 1.0, r -> 0.0)
end

"""
    aiyagari_economy(par, mpar)

Aiyagari: capital rented to a firm with Y = K^α L^(1 - α), prices from the firm. Borrowing limit zero.
"""
function aiyagari_economy(par, mpar)
    gri = make_grids(0.0, par, mpar)
    L = gri.lam_z' * gri.z                      # aggregate labour: mean efficiency E[z]
    # r = α (K/L)^(α - 1) - δ, solved for K
    K_demand(r) = L * ((r + par.δ) / par.α)^(1 / (par.α - 1))
    # the wage that goes with capital demand at r: w = (1 - α) (K/L)^α
    wage(r) = (1 - par.α) * (K_demand(r) / L)^par.α
    return Economy("Aiyagari", gri, wage, K_demand)
end

"""
    output(K, par, gri)

Production Y = K^α L^(1 - α) with L = E[z].
"""
function output(K, par, gri)
    L = gri.lam_z' * gri.z
    return K^par.α * L^(1 - par.α)
end
