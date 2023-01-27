using ScoreP
ScoreP.init()

using MPI
using Printf

function get_arguments(rank, com_size)
    if rank == 0
        a = parse(Float64, get(ARGS, 1, "0.0"))
        b = parse(Float64, get(ARGS, 2, "1.0"))
        n = parse(Int, get(ARGS, 3, "1000000000"))

        for dest in 1:(com_size - 1)
            MPI.Send(a, dest, 0, MPI.COMM_WORLD)
            MPI.Send(b, dest, 0, MPI.COMM_WORLD)
            MPI.Send(n, dest, 0, MPI.COMM_WORLD)
        end
    else
        a, = MPI.Recv(Float64, 0, 0, MPI.COMM_WORLD)
        b, = MPI.Recv(Float64, 0, 0, MPI.COMM_WORLD)
        n, = MPI.Recv(Int, 0, 0, MPI.COMM_WORLD)
    end
    return a, b, n
end

f(x) = x * x

F(x) = x^3 / 3

function integrate(left, right, count, len)
    estimate = (f(left) + f(right)) / 2.0
    for i in 1:(count - 1)
        x = left + i * len
        estimate += f(x)
    end
    return estimate * len
end

function main()
    MPI.Init(; threadlevel = :funneled) # threadlevel <= funneled required for ScoreP!

    rank = MPI.Comm_rank(MPI.COMM_WORLD)
    com_size = MPI.Comm_size(MPI.COMM_WORLD)

    @scorep_user_region "integration" begin

        @scorep_user_region "get_arguments" a, b, n=get_arguments(rank, com_size)

        @scorep_user_region "local integration" begin
            # h and local_n are the same for all processes
            h = (b - a) / n
            local_n = n / com_size

            # compute integration boundaries for each rank
            local_a = a + rank * local_n * h
            local_b = local_a + local_n * h

            # compute integral in bounds for each rank
            local_int = integrate(local_a, local_b, local_n, h)
        end

        @scorep_user_region "collect results" begin
            if rank != 0
                # Worker: send local result to master
                MPI.Send(local_int, 0, 0, MPI.COMM_WORLD)
            else
                # Master: add up results
                total_int = local_int
                for src in 1:(com_size - 1)
                    worker_int, = MPI.Recv(Float64, src, 0, MPI.COMM_WORLD)
                    total_int += worker_int
                end
            end
        end
    end

    # Master: print result
    if rank == 0
        @printf("With n = %d trapezoids, our estimate of the integral from %f to %f is %.12e (exact: %f)\n",
                n, a, b, total_int, F(b)-F(a))
    end

    MPI.Finalize()
end

# run main function
main()
