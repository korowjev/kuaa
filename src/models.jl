include("suites.jl")

spec = ARSpec([0.2, -0.15, 0.1, -0.05], 0.20, 0.5)
simul = Simulator(spec)

nspec = ARSpec([0.1, 0.0, 0.0, 0.0], 0.0, 1.0)
#algo = OnlineNewtonStep(10.0, 1.0, 4)
algo = OnlineMethodMoments(0.0001, 4, 4)
ctx = ARContext(zeros(4))

suite = OnlineSuite(nspec, algo, simul, ctx, PrintSnapshot(100000))

listen(suite)
