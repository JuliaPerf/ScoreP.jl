"""
Main entry function.

1) Compiles the subsystem in a temporary directory.
2) Prepares the environment (i.e. `LD_LIBRARY_PATH` and `LD_PRELOAD`)
3) Restarts the Julia session "in-place"

Afterwards, the ScoreP bindings can be used.
"""
function init(allargs = ARGS; keep_files = false)
    scorep_config_args = String[]
    script_args = String[]

    if !isempty(allargs)
        for (i, arg) in pairs(allargs)
            # ScoreP.jl args
            if arg == "--keep-files"
                keep_files = true
            elseif arg in ("--verbose", "-v", "--debug")
                set_logging_level(:debug)
                # scorep-config args
            elseif arg == "--mpi"
                push!(scorep_config_args, "--mpp=mpi")
            elseif arg[1] == '-'
                push!(scorep_config_args, arg)
                # script args
            else
                # no scorep config args left -> rest is script args
                append!(script_args, allargs[i:end])
                break
            end
        end
        # TODO: process arguments / pass them on to scorep-config
    end

    # set defaults for a few scorep config args if they haven't already been user-specified
    isset(x) = any(startswith(x), scorep_config_args)
    if !isset("--thread")
        push!(scorep_config_args, "--thread=pthread")
    elseif !isset("--nocompiler")
        push!(scorep_config_args, "--compiler")
    end

    @debug("Input arguments", join(scorep_config_args, ' '), join(script_args, ' '))

    initialised = lowercase(get(ENV, "SCOREP_JL_INITIALISED", "")) == "true"
    if !initialised
        @debug("INITIALISED=FALSE")
        init_environment(scorep_config_args; keep_files)
        ENV["SCOREP_JL_INITIALISED"] = "true"
        restart_julia_inplace()
    else
        restore_ld_preload()
        @debug("INITIALISED=TRUE")
    end

    # good to go
    setARGS(script_args)

    @debug "LEAVING $(@__FUNCTION__())"
    return nothing
end

"""
Compiles the subsystem (shared library) in a temporary directory, adds this tempdir to
`LD_LIBRARY_PATH`, and sets `LD_PRELOAD` appropriately.
"""
function init_environment(args = String[]; keep_files = false)
    if contains(get(ENV, "LD_PRELOAD", ""), "libscorep")
        error("`LD_PRELOAD` already contains libscorep libraries. Aborting.")
    end

    if !("--user" in args)
        push!(args, "--user")
    end

    # debugging
    prev_env = copy(ENV)
    @debug(@__FUNCTION__(), join(args, ' '))

    subsystem_libname, tempdir = compile_subsystem(args; keep_files)
    scorep_ld_preload_str = _generate_ld_preload_string(args)

    add_to_env_var("LD_LIBRARY_PATH", tempdir)

    ld_preload_prev = get(ENV, "LD_PRELOAD", "")
    ld_preload_str = strip(ld_preload_prev * " " * scorep_ld_preload_str * " " *
                           subsystem_libname)
    if !isempty(ld_preload_prev)
        @warn("LD_PRELOAD isn't empty. This might lead to errors.")
    end
    ENV["SCOREP_JL_LD_PRELOAD_BACKUP"] = ld_preload_prev
    ENV["LD_PRELOAD"] = ld_preload_str

    @debug("LD_LIBRARY_PATH changes: $(_env_var_changes("LD_LIBRARY_PATH", prev_env))")
    @debug("LD_PRELOAD changes: $(_env_var_changes("LD_PRELOAD", prev_env))")
    return nothing
end
