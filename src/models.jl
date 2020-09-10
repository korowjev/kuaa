include("suites.jl")

# spec = ARSpec([0.2, -0.1], 0.20, 0.5)
# simul = Simulator(spec)

# nspec = ARSpec([0.0, 0.0], 0.0, 1.0)
# #algo = OnlineNewtonStep(1.0, 1.0, 4)
# algo = OnlineMethodMoments(0.0001, 4, 2, 2)
# ctx = ARContext(0.0, zeros(2))

# suite = OnlineSuite(PipelineFlow(nspec, ctx, algo, 0.0),simul, PrintSnapshot(100000))

# listen(suite)


spec = ARMASpec([0.5, 0.25], [-0.1, 0.15], 0.0, 0.25)
simul = Simulator(spec)

nspec = ARMASpec([0.01, 0.0], [0.0, 0.0], 0.0, 0.25)
algo = RMLAlgo(0.00001, 0.01, 2, 4)
ctx = ARMAContext(0.0, zeros(2), zeros(2))

suite = OnlineSuite(PipelineFlow(nspec, ctx, algo, 0.0), simul, PrintSnapshot(100000))

listen(suite)
