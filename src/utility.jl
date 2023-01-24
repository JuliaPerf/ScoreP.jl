"Run a command and return exit code, stdout, and stderr (in this order) as a named tuple."
function _execute(cmd::Cmd)
    out = Pipe()
    err = Pipe()

    process = run(pipeline(ignorestatus(cmd); stdout = out, stderr = err))
    close(out.in)
    close(err.in)

    out = (exitcode = process.exitcode, stdout = String(read(out)),
           stderr = String(read(err)))
    return out
end

"Returns the name of the function this is macro is used in as a symbol."
macro __FUNCTION__()
    quote
        st = StackTraces.stacktrace()
        idx = findfirst(s -> !(s.func in (Symbol("macro expansion"),)), st)
        if !isnothing(idx)
            st[idx].func
        else
            "UNKNOWN_FUNCTION"
        end
    end
end

isactive() = lowercase(get(ENV, "SCOREP_JL_INITIALISED", "")) == "true"

"""
Can be used to set the global logging level to either `:debug`, `:warn`, or
`:info`. The default level in Julia is essentially `:warn`.

Replaces the global logger with a `ConsoleLogger` with the appropriate logging level.
"""
function set_logging_level(level)
    if level == :debug || level == Logging.Debug
        logger = Logging.ConsoleLogger(stderr, Logging.Debug)
    elseif level in (:warn, :default) || level == Logging.Warn
        logger = Logging.ConsoleLogger(stderr, Logging.Warn)
    elseif level == :info || level == Logging.Info
        logger = Logging.ConsoleLogger(stderr, Logging.Info)
    else
        throw(ArgumentError("Unknown logging level. Supported are `:debug`, `:warn`, " *
                            "and `:info`."))
    end
    Logging.global_logger(logger)
    return nothing
end

"Replace `ARGS` by the given vector of strings."
function setARGS(args::AbstractVector{<:AbstractString})
    resize!(ARGS, length(args))
    @assert length(ARGS) == length(args)
    for i in eachindex(args)
        ARGS[i] = args[i]
    end
    return nothing
end

function _is_results_dir(dir)
    # scorep-20230105_0959_16318275631842706
    regex = r"scorep-(failed-)?[0-9]+_[0-9]+_[0-9]+"
    return !isnothing(match(regex, dir))
end

"""
Removes all folders in the current directory (`pwd()`) that match the regex pattern
`scorep-(failed-)?[0-9]+_[0-9]+_[0-9]+`.
"""
function cleanup_results()
    for rdir in filter(_is_results_dir, readdir())
        rm(rdir; recursive = true)
        @info("Removed $rdir")
    end
    return nothing
end

"""
Removes the temporary directory used for compiling the subsystem based on the environment
variable `SCOREP_JL_COMPILATION_DIR`.
"""
function cleanup_subsystem()
    tempdir = get(ENV, "SCOREP_JL_COMPILATION_DIR", nothing)
    if !isnothing(tempdir) && isdir(tempdir)
        rm(tempdir; recursive = true)
    else
        @debug("`SCOREP_JL_COMPILATION_DIR` not set. Thus, can't delete anything.")
    end
    return nothing
end

"""
Deletes all subsystem compilation directories, that is, all directories starting with
"scorep_jl." in `/tmp` (or its analogon for the present OS/platform).
"""
function cleanup_subsystem_all()
    # figure out /tmp dir on this platform
    tmp = mktempdir(; prefix = "scorep_jl.")
    tmp_dir = dirname(tmp)
    rm(tmp; recursive = true)

    # filter out subsystem compilation dirs
    subsys_dirs = filter(startswith("scorep_jl."), readdir(tmp_dir))
    for dir in subsys_dirs
        rm(joinpath(tmp_dir, dir); recursive = true)
        @info("Removed $dir")
    end
    return nothing
end

"""
Deletes
* all results in the current directory,
* all subsystem compilation directories in `/tmp` (or similar).
"""
function cleanup()
    @info("Cleaning up results...")
    cleanup_results()
    println()
    @info("Cleaning up temporary directories...")
    cleanup_subsystem_all()
end

"Add the given `path` to the environment variable `envvar` with colon delimiter (`:`)."
function add_to_env_var(envvar::AbstractString, path::AbstractString;
                        avoid_duplicates = false)
    value = get(ENV, envvar, "")
    if isempty(value)
        ENV[envvar] = path
        return nothing
    end

    if avoid_duplicates && path in split(value, ':')
        return nothing
    end
    ENV[envvar] = join((path, value), ':')
    return nothing
end

"Restore `LD_PRELOAD` based on `SCOREP_JL_LD_PRELOAD_BACKUP`."
function restore_ld_preload()
    if haskey(ENV, "SCOREP_JL_LD_PRELOAD_BACKUP")
        if ENV["SCOREP_JL_LD_PRELOAD_BACKUP"] == "" && haskey(ENV, "LD_PRELOAD")
            delete!(ENV, "LD_PRELOAD")
        else
            ENV["LD_PRELOAD"] = ENV["SCOREP_JL_LD_PRELOAD_BACKUP"]
        end
    end
    return nothing
end

function _env_var_changes(envvar, prev_env, new_env = ENV)
    prev_val = get(prev_env, envvar, "")
    new_val = get(new_env, envvar, "")
    if !isempty(prev_val)
        new_val = replace(new_val, prev_val => "\$$envvar")
    end
    return "$envvar=$new_val"
end

"""
Returns a collection that has `path` as the first element and all other elements as in
`args`. If `path` is already the first element in `args`, nothing is prepended.
"""
function maybe_prepend(args, path)
    if isempty(args) || args[1] != path
        args = copy(args)
        prepend!(args, Ref(path))
    end
    return args
