function _generate_ld_preload_string(args = String[])
    if !("--user" in args)
        push!(args, "--user")
    end
    _, preload_str, _ = _execute(`scorep-config $args --preload-libs`)
    return strip(preload_str)
end

function _generate_subsystem_code(args = String[])
    _check_scorep_config_args(args)
    _, code, _ = _execute(`scorep-config $args --adapter-init`)
    return code
end

function _check_scorep_config_args(args = String[])
    scorep_config = `scorep-config $args`
    ret, _, _ = _execute(scorep_config)
    if ret != 0
        throw(ArgumentError("Given scorep-config `args` aren't supportet (led to non-zero "
                            *
                            "exit code)."))
    end
    return nothing
end

function _generate_compile_deps(args = String[])
    _check_scorep_config_args(args)
    scorep_config = `scorep-config $args`

    _, ldflags, _ = _execute(`$scorep_config --ldflags`)
    _, libs, _ = _execute(`$scorep_config --libs`)
    _, mgmt_libs, _ = _execute(`$scorep_config --mgmt-libs`)
    _, cflags, _ = _execute(`$scorep_config --cflags`)

    libs = " " * strip(libs) * " " * strip(mgmt_libs)
    ldflags = " " * strip(ldflags)
    cflags = " " * strip(cflags)

    libdir = [m.match[4:end] for m in eachmatch(r" -L[/+-@.\w]*", ldflags)]
    lib = [m.match[2:end] for m in eachmatch(r" -l[/+-@.\w]*", libs)]
    cinclude = [m.match[4:end] for m in eachmatch(r" -I[/+-@.\w]*", cflags)]
    cmacro = [(m.match[4:end], 1) for m in eachmatch(r" -D[/+-@.\w]*", cflags)]
    linker_flags = [m.match[2:end] for m in eachmatch(r" -Wl[/+-@.\w]*", ldflags)]

    return (cinclude = cinclude, lib = lib, libdir = libdir, cmacro = cmacro,
            linker_flags = linker_flags)
end

_subsystem_lib_name() = "libscorep_init_subsystem_julia$(VERSION).so"

function compile_subsystem(args = String[]; keep_files = false)
    cinclude, lib, libdir, cmacro, linker_flags = _generate_compile_deps(args)
    scorep_init_code = _generate_subsystem_code(args)
    # @debug scorep_init_code

    # PYTHON:
    # if ("-lscorep_adapter_opari2_mgmt" in lib):
    #     scorep_adapter_init += "\n"
    #     scorep_adapter_init += "/* OPARI dependencies */\n"
    #     scorep_adapter_init += "void POMP2_Init_regions(){}\n"
    #     scorep_adapter_init += "size_t POMP2_Get_num_regions(){return 0;};\n"
    #     scorep_adapter_init += "void POMP2_USER_Init_regions(){};\n"
    #     scorep_adapter_init += "size_t POMP2_USER_Get_num_regions(){return 0;};\n"

    # TODO: linker_flags stuff

    tempdir = mktempdir(; prefix = "scorep_jl.", cleanup = !keep_files)
    ENV["SCOREP_JL_COMPILATION_DIR"] = tempdir
    @debug("SCOREP_JL_COMPILATION_DIR: $tempdir")

    scorep_init_c_filepath = joinpath(tempdir, "scorep_init.c")
    open(scorep_init_c_filepath, "w") do f
        write(f, scorep_init_code)
    end
    @debug("Created `$(scorep_init_c_filepath))`")

    libname = _subsystem_lib_name()
    cd(tempdir) do
        # compile
        run(`gcc -c scorep_init.c -o scorep_init.o`)

        # link
        libdir_prefixed = ["-L" * d for d in libdir]
        include_prefixed = ["-I" * i for i in cinclude]
        push!(linker_flags, "-Wl,-no-as-needed")
        link_cmd = `gcc scorep_init.o -shared -o $libname $include_prefixed $libdir_prefixed $lib $linker_flags`
        @debug("Link cmd: $link_cmd")
        run(link_cmd)
    end

    return libname, tempdir
end
