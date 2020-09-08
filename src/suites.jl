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
    drop::PipelineDrop{T, S, R, Q}
    source::DataSource
    dumper::ModelDumper
end

function listen(suite::OnlineSuite)
    let drop = suite.drop, dumper = suite.dumper, source=suite.source
        while isactive(source)
            drop = drop |> Base.Fix1(next, source) |> process
            if dumptime(dumper)
                dump(dumper, drop.spec, drop.ctx)
            end          
        end 
    end
end

function process(d::PipelineDrop)
    d |> setup |> step |> update
end

function update(d::PipelineDrop)
    d |> specfromvec |> ctxupdate
end
