# The household problem: the endogenous grid method of week 5.
#
# One function per task: marginal utility and its inverse, linear interpolation, one EGM step, and the loop
# that iterates the step until the policy stops moving.

# The dots inside make both functions work elementwise on a number, a vector, or a matrix
uprime(c, par) = c .^ (-par.γ)                  # marginal utility of u(c) = c^(1 - γ) / (1 - γ)
uprime_inv(m, par) = m .^ (-1 / par.γ)          # the inverse: the c with u'(c) = m

"""
    interp1(xq, xgrid, fgrid)

Linear interpolation of the points (xgrid, fgrid) at every query point in xq, flat outside the grid (week 5).
"""
function interp1(xq, xgrid, fgrid)
    out = similar(xq, Float64)
    for (k, x) in enumerate(xq)
        i = clamp(searchsortedlast(xgrid, x), 1, length(xgrid) - 1)   # the interval around x
        w = clamp((x - xgrid[i]) / (xgrid[i + 1] - xgrid[i]), 0.0, 1.0)   # weight on the right end point
        out[k] = (1 - w) * fgrid[i] + w * fgrid[i + 1]
    end
    return out
end

"""
    egm_step(C, r, w, par, gri)

One step of the endogenous grid method: from the consumption policy C on the grid to the new policy.
"""
function egm_step(C, r, w, par, gri)
    R = 1 + r
    EMU = uprime(C, par) * gri.Pi'              # expected marginal utility tomorrow at every (a'_l, z_m)
    ctilde = uprime_inv(par.β * R .* EMU, par)  # (a) consumption today from the inverted Euler equation
    atilde = (ctilde .+ gri.a .- w .* gri.z') ./ R   # (b) today's assets, budget constraint
    Cnew = similar(C)                           # (c) back to the grid, one income state at a time
    for m in 1:length(gri.z)
        Cnew[:, m] = interp1(gri.a, atilde[:, m], ctilde[:, m])
        below = gri.a .< atilde[1, m]           # poorer than the household that saves a' = a_1: limit binds
        Cnew[below, m] = w * gri.z[m] .+ R .* gri.a[below] .- gri.a[1]   # consume everything down to a' = a_1
    end
    return Cnew
end

"""
    solve_household(r, w, par, mpar, gri; C0=nothing)

Iterate egm_step until the policy stops moving. Returns C, the savings policy G, and the count. C0: an
optional starting guess for the policy, for example the solution at nearby prices (a warm start).
"""
function solve_household(r, w, par, mpar, gri; C0=nothing)
    R = 1 + r
    C = C0 === nothing ? max.(r .* gri.a .+ w .* gri.z', 1e-6) : copy(C0)   # guess: consume r a + w z
    it = 0
    while it < mpar.maxiter
        it += 1
        Cnew = egm_step(C, r, w, par, gri)
        dist = maximum(abs.(Cnew .- C))         # largest change of the policy
        C = Cnew
        dist < mpar.crit_pol && break
    end
    G = w .* gri.z' .+ R .* gri.a .- C          # savings a' = w z + R a - c, N_a x N_z
    return C, G, it
end
