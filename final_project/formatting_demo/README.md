# The formatting demo

`badly_formatted.jl` runs, and it is hard to read: no spaces around operators, two-space indentation in one
function and four in the next, a whole `if` block and a whole `for` loop on one line, implicit returns, `for i=1:3`.
Nobody should fix this by hand. The formatter does it, and the pre-commit hook makes sure it is never forgotten.

## Try it

From the root of the repository, in a Julia REPL (`setup_project.jl` installed JuliaFormatter in your default
environment):

```julia
using JuliaFormatter
format("final_project/formatting_demo")   # formats the file in place, settings from .JuliaFormatter.toml
```

Then in the terminal:

```
git diff final_project/formatting_demo/                  # what changed: layout only, the logic is untouched
julia final_project/formatting_demo/badly_formatted.jl   # runs exactly as before
git checkout -- final_project/formatting_demo/           # puts the ugly version back, to repeat the demo
```

With the hook installed (`setup_project.jl` did that), the same happens on every commit without a
command: change one character in the file, `git add` and `git commit`, and the commit stops with
`files were modified by this hook`. The file is now formatted; `git add` it and commit again.

## What JuliaFormatter (Blue style, margin 110) changes

```julia
# A deliberately badly formatted file, ...
function utility(c, gamma=2.0)
    # CRRA utility, log utility for gamma = 1
    if gamma==1
        return log(c)
    end
    return c^(1-gamma)/(1-gamma)
end

function bisect(f, lo, hi, tol=1e-6)
    # find the root of f on [lo, hi] by bisection, f increasing
    while hi-lo>tol
        mid=(lo+hi)/2
        if f(mid)<0
            lo=mid
        else
            hi=mid
        end
    end
    return (lo+hi)/2
end

grid = range(0, 100; length=200)
values = utility.(grid .+ 1)
upper = grid[(length(grid) ÷ 2 + 1):end]
weights=[0.25, 0.5, 0.25]
root = bisect(r->utility(1+r, 2.0)-utility(1.02, 2.0), 0.0, 0.1, 1e-8)
for i in 1:3
    println("weight ", i, " = ", weights[i])
end
println("root ", round(root; digits=6), ", utility at the root ", round(utility(1+root); digits=6))
```

In words: one space after every comma; none around `=` in keyword arguments, which are separated from the
positional ones by `;`; four spaces of indentation; one statement per line, `if` and `for` blocks on several
lines; `for i in`, never `for i =`; an explicit `return` at the end of every function; spaces around the
arithmetic inside an index, and around broadcast operators like `.+`. What it leaves alone: the spacing around
ordinary operators and assignments (`gamma==1`, `lo=mid`, `weights=[...]` stay as they are), so writing
`gamma == 1` is still up to you. Nothing else: the formatter never changes what the code does.
