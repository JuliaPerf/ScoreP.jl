"Generate string for LD_PRELOAD"
function scorep_config_generate_ld_preload(args = String[])
    if !("--user" in args)
        push!(args, "--user")
    end
    _, preload_str, _ = _execute(`scorep-config $args --preload-libs`)
    return strip(preload_str)
end

"Generate string for LD_PRELOAD"
function scorep_config_generate_compile_deps(args = [])
    scorep_config = `scorep-config $args --user`

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
