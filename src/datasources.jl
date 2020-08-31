abstract type DataSource end

struct Simulator <: DataSource
    spec::ModelSpec
    ctx::Context

    function Simulator(spec::ARSpec)
        ctx = ARContext(zeros(spec.p))
        new(spec, ctx)
    end
end

function isactive(sim::Simulator)
    true
end

function next(sim::Simulator)
    y, nctx = simulate(sim.spec, sim.ctx)
    ctxupdate(sim.ctx, y)
    return y
end
