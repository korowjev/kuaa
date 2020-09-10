abstract type RecursiveLikelihoodAlgo <: OnlineAlgo end

function setup(d::OAlgoFlow{<:RecursiveLikelihoodAlgo})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    PipelineFlow(spec₀, ctx₀, algo₀, obs)
end



mutable struct RMLAlgo <: RecursiveLikelihoodAlgo
    γ::Float64
    ϵ::Float64
    ψ::Array{Float64, 1}
    β::Array{Float64, 1}
    R::Array{Float64, 2}
    oldpsis::Array{Float64, 2}
    pdim::Int

    function RMLAlgo(gamma::Float64, epsilon::Float64, pdim::Int, mdim::Int)
        beta = zeros(mdim)
        psi = zeros(mdim)
        R = Array(I(mdim) * 1.0) .* epsilon
        ops = zeros(mdim, mdim-pdim)
        new(gamma, epsilon, psi, beta, R, ops, pdim)
    end

    function RMLAlgo(g::Float64, e::Float64, ps, b, R, op, pd)
        new(g,e,ps,b,R,op,pd)
    end
end

function step(d::OAlgoFlow{<:RMLAlgo})
    spec, ctx, algo, obs = unpack(d)
    phit = [ctx.lastobs; -ctx.lasterrs] #esta mal el error que tomo
    newpsi = zeros(length(phit))
    newpsi += phit
    for i in algo.pdim+1:length(algo.β)
        newpsi += algo.β[i] * algo.oldpsis[:,i-algo.pdim]
    end
    R₁ = algo.R + algo.γ * (newpsi * newpsi' - algo.R)
    e = obs - algo.β' * phit
    β₁ = algo.β + algo.γ * inv(algo.R) * newpsi * e
    oldpsis = zeros(size(algo.oldpsis))
    for i in 2:size(algo.oldpsis)[2]
        oldpsis[:,i] = algo.oldpsis[:,i-1]
    end
    oldpsis[:,1] = newpsi
    algo₁ = RMLAlgo(algo.γ, algo.ϵ, newpsi, β₁, R₁, oldpsis, algo.pdim)
    PipelineFlow(spec, ctx, algo₁, obs)
end
