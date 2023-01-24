using ScoreP
ScoreP.init()

using MPI
using LinearAlgebra

function main()
    MPI.Init(; threadlevel = :funneled)

    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    # warmup
    workload(10, 1)

    handle = ScoreP.region_begin("matmul nonuniform")
    sleep(2 * (rank + 1))
    ScoreP.region_end(handle)

    MPI.Finalize()
end

main()
