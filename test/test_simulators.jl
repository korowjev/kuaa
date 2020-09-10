include("../src/suites.jl")

using Random

Random.seed!(1)


ϕˢ  = 0.10
θˢ  = 0.10
μˢ  = 0.15
σˢ  = 0.50

eˢ = randn(5) * σˢ
yˢ = zeros(5)
yˢ[1] = eˢ[1] + μˢ
for i in 2:5
    yˢ[i] = μˢ + ϕˢ*yˢ[i-1] + θˢ*eˢ[i-1] + eˢ[i]
end

spec = ARMASpec([ϕˢ], [θˢ], μˢ, σˢ)

Random.seed!(1)
let ctx  = ARMAContext(0.0, [0.0], [0.0]), yₛ = zeros(5)
    for i in 1:5
        yₛ[i] = simulate(spec, ctx)
        ctx = ARMAContext(yₛ[i], [yₛ[i]], [eˢ[i]])
    end
    @test yˢ ≈ yₛ
end

Random.seed!(1)
let ctx  = ARMAContext(0.0, [0.0], [0.0]), sim = Simulator(spec), flow = PipelineFlow(spec, ctx, OnlineNewtonStep(0.1,0.1,1), yˢ[1]), yₛ = zeros(5)
    for i in 1:5
        flow = next(sim, flow)
        yₛ[i] = flow.obs
    end
    @test yˢ ≈ yₛ
end

let sim = Simulator(spec); @test isactive(sim) == true end
