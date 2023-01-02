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
