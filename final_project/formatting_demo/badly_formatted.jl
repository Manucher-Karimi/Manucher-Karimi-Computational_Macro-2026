# A deliberately badly formatted file, for the formatting demo of session 8. Run
# `using JuliaFormatter; format("formatting_demo")` (or commit it with the pre-commit hook installed) and look at
# `git diff`: the formatter fixes the layout and nothing else.
function utility(c,gamma = 2.0)
  # CRRA utility, log utility for gamma = 1
  if gamma==1
      return log(c)
  end
  c^(1-gamma)/(1-gamma)
end

function bisect(f,lo,hi,tol = 1e-6)
    # find the root of f on [lo, hi] by bisection, f increasing
    while hi-lo>tol
        mid=(lo+hi)/2
        if f(mid)<0 lo=mid else hi=mid end
    end
    (lo+hi)/2
end

grid = range(0,100,length = 200)
values = utility.(grid.+1)
upper = grid[length(grid)÷2+1:end]
weights=[0.25,0.5,0.25]
root = bisect(r->utility(1+r,2.0)-utility(1.02,2.0),0.0,0.1,1e-8)
for i=1:3 println("weight ", i, " = ", weights[i]) end
println("root ", round(root,digits = 6), ", utility at the root ", round(utility(1+root),digits = 6))
