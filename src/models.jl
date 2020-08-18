using Random

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
    dumper::ModelDumper
end

function listen(suite::OnlineSuite)
    while isactive(suite.source)
        x = next(suite.source)
        update!(suite.spec, suite.algo, x)
        if dumptime(spec.dumper)
            dump(spec.dumper, spec.model)
        end
    end
end

struct ARSpec <: ModelSpec
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

spec = ARSpec([0.1, -0.1], 0.2, 0.5)
simul = Simulator(spec)
