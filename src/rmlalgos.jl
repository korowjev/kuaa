abstract type RecursiveLikelihoodAlgo <: OnlineAlgo end

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
end

function step!(algo::RMLAlgo, ctx::ARMAContext, y::Float64)
    phit = [ctx.lastobs; -ctx.lasterrs] #esta mal el error que tomo
    newpsi = zeros(length(phit))
    newpsi += phit
    for i in algo.pdim+1:length(algo.β)
        newpsi += algo.β[i] * algo.oldpsis[:,i-algo.pdim]
    end
    algo.R += algo.γ * (newpsi * newpsi' - algo.R)
    e = y - algo.β' * phit
    algo.β += algo.γ * inv(algo.R) * newpsi * e
    for i in 2:size(algo.oldpsis)[2]
        algo.oldpsis[:,i] = algo.oldpsis[:,i-1]
    end
    algo.oldpsis[:,1] = newpsi
end

function update!(algo::RMLAlgo, spec::ModelSpec, ctx::Context, y::Float64)
    step!(algo, ctx, y)
    fromvec!(spec, [[0]; algo.β; [1]])
    ctxupdate!(ctx, spec, y)
end
