using TestItemRunner

# Threads.nthreads() ≥ 4 ||
#     error("At least 4 Julia threads necessary. Forgot to set `JULIA_NUM_THREADS`?")

@run_package_tests

@testitem "utility" begin include("utility_tests.jl") end
