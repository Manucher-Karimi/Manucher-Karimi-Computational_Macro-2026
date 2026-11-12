# setup_project.jl: sets up the final project in your course repository. Run it once, from anywhere:
#
#     julia final_project/setup_project.jl
#
# What it does, in this order (each step says whether it worked, and what to do if not):
#
#   1. checks that final_project/ sits inside your git repository
#   2. moves the repository-wide settings to the root of the repository: .pre-commit-config.yaml (the hooks),
#      .JuliaFormatter.toml, .vscode/ (format on save), .github/workflows/ (the check on GitHub)
#   3. installs the packages of Project.toml and Manifest.toml and precompiles them (a few minutes, once)
#   4. installs JuliaFormatter into your default environment and the pre-commit hook, so every commit is
#      formatted
#   5. runs run_all.jl and the smoke test once: if both pass, everything works
#
# Running it again is harmless: what is already done is skipped.

using Pkg: Pkg

const HERE = @__DIR__                                  # final_project/
const ROOT_FILES = joinpath(HERE, "repo_root_files")   # what goes to the root of the repository
const JULIAFORMATTER_VERSION = "2.14.0"                # the version the check on GitHub uses
const HOOK_MARKER = "installed by setup_project.jl"

const RESULTS = Tuple{String,Bool,String}[]

function record(step, ok, message="")
    push!(RESULTS, (step, ok, message))
    println("  [", ok ? "ok" : "!!", "] ", step, isempty(message) ? "" : ": " * message)
    return ok
end

"""Run a command, show its output, return true if it succeeded."""
function succeeds(cmd)
    try
        return success(pipeline(cmd; stdout=stdout, stderr=stderr))
    catch err
        println("       could not run ", cmd, ": ", sprint(showerror, err))
        return false
    end
end

# 1. Where are we

function find_repository()
    println("\n1. The repository")
    if Sys.which("git") === nothing
        record("git", false, "git is not on the PATH. Install Git (it comes with GitHub Desktop).")
        return nothing
    end
    root = try
        readchomp(pipeline(`git -C $HERE rev-parse --show-toplevel`; stderr=devnull))
    catch
        nothing
    end
    if root === nothing
        record(
            "repository",
            false,
            "$HERE is not inside a git repository. Unzip the template into your course repository, so that " *
            "the folder final_project/ sits next to your problem sets, and run this again.",
        )
        return nothing
    end
    root = realpath(root)
    record("repository", true, root)
    if basename(HERE) != "final_project" || realpath(dirname(HERE)) != root
        println("       note: the project is at $(relpath(HERE, root)), the course expects final_project/")
    end
    return root
end

# 2. The files at the root of the repository

function place_root_files(root)
    println("\n2. Settings at the root of the repository")
    if !isdir(ROOT_FILES)
        record("root files", true, "already in place (repo_root_files/ is gone, nothing to move)")
        return nothing
    end
    for (dir, _, files) in walkdir(ROOT_FILES), file in files
        src = joinpath(dir, file)
        rel = relpath(src, ROOT_FILES)
        dst = joinpath(root, rel)
        mkpath(dirname(dst))
        if startswith(rel, ".vscode") && isfile(dst)
            if read(dst) == read(src)
                record(rel, true, "in place")
            else
                # Julia has no JSON reader without a package: keep the student's file, put ours next to it
                alt = joinpath(dirname(dst), splitext(file)[1] * ".final_project.json")
                cp(src, alt; force=true)
                record(rel, true, "kept yours; the template's are in $(basename(alt)), copy what you want")
            end
            continue
        end
        if isfile(dst) && read(dst) != read(src)
            cp(dst, dst * ".bak"; force=true)
            record(rel, true, "replaced, your old version is in $(basename(dst)).bak")
        else
            record(rel, true, "in place")
        end
        cp(src, dst; force=true)
    end
    rm(ROOT_FILES; recursive=true)
    return nothing
end

# 3. The packages

function install_packages()
    println("\n3. The packages of the project (a few minutes the first time)")
    try
        Pkg.activate(HERE)
        Pkg.instantiate()
    catch err
        return record("packages", false, "Pkg.instantiate() failed: " * sprint(showerror, err))
    end
    try
        Pkg.precompile()
    catch
        # On some Windows machines parallel precompilation fails at random (ReadOnlyMemoryError and the like).
        # One package at a time is slower and usually works.
        println("       precompilation failed, trying again one package at a time")
        ENV["JULIA_NUM_PRECOMPILE_TASKS"] = "1"
        try
            Pkg.precompile()
        catch err
            return record(
                "packages",
                false,
                "precompilation failed twice. Close all Julia windows and run this script again; " *
                "if it still fails, update Julia (juliaup update) and try once more. " *
                sprint(showerror, err),
            )
        end
    end
    return record("packages", true, "installed and precompiled")
end

# 4. The formatter and the hook

