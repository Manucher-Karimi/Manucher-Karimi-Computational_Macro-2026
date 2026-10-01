# Submission for the computational part of Problem Set 1 for E8069 Computational Macroeconomics

## Team

1. Manucher Karimi

## Declaration of AI use

For the submission of this problem set, ChatGPT was used for the following assistance:

- Conceptual and derivation tutoring
- Julia debugging and syntax assistance
- Coding assistance, including assistance with plotting, output formatting, and the extrapolation in Question 2.2.c
- Submission review
- Proofreading

## How to run the workbook

After selecting the course kernel, please run the entire Jupyter notebook sequentially from top to bottom.

## Discussions for Question 2

### Question 2.1.a

With the generalization of the model towards CRRA utility and partial capital depreciation, the Value Function Iteration algorithm itself remains unchanged, as the loop does not depend on the specific formulation of the reward matrix $U$. However, the construction of the reward matrix depends on the underlying utility function and resource constraint. Therefore, the following equations change:

| Equation under the analytically tractable model | Equation under the generalized model |
|---|---|
| $u(c_t)=\log(c_t)$ | $u(c_t)=\frac{c_t^{1-\gamma}-1}{1-\gamma}$ |
| $c_t=k_t^\alpha-k_{t+1}$ | $c_t=k_t^\alpha+(1-\delta)k_t-k_{t+1}$ |
| $k^*=(\alpha\beta)^{\frac{1}{1-\alpha}}$ | $k^*=\left(\frac{\alpha}{\frac{1}{\beta}-1+\delta}\right)^{\frac{1}{1-\alpha}}$ |

These changes affect the computation of the reward matrix $U$, the derivation of the consumption policy function, and the computation of the capital grid bounds. The Bellman maximization and the Value Function Iteration loop itself remain unchanged.

### Question 2.1.d

The largest Euler equation error occurs at capital grid point 2, corresponding to a current capital level of $k=0.01851$. The absolute Euler equation error is $1.170\times10^{-2}$, which implies that current consumption deviates by approximately 1.17 percent of itself from the consumption level prescribed by the Euler equation conditional on tomorrow's consumption.

### Question 2.1.e

The largest Euler equation error is found at the first grid point, corresponding to $k=0.29208$, with an absolute error of $4.563\times10^{-2}$. This corresponds to a consumption deviation of approximately 4.563 percent in consumption units. The mean of $\log_{10}|e_i|$ over the grid is $-2.160$.

### Question 2.1.f

The capital policy function crosses the 45-degree diagonal at approximately $k=2.886$. The analytical steady state implied by equation (6) is approximately $k^*=2.921$. The difference between the two values is therefore small and results from the discretization of the state and policy space onto the finite capital grid.

The largest Euler equation error occurs at the lower end of the capital grid. At low capital levels, both the marginal product of capital and the curvature of the policy problem are relatively large. At the same time, the on-grid policy can only choose among discrete values of $k'$. Therefore, a given discretization error in the policy can translate into a comparatively large Euler equation error in this region.

### Question 2.2.a

Starting from $k_0=0.5k^*$, the simulated capital path converges towards the numerical steady state. With $N=200$, the path settles at approximately $k=2.886$, which differs from the analytical steady state by approximately $0.0352$. The difference is caused by the discretization of the capital grid, as the simulated path can only settle at one of the available grid points.

### Question 2.2.b

Increasing the number of grid points substantially reduces the maximum Euler equation error. The maximum error falls from approximately $0.1653$ for $N=50$ to $0.04563$ for $N=200$ and to $0.01111$ for $N=800$. Since multiplying $N$ by four reduces the Euler equation error by approximately a factor of four, the error scales approximately with order $O(N^{-1})$.

The runtime increases considerably with the number of grid points. The Value Function Iteration compares every current grid point with every possible next-period grid point, such that the reward and Bellman matrices contain $N^2$ elements. Since the number of VFI iterations remains approximately constant across the three specifications, the computational cost is approximately of order $O(N^2)$. The measured runtimes are somewhat noisy, particularly for the smaller grids, but increase strongly as $N$ becomes larger.

The finer grid also moves the numerical steady state closer to the analytical steady state, with the settling point increasing from approximately $2.784$ for $N=50$ to $2.886$ for $N=200$ and $2.911$ for $N=800$.

### Question 2.2.c

Using the approximate relationship $\max_i |e_i|\propto N^{-1}$ and the result for $N=800$, an Euler equation error below $10^{-4}$ would require approximately

$$
N \approx 800\frac{0.01111}{10^{-4}} \approx 88,864.
$$

Assuming runtime scales approximately with $N^2$, the estimated runtime on the current machine is approximately 14,572 seconds, or about 243 minutes / 4.05 hours.

### Question 2.2.d

For $\delta=0.1$ and $N=800$, the three economies share the same analytical steady state but converge towards it at different speeds.

- For $\gamma=1$, the capital stock enters the 5 percent neighborhood of $k^*$ after 15 periods.
- For $\gamma=2$, the capital stock enters the 5 percent neighborhood of $k^*$ after 22 periods.
- For $\gamma=5$, the capital stock enters the 5 percent neighborhood of $k^*$ after 37 periods.

Therefore, convergence becomes slower as $\gamma$ increases.

### Question 2.2.e

The household with the lowest $\gamma$ reaches the steady state the fastest. Since the intertemporal elasticity of substitution is given by

$$
IES=\frac{1}{\gamma},
$$

the three economies have an IES of $1.0$, $0.5$, and $0.2$ for $\gamma=1$, $\gamma=2$, and $\gamma=5$, respectively.

A higher IES implies that consumption growth reacts more strongly to differences in the intertemporal return to saving. Since the economy starts below the steady state, the marginal return to additional capital accumulation is relatively high. The household with the higher IES therefore reacts more strongly to this return incentive and initially allocates a larger fraction of output towards saving and capital accumulation.

This can also be seen directly in the initial saving rates. At $k_0$, the saving rates are approximately:

- $\gamma=1$: $s_0=0.316$
- $\gamma=2$: $s_0=0.254$
- $\gamma=5$: $s_0=0.198$

The household with $\gamma=1$ therefore accumulates capital fastest and reaches the neighborhood of the steady state first, whereas the household with $\gamma=5$ has the lowest initial saving rate and converges most slowly.