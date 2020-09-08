abstract type OnlineGradientAlgo <: OnlineAlgo end


function unpack(d::PipelineDrop{<:ModelSpec, <:Context, <:OnlineAlgo, <:Observation})
    (d.spec, d.ctx, d.algo, d.obs)
end

function setup(d::PipelineDrop{<:ModelSpec, <:Context, <:OnlineGradientAlgo, <:Observation})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    g = gradient(spec₀, ctx₀, obs)
    algo₁ = typeof(algo₀)(algo₀, g)
    PipelineDrop(spec₀, ctx₀, algo₁, obs)
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

function step(d::PipelineDrop{<:ModelSpec, <:Context, OnlineNewtonStep, <:Observation})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    A₁ = algo₀.A + algo₀.g*algo₀.g'
    x₁ = algo₀.x - 1/algo₀.γ * A₁^-1 * algo₀.g
    algo₁ = OnlineNewtonStep(x₁, algo₀.g, algo₀.γ, A₁, algo₀.ϵ)
    PipelineDrop(spec₀, ctx₀, algo₁, obs)
end

