using ScoreP
using Test

function localenv(f)
    old_env = copy(ENV)
    try
        f()
    finally
        for (k, v) in ENV
            if !haskey(old_env, k)
                delete!(ENV, k)
            end
        end
        for (k, v) in old_env
            ENV[k] = v
        end
    end
end

@testset "_execute" begin
    ret, out, err = ScoreP._execute(`echo test`)
    @test ret == 0
    @test out == "test\n"
    @test err == ""
end

@testset "add_to_env_var" begin localenv() do
    var = "SCOREP_JL_TESTVAR"
    @test !haskey(ENV, var)
    @test isnothing(ScoreP.add_to_env_var(var, "/this/is/a/test"))
    @test haskey(ENV, var)
    @test ENV[var] == "/this/is/a/test"
    ScoreP.add_to_env_var(var, "/usr/bin/whatever")
    @test ENV[var] == "/usr/bin/whatever:/this/is/a/test"
    ScoreP.add_to_env_var(var, "/usr/bin/whatever")
    @test ENV[var] == "/usr/bin/whatever:/usr/bin/whatever:/this/is/a/test"
    ScoreP.add_to_env_var(var, "/usr/bin/whatever"; avoid_duplicates = true)
    @test ENV[var] == "/usr/bin/whatever:/usr/bin/whatever:/this/is/a/test"
end end

@testset "restore_ld_preload" begin localenv() do
    ENV["LD_PRELOAD"] = ""
    ENV["SCOREP_JL_LD_PRELOAD_BACKUP"] = ""
    @test isnothing(ScoreP.restore_ld_preload())
    @test !haskey(ENV, "LD_PRELOAD")

    ENV["LD_PRELOAD"] = ""
    ENV["SCOREP_JL_LD_PRELOAD_BACKUP"] = "asdf"
    @test isnothing(ScoreP.restore_ld_preload())
    @test ENV["LD_PRELOAD"] == "asdf"

    delete!(ENV, "LD_PRELOAD")
    ENV["SCOREP_JL_LD_PRELOAD_BACKUP"] = "asdf"
    @test isnothing(ScoreP.restore_ld_preload())
    @test ENV["LD_PRELOAD"] == "asdf"
end end
