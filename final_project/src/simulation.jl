# Monte Carlo simulation of a panel of households (session 6).
#
# The only random part of the project. The generator is created from the seed inside the function and passed
# along, never the global state: the same seed gives the same panel on every machine.

"""
    simulate_panel(G, gri, N, T, seed)

N households for T periods from the borrowing limit. Returns the final cross section of assets.
"""
function simulate_panel(G, gri, N, T, seed)
    rng = MersenneTwister(seed)                 # one generator, made from the seed; every draw comes from it
    cum = cumsum(gri.Pi; dims=2)                # cumulated rows of Pi, built once
    cum_z = cumsum(gri.lam_z)                   # cumulated stationary distribution, for the initial income
    a = fill(gri.a[1], N)                       # everybody starts at the limit
    m = [searchsortedfirst(cum_z, u) for u in rand(rng, N)]   # income indices from lam_z
    nz = length(gri.z)
    for _ in 1:T
        anew = similar(a)
        for k in 1:nz                           # (i) tomorrow's assets: one interpolation per income state
            sel = m .== k
            anew[sel] = interp1(a[sel], gri.a, G[:, k])
        end
        a = anew
        u = rand(rng, N)                        # (ii) tomorrow's income: one uniform per household
        m = [min(searchsortedfirst(view(cum, m[j], :), u[j]), nz) for j in 1:N]   # the first n with F_mn >= u
    end
    return a
end

"""
    mean_assets_by_simulation(G, gri, N, T, seeds)

Mean assets of the simulated cross section over several seeds: mean, standard error, the values.
"""
function mean_assets_by_simulation(G, gri, N, T, seeds)
    means = [mean(simulate_panel(G, gri, N, T, seed)) for seed in seeds]
    return mean(means), std(means) / sqrt(length(means)), means
end
