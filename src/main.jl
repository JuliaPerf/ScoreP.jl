function scorep_main()
    if !isempty(ARGS)
        # TODO: process arguments / pass them on to scorep-config
    end

    if !get(ENV, "SCOREP_JL_INITIALISED", false)
        # TODO init subsystem
        # ENV["SCOREP_JL_INITIALISED"] = true
    else
        restore_ld_preload()
    end
    return nothing
end

function prepare_environment(args; keep_files = false)
    if contains(get(ENV, "LD_PRELOAD", ""), "libscorep")
        error("`LD_PRELOAD` already contains libscorep libraries. Aborting.")
    end

    if !("--user" in args)
        push!(args, "--user")
    end

    @debug("prepare_environment", join(args, ' '))

    subsystem_libname, tempdir = compile_subsystem(args; keep_files)
    ld_preload_str = generate_ld_preload_string(args)
end
