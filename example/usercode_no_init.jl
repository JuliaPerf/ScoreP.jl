# User code, no ScoreP initialisation.
println("User Code!")
@show ARGS

A = rand(1000, 1000)
B = rand(1000, 1000)

A * B

function f(x)
    s = zero(eltype(x))
    for i in eachindex(x)
        s += sqrt(abs(x[i]))
    end
    return s
end

f(A)
