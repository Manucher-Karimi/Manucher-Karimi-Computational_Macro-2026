# Figures and tables of the write-up, written to output/ by the launch file.
#
# Every number that appears in the write-up is written here, to a .tex file that the write-up \input's.
# Nothing is typed into the text by hand.

"""
    wealth_figure(lam, gri, path)

Two panels: the distribution of wealth at the equilibrium, and its Lorenz curve.
"""
function wealth_figure(lam, gri, path)
    lam_a = vec(sum(lam; dims=2))               # the marginal distribution over assets
    pop, wealth, gini = lorenz_curve(lam, gri)
    edges = collect(0.0:1.0:60.0)               # bins of width one, as in the session 6 figures
    cdf = interp1(edges, gri.a, cumsum(lam_a))  # the distribution function, read off between grid points
    cdf[1] = 0.0                                # the first bin includes the mass at the limit
    mass = diff(cdf)
    left = bar(
        edges[1:(end - 1)] .+ 0.5,
        mass;
        bar_width=1.0,
        color="#4c72b0",
        linecolor="white",
        linewidth=0.3,
        legend=false,
        xlims=(0, 60),
        xlabel="assets a",
        ylabel="share of households per unit of a",
        title="Wealth distribution",
        titlelocation=:left,
    )
    note = @sprintf("%.1f percent at a = 0", 100 * lam_a[1])
    annotate!(left, 58, 0.95 * maximum(mass), text(note, 8, :right))
    right = plot(
        pop,
        wealth;
        color="#4c72b0",
        label=@sprintf("Lorenz curve, Gini %.2f", gini),
        xlabel="population share",
        ylabel="wealth share",
        title="Lorenz curve",
        titlelocation=:left,
        legend=:topleft,
    )
    plot!(right, [0, 1], [0, 1]; color="#999999", linewidth=0.8, label="equality")
    fig = plot(left, right; layout=(1, 2), size=(640, 260), titlefontsize=10, guidefontsize=8, tickfontsize=7)
    mkpath(dirname(path))
    savefig(fig, path)
    return nothing
end

"""
    equilibrium_table(rows, path)

A booktabs table from (label, value, format) rows, to be \\input into the write-up.
"""
function equilibrium_table(rows, path)
    lines = ["\\begin{tabular}{lr}", "\\toprule", "Statistic & Value \\\\", "\\midrule"]
    for (label, value, fmt) in rows
        push!(lines, label * " & " * Printf.format(Printf.Format(fmt), value) * " \\\\")
    end
    append!(lines, ["\\bottomrule", "\\end{tabular}", ""])
    mkpath(dirname(path))
    write(path, join(lines, "\n"))
    return nothing
end

"""
    numbers_file(numbers, path)

One LaTeX macro per number, so that the text of the write-up can cite results without retyping them.
"""
function numbers_file(numbers, path)
    fmtval(v, fmt) = Printf.format(Printf.Format(fmt), v)
    lines = ["\\newcommand{\\$name}{" * fmtval(v, fmt) * "}" for (name, v, fmt) in numbers]
    mkpath(dirname(path))
    write(path, join(lines, "\n") * "\n")
    return nothing
end
