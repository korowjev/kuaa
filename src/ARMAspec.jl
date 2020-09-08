include("utils.jl")

mutable struct ARMASpec <: ModelSpec
    p::Int
    q::Int
    ϕ::Array{Float64, 1}
    θ::Array{Float64, 1}
    μ::Float64
    σ::Float64

    function ARMASpec(phi::Array{Float64, 1}, theta::Array{Float64, 1}, mu::Float64, sigma::Float64)
        new(length(phi), length(theta), phi, theta, mu, sigma)
    end
end

struct ARMAContext <: Context
    lastobs::Array{Float64, 1}
    lasterrs::Array{Float64, 1}
end

function ctxupdate(ctx::ARMAContext, spec::ARMASpec, y::Float64, e::Float64)
    pushfirst!(ctx.lasterrs, e)
    pop!(ctx.lasterrs)
    pushfirst!(ctx.lastobs, y)
    pop!(ctx.lastobs)
end

function ctxupdate(ctx::ARMAContext, spec::ARMASpec, y::Float64)
    e = y - predict(spec, ctx)
    ctxupdate(ctx, spec, y, e)
end

function predict(spec::ARMASpec, ctx::ARMAContext)
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + sum(spec.θ .* ctx.lasterrs)
end

function simulate(spec::ARMASpec, ctx::ARMAContext)
    ϵ = randn() * spec.σ
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + sum(spec.θ .* ctx.lasterrs) + ϵ, ϵ
end

function fromvec!(spec::ARMASpec, vec::Array{Float64, 1})
    spec.μ = vec[1]
    spec.ϕ = vec[2:spec.p+1]
    spec.θ = vec[spec.p+2:end-1]
    spec.σ = vec[end]
end
