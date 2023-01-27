# ScoreP.jl

![](https://img.shields.io/badge/lifecycle-experimental-red.svg)

*Tracing and profiling Julia code with [Score-P](https://www.vi-hps.org/projects/score-p)*

## Install

### ScoreP.jl (Julia Interface)

```julia
] add https://github.com/JuliaPerf/ScoreP.jl
```

### Score-P (Parent Software)

```
wget https://perftools.pages.jsc.fz-juelich.de/cicd/scorep/tags/scorep-7.1/scorep-7.1.tar.gz
tar -xf scorep-7.1.tar.gx
cd scorep-7.1/
mkdir build
cd build
../configure --enable-shared
make -j 4
sudo make install
```

**Note:** You might want to also provide a `--prefix=/my/user/dir/` to `configure` to install into non-global user directory. In this case, you can drop the `sudo` in the last line.

## Basics

### Profiling

```julia
# example.jl
using ScoreP
ScoreP.init()

# ScoreP initialization must come before anything else!

X = rand(100_000)

@scorep_user_region "sin" X .= sin.(X)

@scorep_user_region "code block" begin
    @scorep_user_region "allocs" begin
        A = rand(1000,1000)
        B = rand(1000,1000)
    end
    @scorep_user_region "loop" begin
        for _ in 1:10
            A * B
        end
    end
end
```

Running this (`julia example.jl`) generates a folder, e.g., `scorep-20230127_1603_20921538990107094` (you can set `export SCOREP_EXPERIMENT_DIRECTORY=foldername` to choose a specific folder name up-front). In it is a `profile.cubex` file which contains the profiling information. You can open `.cubex` files with [Cube](https://www.scalasca.org/scalasca/software/cube-4.x/download.html). For the example above, this should give you something like this:

<img alt="ex_basic_cube" src="https://user-images.githubusercontent.com/187980/215124028-9d5cc801-f937-4a96-9d22-5543a365cec0.png">

### Profiling + Tracing

Running the same example with `export SCOREP_ENABLE_TRACING=true` the output folder will besides the profiling results contain tracing information as well, specifically, a file `traces.otf2`. The latter can be opened with the (commerical) software [Vampir](https://vampir.eu/) and should give you something like the following.

<img alt="ex_basic_vampir" src="https://user-images.githubusercontent.com/187980/215124135-e3eba293-560d-474f-a3b5-b99e6cb8f07c.png">

On Linux and Windows, it should also be possible to use the [Intel Trace Analyzer](https://www.intel.com/content/www/us/en/developer/tools/oneapi/trace-analyzer.html#gs.oc8bgr) or other OTF2 visualizers.

## MPI

```julia
# mpi_example.jl
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
```

<img alt="ex_mpi_cube" src="https://user-images.githubusercontent.com/187980/215132355-5bb86fd8-f637-4467-a79a-41d12b3990bc.png">
<img alt="ex_mpi_vampir" src="https://user-images.githubusercontent.com/187980/215132435-1a3ec376-37d0-417f-b31b-8fe77a5e96e7.png">

## Score-P Ecosystem

![](https://github.com/JuliaPerf/ScoreP.jl/raw/main/scorep_ecosystem.png)

## Acknowledgements

* The Python analogon [scorep_binding_python](https://github.com/score-p/scorep_binding_python) was as a valuable resource for inspiration.

## Credits

This package is an effort by the [Paderborn Center for Parallel Computing (PC²)](https://pc2.uni-paderborn.de/).
