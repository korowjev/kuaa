OAlgoFlow{T <: OnlineAlgo} = PipelineFlow{<:ModelSpec, <:Context, T, <:Observation}

function unpack(d::OAlgoFlow{<:OnlineAlgo})
    (d.spec, d.ctx, d.algo, d.obs)
end

include("ogalgos.jl")
include("omalgos.jl")
include("rmlalgos.jl")
