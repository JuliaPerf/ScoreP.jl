function scorep_main(args = String[]; keep_files = false)
    if !isempty(ARGS)
        # TODO: process arguments / pass them on to scorep-config
    end

    if !(lowercase(get(ENV, "SCOREP_JL_INITIALISED", "false")) == "true")
        prepare_environment(args; keep_files)
        ENV["SCOREP_JL_INITIALISED"] = "true"
        restart_julia_inplace()
    else
        restore_ld_preload()
    end

    @debug "LEAVING scorep_main"
    return nothing
end

function restart_julia_inplace()
    # julia = jlopts.julia_bin |> unsafe_string
    julia = joinpath(Sys.BINDIR, Base.julia_exename())
    jlopts = Base.JLOptions()
    sysimg = jlopts.image_file |> unsafe_string
    scriptname = PROGRAM_FILE

    project_str = "--project=" * Base.active_project()
    sysimg_str = "-J" * sysimg
    args = [project_str, sysimg_str]

    if jlopts.fast_math == 1
        push!(args, "--math-mode=fast")
    end
    if jlopts.check_bounds == 1
        push!(args, "--check-bounds=yes")
    elseif jlopts.check_bounds == 2
        push!(args, "--check-bounds=no")
    end
    # TODO support more / all julia command line options. Incomplete but we might be able
    # to copy code from Base.julia_cmd().

    if !isempty(scriptname) # interactive REPL
        append!(args, [scriptname, ARGS...])
    else
        append!(args, [ARGS...])
    end

    @debug("execve", julia, args)
    execve(julia, args, ENV)
end

"""
Compiles the subsystem (shared library) in a temporary directory, adds this tempdir to
`LD_LIBRARY_PATH`,
"""
function prepare_environment(args = String[]; keep_files = false)
    if contains(get(ENV, "LD_PRELOAD", ""), "libscorep")
        error("`LD_PRELOAD` already contains libscorep libraries. Aborting.")
    end

    if !("--user" in args)
        push!(args, "--user")
    end

    # debugging
    prev_env = copy(ENV)
    @debug("prepare_environment", join(args, ' '))

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
