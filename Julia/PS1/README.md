# Submission for the computational part of Problem Set 1 for E8069 Computational Macroeconomics
## Team: 
1. Manucher Karimi

## Declaration of AI use

## How to run the workbook
After selecting the course kernel, please run the entire Juypter notebook sequentially from top to bottom.

## Discussions for Question 2
### Question 2.1.a
With the generalization of the model towards CRRA utility and capital stocks, the Value Function Iteration algorithm itself remains unchanged, as the loop does not depend on specific formulations of the reward matrix U. However, the construction of said reward matrix depends on the underlying utility function. Therefore, the following functions change: 

| Equation under the analytically tractable model | Equation under the generalized model |
|---|---|
| $u(c_t) =  \log(c_t)$| $u(c) = \frac{c_t^{1-\gamma}}{1-\gamma}$ |
|$c = k_t^\alpha - k_{t+1}$|$c = k_t^\alpha + (1-\delta)k_t - k_{t+1}$|
|$k^* = (\alpha\beta)^{\frac{1}{1-\alpha}$|$k^* = \left(\frac{\alpha}{\frac{1}{\beta}-1+\delta}\right)^{\frac{1}{1-\alpha}} $|

These changes affect the computation of the reward matrix $U$, the derivation of the consumption policy function $c$, and the computation of the capital grid bounds.

### Question 2.1.d:
The largest Euler equation error occurs at the capital grid point 2, where the model's computed optimal consumption for a current capital level of 0.01851 deviates from the analytical benchmark by 1.17 percent.

### Question 2.1.f: 
The largest 