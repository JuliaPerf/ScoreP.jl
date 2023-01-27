using ScoreP
ScoreP.init()

using MPI

function main()
    MPI.Init(; threadlevel = :funneled)

    rank = MPI.Comm_rank(MPI.COMM_WORLD)

    @scorep_user_region "nonuniform sleep" sleep(2 * (rank + 1))

    MPI.Finalize()
end

main()
