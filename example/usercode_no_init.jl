# User code, no ScoreP initialisation.
println("User Code!")
@show ARGS

using ScoreP # optional / no-op
using LinearAlgebra

function workload(iter, N = 1000)
    A = rand(N, N)
    B = rand(N, N)
    C = rand(N, N)
    for _ in 1:iter
        mul!(C, A, B)
    end
    return C
end

function workload_multithreaded(iter, N = 1000)
    @assert Threads.nthreads() > 1
    A = rand(N, N)
    B = rand(N, N)
    Cs = [zeros(N, N) for _ in 1:Threads.nthreads()]
    Threads.@threads :static for tid in 1:Threads.nthreads()
        for _ in 1:iter
            mul!(Cs[tid], A, B)
        end
    end
    return Cs
end

# warmup
workload(10, 1)

@scorep_user_region_stored "matmul" workload(500)
@scorep_user_region_stored "matmul large" workload(5000)
@scorep_user_region_stored "matmuls multithreaded" workload_multithreaded(500)
