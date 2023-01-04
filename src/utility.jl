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

# function set_ld_preload(value::AbstractString)
#     if !haskey(ENV, "SCOREP_JL_LD_PRELOAD_BACKUP") ||
#        isempty(ENV["SCOREP_JL_LD_PRELOAD_BACKUP"])
#         ENV["SCOREP_JL_LD_PRELOAD_BACKUP"] = value
#     else
#         # Do we want to throw an error here?
#         # error("`SCOREP_JL_LD_PRELOAD_BACKUP` already set. Aborting.")
#     end
#     return nothing
# end

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
function execv(path::AbstractString, args::Vector{String})
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
function execvp(filename::AbstractString, args::Vector{String})
    args = maybe_prepend(args, filename)
    posix_execvp(filename, args)
end
function posix_execvp(filename::AbstractString, argv::AbstractVector{<:AbstractString})
    @ccall execvp(filename::Ptr{Cchar}, argv::Ptr{Ptr{Cchar}})::Cint
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
function restart_julia_inplace()
    # julia = jlopts.julia_bin |> unsafe_string
    julia = joinpath(Sys.BINDIR, Base.julia_exename())
    jlopts = Base.JLOptions()
    sysimg = jlopts.image_file |> unsafe_string
    scriptname = PROGRAM_FILE

    project_str = "--project=" * Base.active_project()
    sysimg_str = "-J" * sysimg
    args = [project_str, sysimg_str, "--quiet"]

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

    println()
    @debug("execve", julia, args)
    execve(julia, args, ENV)
end
