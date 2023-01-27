# ScoreP.jl

*Tracing and profiling Julia code with [Score-P](https://www.vi-hps.org/projects/score-p)*

**This package is currently in pre-alpha condition. Don't expect anything to work!**

## Demo

### Basics

#### Profiling

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

#### Profiling + Tracing

Running the same example with `export SCOREP_ENABLE_TRACING=true` the output folder will besides the profiling results contain tracing information as well, specifically, a file `traces.otf2`. The latter can be opened with the (commerical) software [Vampir](https://vampir.eu/) and should give you something like the following.

<img alt="ex_basic_vampir" src="https://user-images.githubusercontent.com/187980/215124135-e3eba293-560d-474f-a3b5-b99e6cb8f07c.png">

On Linux and Windows, it should also be possible to use the [Intel Trace Analyzer](https://www.intel.com/content/www/us/en/developer/tools/oneapi/trace-analyzer.html#gs.oc8bgr) or other OTF2 visualizers.


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

## Score-P Ecosystem

![](https://github.com/JuliaPerf/ScoreP.jl/raw/main/scorep_ecosystem.png)

## Acknowledgements

* The Python analogon [scorep_binding_python](https://github.com/score-p/scorep_binding_python) was as a valuable resource for inspiration.

## Credits

This package is an effort by the [Paderborn Center for Parallel Computing (PC²)](https://pc2.uni-paderborn.de/).
