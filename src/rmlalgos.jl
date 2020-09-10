abstract type RecursiveLikelihoodAlgo <: OnlineAlgo end

function setup(d::OAlgoFlow{<:RecursiveLikelihoodAlgo})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    PipelineFlow(spec₀, ctx₀, algo₀, obs)
end



mutable struct RMLAlgo <: RecursiveLikelihoodAlgo
    γ::Float64
    ϵ::Float64
    ψ::Array{Float64, 1}
    x::Array{Float64, 1}
    R::Array{Float64, 2}
    errs::Array{Float64, 1}
    oldpsis::Array{Float64, 2}
    pdim::Int

    function RMLAlgo(gamma::Float64, epsilon::Float64, pdim::Int, mdim::Int)
        beta = zeros(mdim+2)
        psi = zeros(mdim+1)
        R = Array(I(mdim+1) * 1.0) .* epsilon
        ops = zeros(mdim+1, mdim-pdim)
        errs = zeros(mdim-pdim)
        new(gamma, epsilon, psi, beta, R,errs, ops, pdim)
    end

    function RMLAlgo(g::Float64, e::Float64, ps, b, R,er, op, pd)
        new(g,e,ps,b,R,er,op,pd)
    end
end

function step(d::OAlgoFlow{<:RMLAlgo})
    spec, ctx, algo, obs = unpack(d)
    errs₀ = algo.errs
    β = algo.x[1:end-1]
    σ²₀ = algo.x[end]
    Φ₀ = [[1]; ctx.lastobs; errs₀]
    Ψ₁ = copy(Φ₀)
    Ψ₁ += sum(algo.oldpsis * diagm(β[algo.pdim+2:end]), dims=2)[:,1]
    R₁ = algo.R + algo.γ * (Ψ₁ * Ψ₁' - algo.R)
    e = obs - β' * Φ₀
    β₁ = β + algo.γ * inv(R₁) * Ψ₁ * e
    σ²₁ = σ²₀ + algo.γ * (e^2 - σ²₀)
    oldpsis = zeros(size(algo.oldpsis))
    oldpsis[:,2:end] = algo.oldpsis[:,1:end-1]
    oldpsis[:,1] = Φ₀
    errs₀[2:end] = algo.errs[1:end-1]
    errs₀[1] = e
    algo₁ = RMLAlgo(algo.γ, algo.ϵ, Ψ₁, [β₁; [σ²₁]], R₁, errs₀, oldpsis, algo.pdim)
    PipelineFlow(spec, ctx, algo₁, obs)
end
