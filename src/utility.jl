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
function add_to_env_var(envvar::AbstractString, path::AbstractString)
    value = get(ENV, envvar, "")
    if isempty(value)
        ENV[envvar] = path
    else
        ENV[envvar] = join((value, path), ':')
    end
    return nothing
end

"Restore `LD_PRELOAD` based on `SCOREPJL_LD_PRELOAD_BACKUP`."
function restore_ld_preload()
    if haskey(ENV, "SCOREPJL_LD_PRELOAD_BACKUP")
        if ENV["SCOREPJL_LD_PRELOAD_BACKUP"] == ""
            delete!(ENV, "LD_PRELOAD")
        else
            ENV["LD_PRELOAD"] = ENV["SCOREPJL_LD_PRELOAD_BACKUP"]
        end
    end
    return nothing
end

# function set_ld_preload(value::AbstractString)
#     if !haskey(ENV, "SCOREPJL_LD_PRELOAD_BACKUP") ||
#        isempty(ENV["SCOREPJL_LD_PRELOAD_BACKUP"])
#         ENV["SCOREPJL_LD_PRELOAD_BACKUP"] = value
#     else
#         # Do we want to throw an error here?
#         # error("`SCOREPJL_LD_PRELOAD_BACKUP` already set. Aborting.")
#     end
#     return nothing
# end

# The exec* family of functions, check out the following for an overview:
#     https://docs.python.org/3/library/os.html#os.execl

# execv
"Inherits the environment variables."
function execv(path::AbstractString, args::Vector{String})
    if isempty(args) || args[1] != path
        args = copy(args)
        prepend!(args, Ref(path))
    end
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
    if isempty(args) || args[1] != path
        args = copy(args)
        prepend!(args, Ref(path))
    end
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
    if isempty(args) || args[1] != filename
        args = copy(args)
        prepend!(args, Ref(filename))
    end
    posix_execvp(filename, args)
end
function posix_execvp(filename::AbstractString, argv::AbstractVector{<:AbstractString})
    @ccall execvp(filename::Ptr{Cchar}, argv::Ptr{Ptr{Cchar}})::Cint
end
