module ScoreP

using Logging
using Preferences
using Libdl

const library_path = @load_preference("library_path", nothing)

if !isnothing(library_path)
    const libscorep_adapter_user_event = joinpath(library_path, "libscorep_adapter_user_event.so")
else
    const libscorep_adapter_user_event = "libscorep_adapter_user_event.so"
end

function set_library_path(library_path)
    @set_preferences!("library_path" => library_path)
    @info("New library path set; please restart Julia to see this take effect", library_path)
end

include("utility.jl")
include("LibScoreP.jl")
using .LibScoreP
include("jlwrapper.jl")
include("subsystem.jl")
include("main.jl")

export LibScoreP,
       @scorep_user_region

end # module ScoreP
