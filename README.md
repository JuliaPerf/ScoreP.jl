# ScoreP.jl

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

## Acknowledgements

* The Python analogon [scorep_binding_python](https://github.com/score-p/scorep_binding_python) was as a valuable resource for inspiration.