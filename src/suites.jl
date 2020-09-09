using Random
using LinearAlgebra

include("atree.jl")
include("utils.jl")

include("specs.jl")
include("algos.jl")
include("dumpers.jl")
include("datasources.jl")

abstract type Suite end

struct OnlineSuite{T <: ModelSpec, S <: Context, R <: OnlineAlgo, Q <: Observation} <: Suite
    flow::PipelineFlow{T, S, R, Q}
    source::DataSource
    dumper::ModelDumper
end

function listen(suite::OnlineSuite)
    let flow = suite.flow, dumper = suite.dumper, source=suite.source
        while isactive(source)
            flow = flow |> Base.Fix1(next, source) |> process
            if dumptime(dumper)
                dump(dumper, flow.spec, flow.ctx)
            end
        end
    end
end

function process(d::PipelineFlow)
    d |> setup |> step |> update
end

function update(d::PipelineFlow)
    d |> specfromvec |> ctxupdate
end
