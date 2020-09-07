abstract type DataSource end

mutable struct Simulator <: DataSource
    spec::ModelSpec
    ctx::Context

    function Simulator(spec::ARSpec)
        ctx = ARContext(0.0, zeros(spec.p))
        new(spec, ctx)
    end
    
    function Simulator(spec::ARMASpec)
        ctx = ARMAContext(zeros(spec.p), zeros(spec.q))
        new(spec, ctx)
    end
end

function isactive(sim::Simulator)
    true
end

function next!(sim::Simulator)
    y, e = simulate(sim.spec, sim.ctx)
    sim.ctx = ctxupdate!(sim.ctx, sim.spec, y, e)
    return y
end
