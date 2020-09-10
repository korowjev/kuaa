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
    y::Float64
    lastobs::Array{Float64, 1}
    lasterrs::Array{Float64, 1}
end

ARMAFlow = PipelineFlow{ARMASpec, ARMAContext, <:IdAlgo, <:Observation}


function ctxupdate(d::ARMAFlow)
    spec₀, ctx₀, algo₀, obs = unpack(d)
    e = obs - predict(spec₀, ctx₀)
    lasterrs = ctx₀.lasterrs
    pushfirst!(lasterrs, e)
    pop!(lasterrs)
    lastobs = ctx₀.lastobs
    pushfirst!(lastobs, obs)
    pop!(lastobs)
    ctx₁ = ARMAContext(obs, lastobs, lasterrs)
    PipelineFlow(spec₀, ctx₁, algo₀, obs)
end

function predict(spec::ARMASpec, ctx::ARMAContext)
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + sum(spec.θ .* ctx.lasterrs)
end

function simulate(spec::ARMASpec, ctx::ARMAContext)
    ϵ = randn() * spec.σ
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + sum(spec.θ .* ctx.lasterrs) + ϵ
end

function specfromvec(d::ARMAFlow)
    spec₀, ctx₀, algo₀, obs = unpack(d)
    vec = algo₀.β
    μ = vec[1]
    ϕ = vec[2:spec₀.p+1]
    θ = vec[spec₀.p+2:end-1]
    σ = sqrt(vec[end])
    spec₁ = ARMASpec(ϕ, θ, μ, σ)
    PipelineFlow(spec₁, ctx₀, algo₀, obs)
end
