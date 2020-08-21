using Random
using LinearAlgebra

abstract type ModelSpec end

abstract type IdAlgo end
abstract type OnlineAlgo <: IdAlgo end

abstract type DataSource end

abstract type Suite end
abstract type ModelDumper end

abstract type Context end

struct OnlineSuite <: Suite
    spec::ModelSpec
    algo::OnlineAlgo
    source::DataSource
    ctx::Context
    dumper::ModelDumper
end

function listen(suite::OnlineSuite)
    while isactive(suite.source)
        x = next(suite.source)
        update!(suite.spec, suite.ctx, suite.algo, x)
        if dumptime(spec.dumper)
            dump(spec.dumper, spec.model)
        end
    end
end

mutable struct ARSpec <: ModelSpec
    p::Int
    ϕ::Array{Float64, 1}
    μ::Float64
    σ::Float64

    function ARSpec(phi::Array{Float64, 1}, mu::Float64, sigma::Float64)
        new(length(phi), phi, mu, sigma)
    end
end

struct Simulator <: DataSource
    spec::ModelSpec
    ctx::Context

    function Simulator(spec::ARSpec)
        ctx = ARContext(zeros(spec.p))
        new(spec, ctx)
    end
end

struct ARContext <: Context
    lastobs::Array{Float64, 1}
end

function isactive(sim::Simulator)
    true
end

function next(sim::Simulator)
    y, nctx = simulate(sim.spec, sim.ctx)
    ctxupdate(sim.ctx, y, nctx)
    return y
end

function ctxupdate(ctx::ARContext, y::Float64, _::Any)
    pushfirst!(ctx.lastobs, y)
    pop!(ctx.lastobs)    
end

function simulate(spec::ARSpec, ctx::ARContext)
    ϵ = randn() * spec.σ
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + ϵ, nothing
end


abstract type AlgoMemory end

mutable struct OnlineNewtonStep <: OnlineAlgo
    γ::Float64
    ϵ::Float64
    x::Array{Float64, 1}
    A::Array{Float64, 2}

    function OnlineNewtonStep(gamma::Float64, epsilon::Float64, dim::Int)
        x = zeros(dim)
        A = Array(I(dim) * 1.0) .* epsilon
        new(gamma, epsilon, x, A)
    end
end

function step!(algo::OnlineNewtonStep, g::Array{Float64, 1})
    algo.A += g*g'
    algo.x -= 1/algo.γ * algo.A^-1 * g
end

function update!(spec::ARSpec, ctx::ARContext, algo::OnlineNewtonStep, y::Float64)
    yhat = predict(spec, ctx)
    error = y - yhat
    g = - 2 * error * [[1.0]; ctx.lastobs]
    step!(algo, g)
    spec.μ = algo.x[1]
    spec.ϕ = algo.x[2:end]
end

function predict(spec::ARSpec, ctx::ARContext)
    spec.μ + sum(spec.ϕ .* ctx.lastobs)
end

spec = ARSpec([0.5, -0.1], 0.2, 0.05)
simul = Simulator(spec)

nspec = ARSpec([0.0, 0.0], 0.0, 1.0)
algo = OnlineNewtonStep(10.0, 1.0, 3)
ctx = ARContext(zeros(2))
for i in 1:200000
    y = next(simul)
    update!(nspec, ctx, algo, y)
    ctxupdate(ctx, y, nothing)
end

    
