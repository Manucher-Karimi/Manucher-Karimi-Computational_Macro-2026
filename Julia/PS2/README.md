# Submission for the computational part of Problem Set 1 for E8069 Computational Macroeconomics

## Team

1. Manucher Karimi

## Declaration of AI use

For the submission of this problem set, ChatGPT was used for the following assistance:

- Conceptual and derivation tutoring
- Julia debugging and syntax assistance
- Coding assistance, including assistance with plotting, output formatting
- Submission review
- Proofreading

## How to run the workbook

After selecting the course kernel, please run the entire Jupyter notebook sequentially from top to bottom. Reported run time and iteration computation times can vary by device used.

## Discussion of Question 2: 
### Question 2.2.b: 

When we increase the resolution of the asset grid $N_a$, the error $e_W$ and the maximum Euler equation error for the on-grid VFI fall, while the errors for the remaining three methods remain unchanged despite the increase the resolution. Meanwhile, the compute time per iteration increases with the resolution of the grid for all methods. This observed behavior can be explained by the main difference between on-grid VFI and the other solvers. Unlike on-grid VFI, VFI off-grid, Time iteration and EGM not only use the grid points themselves, but also interpolations in between the grid points. The use of interpolates makes the gains from higher grid resolution redundant as the solvers can already obtain results in between grid points and are not restricted to the values of the grid points. 

Surprisingly, the maximum Euler error increases for both off-grid VFI and time iteration when we increase the grid resolution. 

### Question 2.2.c: 

The tightening in the convergence criteria by a factor of 100 decreases the policy error $e_W$ for both the off-grid VFI and the EGM while actually increasing the error for Time Iteration. Meanwhile, the error remains identical for on grid VFI. Therefore, the asset grid itself sets the error $e_W$ only for on-grid VFI while the stopping rule determines the error for the other investigated methods. 

### Question 2.2.d: 

When we rank the methods for the maximum computed Euler equation error the ranking of the methods would be from best to worst: 
1. Howard
2. VFI off the grid
3. EGM
4. Time iteration
5. VFI on the grid. 

If we instead rank them by the mean Euler error ranking remains the same with : 
1. Howard
2. VFI off the grid
3. EGM
4. Time iteration
5. VFI on the grid. 

This ranking remains unchanged, when we use the maximum consumption-policy error $e_W$ as our ranking criteria. 

Interestingly, we do observe that when we move away from the interior window and instead observe $e_G$, that all methods report the same policy error with 0.18. As $e_g$ also captures states where the household is at the grid bounds, the Euler equation does not capture these corner solutions, as we exclude them from the computation. Therefore, if we are interested at these households at the grid boundaries (e.g. if we introduce asset constraints), relying on the interior window policy error or the Euler equation error is insufficient to assess accuracy. 

## Discussion of Question 3: 
### Question 3.2.c: 

When we rank the methods for the CRRA case, we get the following rankings for the maximum Euler equation error and the mean Euler error: 
1. EGM
2. VFI off the grid & Howard
3. Time Iteration
4. VFI on the grid

with the following values reported: 
| method | iterations | time (s) | ms per iteration | Euler error, max | Euler error, mean $\log_{10}$ |
| --- | --- | --- | --- | --- | --- |
| VFI on the grid | 339 | 1.98 | 5.84 | $1.7 \cdot 10^{-1}$ | -1.7 |
| VFI off the grid | 339 | 52.79 | 155.72 | $1.2 \cdot 10^{-4}$ | -5.1 |
| Howard | 11 | 2.82 | 256.73 | $1.2 \cdot 10^{-4}$ | -5.1 |
| Time iteration | 272 | 4.20 | 15.45 | $1.7 \cdot 10^{-4}$ | -4.7 |
| EGM | 272 | 0.28 | 1.04 | $2.8 \cdot 10^{-6}$ | -6.6 |

For the purpose of accuracy of the results, all methods except for VFI on the grid can be trusted up to three decimal digits as their maximum Euler equation error is at least in the $10^{-4}$ range. 

When we compare the results to the CARA model where we know the exact solution, we can observe that the both the maximum Euler error and the mean euler error are larger in the CRRA model than in the CARA benchmark, subsequently performing relatively worse under CRRA than under CARA. However, these differences can be explained by the introduction of a potentially binding borrowing constraint, a different income grid caused by recomputation of the income process, and the different utility function. 

However, for this CRRA model, EGM can be preferred as the computed policy function is accurate for the first five decimal digits and takes the least amount of time to complete its computations. 

### Question 3.3.:
For 1.5 to 2 % of all asset states in the lowest two income states, all methods report that the borrowing constraint is binding and that households would prefer to take up debt if unconstrained. The binding borrowing constraint turns the Euler equation into an inequality as the Lagrange multiplier of the constraint is nonzero. 

Regarding the location of the maximum Euler equation error, with the exception of VFI on the grid the reported maximum error is located near the upper asset grid bound. This is consistent with the design of the asset grid as the resolution of the grid is more sparse at the upper bound due to the quadratic spacing of our grid points to locate more asset states near the borrowing constraint. Surprisingly, for VFI on the grid, the largest Euler error reported is at asset level $a = 16.161$ and not at the upper asset grid bound. The plot of the maximum Euler equation error shows that the error for VFI on the grid is more noisy and less smooth than the other methods. As VFI on the grid can only use the actual grid points as asset states, discretization can introduce larger deviations between the optimal asset choice and the corresponding required current asset holding. 