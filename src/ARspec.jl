
mutable struct ARSpec <: ModelSpec
    p::Int
    ϕ::Array{Float64, 1}
    μ::Float64
    σ::Float64

    function ARSpec(phi::Array{Float64, 1}, mu::Float64, sigma::Float64)
        new(length(phi), phi, mu, sigma)
    end
end

struct ARContext <: Context
    y::Float64
    lastobs::Array{Float64, 1}
end

function specfromvec(d::PipelineDrop{ARSpec, ARContext, <:OnlineAlgo, <:Observation})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    μ = algo₀.x[1]
    ϕ = algo₀.x[2:end-1]
    σ = algo₀.x[end]
    spec₁ = ARSpec(ϕ, μ, σ)
    PipelineDrop(spec₁, ctx₀, algo₀, obs)
end

function ctxupdate(d::PipelineDrop{ARSpec, ARContext, <:OnlineAlgo, <:Observation})
    spec₀, ctx₀, algo₀, obs = unpack(d)
    lastobs₁ = ctx₀.lastobs
    pushfirst!(lastobs₁, obs)
    pop!(lastobs₁)    
    ctx₁ = ARContext(obs, lastobs₁)
    PipelineDrop(spec₀, ctx₁, algo₀, obs)
end

function predict(spec::ARSpec, ctx::ARContext)
    spec.μ + sum(spec.ϕ .* ctx.lastobs)
end

function armeqs(moments::Array{Float64, 1}, automs::Array{Float64, 1})
    mean, var, covs = centersecond(moments, automs)
    mn = length(covs)
    ms = zeros(mn, mn)
    for i in 1:mn
        for j in 1:mn
            if j < i
                ms[i,j] = covs[i-j]
            elseif j > i
                ms[i,j] = covs[j-i]
            else
                ms[i,j] = var
            end
        end
    end
    phis = inv(ms) * covs
    mu = mean * (1 - sum(phis))
    sigma = max(0.0001, var - covs' * phis)
    [[mu]; phis; [sqrt(sigma)]]
end

function getmeqs(spec::ARSpec)
    return armeqs
end

function gradient(spec::ARSpec, ctx::ARContext, y::Float64)
    g = zeros(spec.p + 2)
    yhat = predict(spec, ctx)
    error = y - yhat
    g[1] = - 2 * error
    g[2:end-1] = - 2 * error * ctx.lastobs
    g[end] = -2(error^2 - spec.σ^2)
    return g
end

function simulate(spec::ARSpec, ctx::ARContext)
    ϵ = randn() * spec.σ
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + ϵ
end
