mutable struct Simulator <: DataSource
    spec::ModelSpec
    ctx::Context
    obs

    function Simulator(spec::ARSpec)
        ctx = ARContext(0.0, zeros(spec.p))
        new(spec, ctx, 0.0)
    end

    function Simulator(spec::ARSpec, ctx::ARContext, y)
        new(spec, ctx, y)
    end

    function Simulator(spec::ARMASpec)
        ctx = ARMAContext(zeros(spec.p), zeros(spec.q))
        new(spec, ctx, 0.0)
    end
end

function isactive(sim::Simulator)
    true
end

function next(sim::Simulator, d::PipelineDrop{<:ModelSpec, <:Context, <:OnlineAlgo, <:Observation})    
    spec₀, ctx₀, algo₀, obs = unpack(d)
    obs₁ = simulate(sim.spec, sim.ctx)
    sim.ctx = ctxupdate(PipelineDrop(sim.spec, sim.ctx, OnlineNewtonStep(1.0,1.0,1), obs₁)).ctx
    PipelineDrop(spec₀, ctx₀, algo₀, obs₁)
end
