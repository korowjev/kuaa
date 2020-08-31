abstract type OnlineMomentAlgo <: OnlineAlgo end

mutable struct OnlineMethodMoments <: OnlineMomentAlgo
    γ::Float64
    moments::Array{Float64, 1}
    automs::Array{Float64, 1}

    function OnlineMethodMoments(gamma::Float64, mdim::Int, adim::Int)
        m = zeros(mdim)
        am = zeros(adim)
        new(gamma, m, am)
    end
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

function solveparams(algo::OnlineMomentAlgo, eqs::Function)
    eqs(algo.moments, algo.automs)
end


function update!(spec::ModelSpec, ctx::Context, algo::OnlineMomentAlgo, y::Float64)
     updatemoments!(algo, y, ctx)
     eqs = getmeqs(spec)
     pars = solveparams(algo, eqs)
     fromvec!(spec, pars)
end
