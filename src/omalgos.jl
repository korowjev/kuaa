abstract type OnlineMomentAlgo <: OnlineAlgo end

function setup!(algo::OnlineMomentAlgo, spec::ModelSpec, ctx::Context, y::Float64)
    if isnothing(algo.eqs)
        algo.eqs = getmeqs(spec)
    end
    updatemoments!(algo, y, ctx)
end

function updatemoments!(algo::OnlineMomentAlgo, y::Float64, ctx::Context)
    ms, cs = length(algo.moments), length(algo.automs)
    for i in 1:ms
        algo.moments[i] += algo.γ * (y^i - algo.moments[i])
    end
    for i in 1:cs
        algo.automs[i] += algo.γ * (y*ctx.lastobs[i] - algo.automs[i])
    end
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
end

function step!(algo::OnlineMethodMoments)
    algo.x = algo.eqs(algo.moments, algo.automs)
end
