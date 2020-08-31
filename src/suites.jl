using Random
using LinearAlgebra

include("specs.jl")
include("algos.jl")
include("dumpers.jl")
include("datasources.jl")

abstract type Suite end

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

