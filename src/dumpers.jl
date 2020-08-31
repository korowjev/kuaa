abstract type ModelDumper end

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
