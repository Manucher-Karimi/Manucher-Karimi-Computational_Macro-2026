# From the policy to the distribution: Young's method of session 6.
#
# The lottery, the policy chain as a sparse matrix, its stationary distribution, and the aggregates.

"""
    lottery(G, gri)

For every policy value a'_im: the index l of the grid point below it, and the weight w_im on l + 1.
"""
function lottery(G, gri)
    na = length(gri.a)
    l = clamp.(searchsortedlast.(Ref(gri.a), G), 1, na - 1)   # a_l <= a'_im < a_{l+1}, l at most N_a - 1
    w = (G .- gri.a[l]) ./ (gri.a[l .+ 1] .- gri.a[l])
    return l, clamp.(w, 0.0, 1.0)               # exactly at the top of the grid, w would be 1 + 1e-16
end

"""
    transition_matrix(G, gri)

The policy chain Q_g as a sparse matrix: Q[(i, m), (l, n)] = Pi[m, n] (1 - w_im) and
Q[(i, m), (l + 1, n)] = Pi[m, n] w_im, zeros elsewhere.
"""
function transition_matrix(G, gri)
    na, nz = length(gri.a), length(gri.z)
    idx = reshape(1:(na * nz), na, nz)          # idx[i, m] = i + (m - 1) N_a: the row of state (a_i, z_m)
    l, w = lottery(G, gri)
    rows, cols, vals = Int[], Int[], Float64[]  # the triplets, collected column block by column block
    for m in 1:nz                               # income today
        for n in 1:nz                           # income tomorrow
            append!(rows, idx[:, m])            # mass 1 - w_im goes to (a_l, z_n) ...
            append!(cols, idx[l[:, m], n])
            append!(vals, gri.Pi[m, n] .* (1 .- w[:, m]))
            append!(rows, idx[:, m])            # ... and mass w_im to (a_{l+1}, z_n)
            append!(cols, idx[l[:, m] .+ 1, n])
            append!(vals, gri.Pi[m, n] .* w[:, m])
        end
    end
    return sparse(rows, cols, vals, na * nz, na * nz)
end

"""
    stationary_dist(Q, mpar, gri; lam0=nothing)

Iterate lam_{n+1} = Q' lam_n from the uniform distribution (or from lam0). Returns lam as an N_a x N_z table,
and the iteration count.
"""
function stationary_dist(Q, mpar, gri; lam0=nothing)
    n = size(Q, 1)
    lam = lam0 === nothing ? fill(1 / n, n) : vec(lam0)   # the start, as a vector in the order of idx
    QT = sparse(Q')                             # the transpose once, stored as its own sparse matrix
    it = 0
    while it < mpar.maxiter
        it += 1
        lam_new = QT * lam
        dist = maximum(abs.(lam_new .- lam))
        lam = lam_new
        dist < mpar.crit_dist && break
    end
    return reshape(lam, length(gri.a), length(gri.z)), it   # back to the (a, z) table
end

"""
    mean_assets(lam, gri)

A = Σ_{i, m} lam_im a_i, with lam as an N_a x N_z table.
"""
mean_assets(lam, gri) = sum(lam .* gri.a)

"""
    lorenz_curve(lam, gri)

The Lorenz curve of wealth (cumulative population share, cumulative wealth share) and the Gini.
"""
function lorenz_curve(lam, gri)
    lam_a = vec(sum(lam; dims=2))               # the marginal distribution over assets
    pop = [0.0; cumsum(lam_a)]
    wealth = [0.0; cumsum(lam_a .* gri.a)]
    wealth = wealth ./ wealth[end]
    gini = 1 - sum((pop[2:end] .- pop[1:(end - 1)]) .* (wealth[2:end] .+ wealth[1:(end - 1)]))   # 1 - 2 area
    return pop, wealth, gini
end
