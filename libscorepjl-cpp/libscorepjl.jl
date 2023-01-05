# libscorep_jlwrap = joinpath(@__FILE__, "libscorep_jlwrap.so")
libscorep_jlwrap = joinpath(pwd(), "libscorep_jlwrap.so")

# Tested: Seems to work. After ScoreP.init() this returns without error / segfault.
function region_begin(region_name, filename, line_number)
    @ccall libscorep_jlwrap.region_begin(region_name::Ptr{Cchar},
                                         filename::Ptr{Cchar},
                                         line_number::Culong)::Cvoid
end
