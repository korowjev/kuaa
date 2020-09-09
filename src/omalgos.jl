abstract type OnlineMomentAlgo <: OnlineAlgo end

function setup(d::OAlgoFlow{<:OnlineMomentAlgo})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    eqs₁ = getmeqs(spec)
    moments, automs = updatemoments(algo₀, obs, ctx₀)
    algo₁ = typeof(algo₀)(algo₀, moments, automs, eqs₁)
    PipelineFlow(spec₀, ctx₀, algo₁, obs)
end

function updatemoments(algo::OnlineMomentAlgo, y::Float64, ctx::Context)
    ms = length(algo.moments)
    moments = algo.moments + algo.γ * (y.^(1:ms) .- algo.moments)
    automs = algo.automs + algo.γ * (y*ctx.lastobs - algo.automs)
    (moments, automs)
end

mutable struct OnlineMethodMoments <: OnlineMomentAlgo
    γ::Float64
    moments::Array{Float64, 1}
    automs::Array{Float64, 1}
    eqs::Union{Function, Nothing}
    x::Array{Float64, 1}
    
    function OnlineMethodMoments(gamma::Float64, dim::Int, mdim::Int, adim::Int)
        m = zeros(mdim)
        am = zeros(adim)
        x = zeros(dim)
        new(gamma, m, am, nothing, x)
    end

    function OnlineMethodMoments(cp₀::OnlineMethodMoments, m, a, e)
        new(cp₀.γ, m, a, e, cp₀.x)
    end

    
    function OnlineMethodMoments(g, m, a, e, x)
        new(g, m, a, e, x)
    end

end

function step(d::OAlgoFlow{<:OnlineMethodMoments})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    x₁ = algo₀.eqs(algo₀.moments, algo₀.automs)
    algo₁ = OnlineMethodMoments(algo₀.γ, algo₀.moments, algo₀.automs, algo₀.eqs, x₁)
    PipelineFlow(spec₀, ctx₀, algo₁, obs)
end
