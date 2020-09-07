include("utils.jl")

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

function specfromvec!(::Type{ARSpec}, vec::Array{Float64, 1})
    μ = vec[1]
    ϕ = vec[2:end-1]
    σ = vec[end]
    ARSpec(ϕ, μ, σ)
end

function ctxupdate!(ctx₀::ARContext, spec::ARSpec, y::Float64)
    lastobs₁ = ctx₀.lastobs
    pushfirst!(lastobs₁, y)
    pop!(lastobs₁)    
    ARContext(y, lastobs₁)
end

function ctxupdate!(ctx::ARContext,spec::ARSpec, y::Float64, e)
    ctxupdate!(ctx, spec, y)
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
    yhat = predict(spec, ctx)
    error = y - yhat
    g = - 2 * error * [[1.0]; ctx.lastobs]
    return [g; [-2(error^2 - spec.σ^2)]]
end

function simulate(spec::ARSpec, ctx::ARContext)
    ϵ = randn() * spec.σ
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + ϵ, nothing
end