end

# The exec* family of functions, check out the following for an overview:
#     https://docs.python.org/3/library/os.html#os.execl

# execv
"Inherits the environment variables."
function execv(path::AbstractString, args::Vector{String} = String[])
    args = maybe_prepend(args, path)
    posix_execv(path, args)
end
function posix_execv(path::AbstractString, argv::AbstractVector{<:AbstractString})
    @ccall execv(path::Ptr{Cchar}, argv::Ptr{Ptr{Cchar}})::Cint
end

# execve
"""
Does **not** inherit the environment variables. The argument `env` specifies the new
environment and can be a vector of strings in the form `\"key=value\"` or a dictionary.
"""
function execve(path::AbstractString, args::Vector{String}, env::Vector{String})
    args = maybe_prepend(args, path)
    posix_execve(path, args, env)
end
function execve(path, args, env::AbstractDict)
    # convert string into vector of "key=value" strings
    execve(path, args, ["$k=$v" for (k, v) in env])
end
function posix_execve(path::AbstractString, argv::AbstractVector{<:AbstractString},
                      envp::AbstractVector{<:AbstractString})
    @ccall execve(path::Ptr{Cchar}, argv::Ptr{Ptr{Cchar}}, envp::Ptr{Ptr{Cchar}})::Cint
end

# execvp
"""
Looks up `filename` in PATH to find the program to execute. Inherits the environment
variables.
"""
function execvp(filename::AbstractString, args::Vector{String} = String[])
    args = maybe_prepend(args, filename)
    posix_execvp(filename, args)
end
function posix_execvp(filename::AbstractString, argv::AbstractVector{<:AbstractString})
    @ccall execvp(filename::Ptr{Cchar}, argv::Ptr{Ptr{Cchar}})::Cint
    # ccall(:execvp, Cint, (Ptr{Cchar}, Ptr{Ptr{Cchar}}), filename, argv)
end

"""
Replaces the current Julia process by a new one (see `execve`). The new process will have
all environment variables set as in `ENV` at the point of calling the function.

Effectively, this allows one to (seemingly) change `LD_LIBRARY_PATH` and `LD_PRELOAD` while
Julia is running: Modify `ENV` and call this function for an "inplace restart".

*Warning:* To start the new Julia process, this function needs to figure out how Julia was
originally started, i.e., which command line arguments have been provided to `julia`.
Currently not all options will be forwarded to the new process!
"""
function restart_julia_inplace(args = ARGS; load_scorep = true, scorepjl_args = String[])
    # julia binary
    julia = joinpath(Sys.BINDIR, Base.julia_exename())

    # julia arguments (e.g. --project, --check-bounds etc.)
    jl_args = get_julia_args()

    # non julia arguments (e.g. script name, remaining arguments etc.)
    if !isinteractive()
        # script mode (no REPL)
        @assert !isempty(PROGRAM_FILE)
        scriptname = PROGRAM_FILE
        nonjl_args = [scriptname, args...]
    else
        # interactive REPL
        startup_code = ""
        if "--revise" in scorepjl_args || isdefined(Main, :Revise)
            startup_code *= "using Revise;"
        end
        if load_scorep
            startup_code *= "using ScoreP; ScoreP.init();"
        end
        if "--debug" in scorepjl_args
            startup_code *= "using Logging; global_logger(ConsoleLogger(stderr, Logging.Debug));"
        end
        if !isempty(PROGRAM_FILE)
            if endswith(PROGRAM_FILE, "terminalserver.jl")
                # VSCode integrated REPL (exception)
                # @show PROGRAM_FILE
                # pushfirst!(args, "USE_REVISE=true")
                # pushfirst!(args, "ENABLE_SHELL_INTEGRATION=true")
                # pushfirst!(args, "USE_PLOTPANE=true")
                # pushfirst!(args, "USE_PROGRESS=true")
                # pushfirst!(args, "DEBUG_MODE=false")
                # startup_code *= "include(\"$PROGRAM_FILE\");"
                # error("Integrated REPL in VSCode is currently not supported.")
            else
                error("isinteractive() but also !isempty(PROGRAM_FILE). This is " *
                      "currently not supported.")
            end
        end
        nonjl_args = ["-e $startup_code", "-i", args...]
        println() # just minor cosmetics :)
    end

    execve_args = vcat(jl_args, nonjl_args)
    @debug("execve", julia, execve_args)
    execve(julia, execve_args, ENV)
end

function get_julia_args()
    jlopts = Base.JLOptions()
    project_str = "--project=" * Base.active_project()
    sysimg_str = "-J" * unsafe_string(jlopts.image_file)
    jl_args = [project_str, sysimg_str, "--quiet"]

    if jlopts.fast_math == 1
        push!(jl_args, "--math-mode=fast")
    end
    if jlopts.check_bounds == 1
        push!(jl_args, "--check-bounds=yes")
    elseif jlopts.check_bounds == 2
        push!(jl_args, "--check-bounds=no")
    end
    if jlopts.nthreads > 0
        push!(jl_args, "--threads=$(jlopts.nthreads)")
    end

    # -L and others(?)
    jlcmds = Base.unsafe_load_commands(Base.JLOptions().commands)
    idx = findfirst(p -> p[1] == 'L', jlcmds)
    if !isnothing(idx)
        pushfirst!(jl_args, "--load=" * jlcmds[idx][2])
    end

    # TODO support more / all julia command line options. Incomplete but we might be able
    # to copy code from Base.julia_cmd().
    return jl_args
end
