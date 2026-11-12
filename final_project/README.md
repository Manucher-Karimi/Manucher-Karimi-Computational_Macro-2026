# Project title

*Computational Macro (HWS 2026), University of Mannheim. Final project of: your name.*

**What this project does.** One paragraph: the model, the extension, the main result. The template solves the
Aiyagari (1994) economy of session 6 with the methods of the course (endogenous grid method, Young's method,
bisection on the interest rate) and reports the stationary equilibrium, the wealth distribution, and a Monte
Carlo check with its standard error across seeds. Replace this paragraph and the code in `src/` with your own
project and keep the structure.

## Set up, once

Unzip the template into your course repository, so that the folder `final_project/` sits next to your problem
sets. Then, in a terminal in the repository (in VS Code: Terminal, New Terminal):

```
julia final_project/setup_project.jl
```

It moves the repository-wide settings to the root of the repository (the pre-commit hooks, the JuliaFormatter
settings, the VS Code settings, the check on GitHub), installs and precompiles the packages of `Manifest.toml` (a
few minutes, once), installs JuliaFormatter into your default environment and the pre-commit hook, and runs the
project and the smoke test once. Each step says whether it worked and what to do if not; running it again is
harmless. Then commit and push everything.

The hook needs `pre-commit`, a Python tool. The script finds it, or installs it with `pip` if Python is there; on
a computer without Python it installs a plain git hook that runs JuliaFormatter instead. On another computer,
after cloning: `julia final_project/setup_project.jl` again.

## How to run

From the root of the repository:

```
julia --project=final_project final_project/run_all.jl         # every figure and table, about a minute
julia --project=final_project final_project/test/runtests.jl   # the smoke test
```

`run_all.jl` activates the environment of `final_project/` itself, so in VS Code you can also open it and run it
with `Julia: Execute File in REPL`. It writes `output/figures/wealth.pdf`, `output/tables/equilibrium.tex`,
`output/tables/numbers.tex` and `output/log.txt`. The write-up in `writeup/project.tex` includes these files,
compile it with `pdflatex` after the run. Nothing in `output/` is edited by hand.

## Structure

```
<your repository>/
├── .pre-commit-config.yaml      the hooks that run before every commit           ┐ moved here by
├── .JuliaFormatter.toml         settings of the formatter (Blue style, 110)      │ setup_project.jl,
├── .vscode/                     format on save                                   │ they apply to the
├── .github/workflows/           the check on GitHub, after every push            ┘ whole repository
├── (your problem sets)
└── final_project/
    ├── README.md                what, how to run, how long, what comes out where
    ├── setup_project.jl         the setup above
    ├── run_all.jl               the launch file: every figure and table from scratch, every seed set here
    ├── Project.toml             what the project uses, with version bounds
    ├── Manifest.toml            every package with its exact version, written by Pkg, committed
    ├── src/                     functions only, nothing runs on include
    │   ├── model.jl             parameters, grids, the income process
    │   ├── household.jl         the endogenous grid method
    │   ├── aggregation.jl       the lottery, the policy chain, the stationary distribution
    │   ├── simulation.jl        the Monte Carlo panel, with the seed as an argument
    │   ├── equilibrium.jl       one wrapper for Huggett and Aiyagari
    │   └── figures.jl           writes the figures and the .tex tables
    ├── test/
    │   └── runtests.jl          one number you know: r* = 2.53 percent
    ├── output/                  written by run_all.jl, never edited
    │   ├── figures/
    │   └── tables/
    ├── writeup/
    │   └── project.tex          five to eight pages, \input and \includegraphics from output/
    └── formatting_demo/         a badly formatted file, to see what JuliaFormatter does (delete it later)
```

## Formatting, and the pre-commit hook

The code is formatted with `JuliaFormatter` (settings in `.JuliaFormatter.toml`), and a git hook runs it before
every commit so that nobody has to think about it. `setup_project.jl` installed the formatter and the hook. From
now on `git commit` runs the hooks first. A hook that changed a file stops the commit and leaves the file
formatted: `git add` it and commit again. Commits from GitHub Desktop or VS Code run the hooks too. In VS Code,
the settings in `.vscode/` format on save with the Julia extension, so the hook rarely has anything left to do.
To see the formatter at work, `formatting_demo/README.md`.

## The check on GitHub

After every push that touches the project, GitHub runs it on a clean machine (`.github/workflows/`): the hooks on
every file of `final_project/`, `run_all.jl` from scratch with the packages of `Manifest.toml` and the Julia
version recorded there, the smoke test, and `pdflatex` on the write-up. The result is the tick or the cross next
to your commit, and the Actions tab of your repository shows the details. A green tick means your project
reproduces on a machine that is not yours. A yellow warning means the tables you committed differ from those the
code produces now: run `run_all.jl`, compile the write-up, commit both. The first run takes several minutes
(Plots compiles), later runs reuse a cache. Each run keeps the reproduced `output/` and write-up for download
(Artifacts).

## Reproducibility

- **Environment:** `Project.toml` says what the project uses, `Manifest.toml` records every package with its exact
  version and the Julia version. Pkg writes both; commit both. Add a package with `] activate final_project`,
  then `] add Name`.
- **Seeds:** every random number comes from a generator created from a seed in `run_all.jl` (`SEEDS`), passed as
  an argument. Simulated numbers are reported with their standard error across seeds.
- **One command:** `julia --project=final_project final_project/run_all.jl` produces every file the write-up
  includes. The check on GitHub runs exactly that on a clean machine after every push.

## Checklist before you submit

- [ ] the check on GitHub is green for your last commit
- [ ] `Manifest.toml` is committed
- [ ] `writeup/project.pdf` is in the repository, compiled from the current `output/`, no retyped numbers
- [ ] this README says what, how to run, how long, and what comes out where
- [ ] the note on AI use below is filled in

## AI use

Which tools, for what. The rule of the syllabus applies: you must be able to explain every line.
