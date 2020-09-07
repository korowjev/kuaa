abstract type ModelDumper end

mutable struct PrintSnapshot <: ModelDumper
    counter::Int
    refresh::Int

    function PrintSnapshot(c::Int, r::Int)
        new(c, r)
    end

    function PrintSnapshot(r::Int)
        new(0, r)
    end
end

function dumptime(d::PrintSnapshot)
    d.counter == 0
end

function ++(d::PrintSnapshot)
    c₁ = d.counter == d.refresh ? 0 : d.counter + 1
    PrintSnapshot(c₁, d.refresh)
end


function dump(d::PrintSnapshot, spec::ModelSpec, ctx::Context)
    print("$spec \n")
end
