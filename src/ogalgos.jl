abstract type OnlineGradientAlgo <: OnlineAlgo end

mutable struct OnlineNewtonStep <: OnlineGradientAlgo
    γ::Float64
    ϵ::Float64
    x::Array{Float64, 1}
    A::Array{Float64, 2}

    function OnlineNewtonStep(gamma::Float64, epsilon::Float64, dim::Int)
        x = zeros(dim)
        A = Array(I(dim) * 1.0) .* epsilon
        new(gamma, epsilon, x, A)
    end
end

function step!(algo::OnlineNewtonStep, g::Array{Float64, 1})
    algo.A += g*g'
    algo.x -= 1/algo.γ * algo.A^-1 * g
end

function update!(spec::ModelSpec, ctx::Context, algo::OnlineGradientAlgo, y::Float64)
    g = gradient(spec, ctx, y)
    step!(algo, g)
    fromvec!(spec, algo.x)
end
