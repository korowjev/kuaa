abstract type OnlineGradientAlgo <: OnlineAlgo end

function setup!(algo₀::OnlineGradientAlgo, spec::ModelSpec, ctx::Context, y::Float64)
    g = gradient(spec, ctx, y)
    algo₁ = typeof(algo₀)(algo₀, g)
    (algo₁, spec, ctx)
end

struct OnlineNewtonStep <: OnlineGradientAlgo
    x::Array{Float64, 1}
    g::Array{Float64, 1}
    γ::Float64
    A::Array{Float64, 2}
    ϵ::Float64

    function OnlineNewtonStep(gamma::Float64, epsilon::Float64, dim::Int)
        x = zeros(dim)
        g = zeros(dim)
        A = Array(I(dim) * 1.0) .* epsilon
        new(x, g, gamma, A, epsilon)
    end

    function OnlineNewtonStep(x, g, ga, a, eps)
        new(x, g, ga, a, eps)
    end

    function OnlineNewtonStep(cp₀::OnlineNewtonStep, g::Array{Float64, 1})
        new(cp₀.x, g, cp₀.γ, cp₀.A, cp₀.ϵ)
    end
    
end

function step!(algo::OnlineNewtonStep)
    A₁ = algo.A + algo.g*algo.g'
    x₁ = algo.x - 1/algo.γ * A₁^-1 * algo.g
    OnlineNewtonStep(x₁, algo.g, algo.γ, A₁, algo.ϵ)
end

