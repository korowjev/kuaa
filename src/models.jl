using Random
using LinearAlgebra

abstract type ModelSpec end

abstract type IdAlgo end
abstract type OnlineAlgo <: IdAlgo end
abstract type OnlineGradientAlgo <: OnlineAlgo end

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
        ctxupdate(suite.ctx, x)
        if dumptime(suite.dumper)
            dump(suite.dumper, suite.spec, suite.ctx)
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
    ctxupdate(sim.ctx, y)
    return y
end

function ctxupdate(ctx::ARContext, y::Float64)
    pushfirst!(ctx.lastobs, y)
    pop!(ctx.lastobs)    
end

function simulate(spec::ARSpec, ctx::ARContext)
    ϵ = randn() * spec.σ
    spec.μ + sum(spec.ϕ .* ctx.lastobs) + ϵ, nothing
end


abstract type AlgoMemory end

mutable struct OnlineNewtonStep <: OnlineGradientAlgo
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

function update!(spec::ModelSpec, ctx::Context, algo::OnlineGradientAlgo, y::Float64)
    g = gradient(spec, ctx, y)
    step!(algo, g)
    fromvec!(spec, algo.x)
end

function predict(spec::ARSpec, ctx::ARContext)
    spec.μ + sum(spec.ϕ .* ctx.lastobs)
end

function gradient(spec::ARSpec, ctx::ARContext, y::Float64)
    yhat = predict(spec, ctx)
    error = y - yhat
    g = - 2 * error * [[1.0]; ctx.lastobs]
    return [g; [-2(error^2 - spec.σ^2)]]
end

function fromvec!(spec::ARSpec, vec::Array{Float64, 1})
    spec.μ = vec[1]
    spec.ϕ = vec[2:end-1]
    spec.σ = vec[end]
end


mutable struct PrintSnapshot <: ModelDumper
    counter::Int
    refresh::Int

    function PrintSnapshot(r::Int)
        new(0, r)
    end
end

function dumptime(d::PrintSnapshot)
    if d.counter == d.refresh
        d.counter = 0
        return true
    end
    d.counter += 1
    false
end

function dump(d::PrintSnapshot, spec::ModelSpec, ctx::Context)
    print("$spec \n")
end



spec = ARSpec([0.5, -0.1], 0.2, 0.05)
simul = Simulator(spec)

nspec = ARSpec([0.0, 0.0], 0.0, 1.0)
algo = OnlineNewtonStep(10.0, 1.0, 4)
ctx = ARContext(zeros(2))

suite = OnlineSuite(nspec, algo, simul, ctx, PrintSnapshot(10000))

listen(suite)