function install_formatter()
    # the pre-commit hook calls JuliaFormatter from the default environment, so it goes there
    try
        Pkg.activate()
        deps = values(Pkg.dependencies())
        installed = [d.version for d in deps if d.name == "JuliaFormatter" && d.is_direct_dep]
        if isempty(installed) || string(only(installed)) != JULIAFORMATTER_VERSION
            try
                Pkg.add(; name="JuliaFormatter", version=JULIAFORMATTER_VERSION)
            catch
                println("       JuliaFormatter $JULIAFORMATTER_VERSION not available, installing the latest")
                Pkg.add("JuliaFormatter")
            end
        end
        return record("JuliaFormatter", true, "in your default environment")
    catch err
        return record("JuliaFormatter", false, sprint(showerror, err))
    finally
        Pkg.activate(HERE)
    end
end

"""Whether a command runs and exits with 0, without showing its output."""
function works(cmd)
    try
        return success(pipeline(cmd; stdout=devnull, stderr=devnull))
    catch
        return false
    end
end

"""
    find_precommit()

A command that runs pre-commit, or nothing: pre-commit itself, or `python -m pre_commit`, installed if needed.
"""
function find_precommit()
    exe = Sys.which("pre-commit")
    exe === nothing || return `$exe`
    for name in ("python", "python3", "py")
        py = Sys.which(name)
        py === nothing && continue
        works(`$py -c "import sys"`) || continue    # skips the Windows Store stub, which only opens the store
        works(`$py -m pre_commit --version`) && return `$py -m pre_commit`
        println("       installing pre-commit with $name -m pip install --user pre-commit")
        succeeds(`$py -m pip install --user pre-commit`) && return `$py -m pre_commit`
    end
    return nothing
end

# Without Python there is no pre-commit: a plain git hook that runs JuliaFormatter on the staged .jl files
# does the essential part. The check on GitHub runs the full set of hooks either way.
const FALLBACK_HOOK = """
#!/bin/sh
# $HOOK_MARKER: formats the staged Julia files, and stops the commit if that changed one.
git diff --cached --name-only -z --diff-filter=ACM -- '*.jl' |
    xargs -0 -r julia --startup-file=no -e 'import JuliaFormatter; exit(JuliaFormatter.format(ARGS) ? 0 : 1)'
status=\$?
if [ \$status -ne 0 ]; then
    echo "JuliaFormatter changed files: look at them, git add them, and commit again."
fi
exit \$status
"""

function install_hook(root)
    println("\n4. The formatter and the pre-commit hook")
    install_formatter()
    precommit = find_precommit()
    if precommit !== nothing
        ok = succeeds(Cmd(`$precommit install --install-hooks`; dir=root))
        message = ok ? "every commit is now formatted" : "pre-commit install failed"
        return record("pre-commit hook", ok, message)
    end
    hooks = readchomp(`git -C $root rev-parse --git-path hooks`)
    hooks = isabspath(hooks) ? hooks : joinpath(root, hooks)
    hook = joinpath(hooks, "pre-commit")
    if isfile(hook) && !occursin(HOOK_MARKER, read(hook, String))
        return record("pre-commit hook", false, "$hook exists and was not written by this script")
    end
    mkpath(hooks)
    write(hook, FALLBACK_HOOK)
    chmod(hook, 0o755)
    return record("pre-commit hook", true, "no Python found: a plain git hook formats .jl files on commit")
end

# 5. Does it run

function run_project(root)
    println("\n5. run_all.jl and the smoke test")
    julia = Base.julia_cmd()
    ok = succeeds(Cmd(`$julia --project=$HERE $(joinpath(HERE, "run_all.jl"))`; dir=root))
    record("run_all.jl", ok, ok ? "wrote output/" : "failed, see the error above")
    ok = succeeds(Cmd(`$julia --project=$HERE $(joinpath(HERE, "test", "runtests.jl"))`; dir=root))
    record("smoke test", ok, ok ? "passed" : "failed, see above")
    return nothing
end

function main()
    println("Setting up the final project")
    root = find_repository()
    if root !== nothing
        place_root_files(root)
        if install_packages()
            install_hook(root)
            "--skip-run" in ARGS || run_project(root)
        end
    end
    failed = filter(r -> !r[2], RESULTS)
    println("\n", "-"^78)
    if !isempty(failed)
        println("Not done yet. Fix what is marked [!!] and run this script again:")
        for (step, _, msg) in failed
            println("  - ", step, ": ", msg)
        end
        println("If you are stuck, send the whole output of this script to your instructor.")
        exit(1)
    end
    println("Done. Next:")
    println("  1. In GitHub Desktop, commit and push, the new files at the root of the repository included.")
    println("  2. On GitHub, the Actions tab of your repository shows the check: it runs your project on a")
    println("     clean machine after every push. A green tick means it reproduces.")
    println("  3. Replace src/, run_all.jl and the write-up with your own project; keep the structure.")
    return nothing
end

main()
