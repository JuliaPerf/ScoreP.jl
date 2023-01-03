module ScoreP

const libscorep_adapter_user_event = "/upb/departments/pc2/users/b/bauerc/.local/lib/libscorep_adapter_user_event.so"

include("LibScoreP.jl")
using .LibScoreP
include("utility.jl")
include("subsystem.jl")

end # module ScoreP
