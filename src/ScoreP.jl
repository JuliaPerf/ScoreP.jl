module ScoreP

using Logging

const libscorep_adapter_user_event = "/upb/departments/pc2/users/b/bauerc/.local/lib/libscorep_adapter_user_event.so"

include("utility.jl")
include("LibScoreP.jl")
using .LibScoreP
include("jlwrapper.jl")
include("subsystem.jl")
include("main.jl")

end # module ScoreP
