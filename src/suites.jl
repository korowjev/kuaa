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
    let algo = suite.algo, spec = suite.spec, ctx = suite.ctx, dumper = suite.dumper
        while isactive(suite.source)
            y = next!(suite.source)
            spec, ctx, algo = process(algo, spec, ctx, y)
            dumper = ++(dumper)
            if dumptime(dumper)
                dump(dumper, spec, ctx)
            end          
        end 
    end
end

function process(algo₀::OnlineAlgo, spec₀::ModelSpec, ctx₀::Context, y::Float64)
    (algo₀, spec₀, ctx₀, y) |> setup |> step |> update
end

function update(spec::ModelSpec, ctx::Context, algo::OnlineAlgo, y::Float64)
    (spec, ctx, algo, y) |> specfromvec |> ctxupdate
end

function update((spec, ctx, algo, y)::Tuple{ModelSpec, Context, OnlineAlgo, Float64})
    update(spec, ctx, algo, y)
end

