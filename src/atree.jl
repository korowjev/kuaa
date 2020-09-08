abstract type ModelSpec end

abstract type Context end

abstract type IdAlgo end
abstract type OnlineAlgo <: IdAlgo end

abstract type ModelDumper end

abstract type DataSource end
Observation = Float64

struct PipelineDrop{T <: ModelSpec, S <: Context, R <: OnlineAlgo, Q <: Observation}
    spec::T
    ctx::S
    algo::R
    obs::Q
end
