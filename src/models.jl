include("suites.jl")

spec = ARSpec([0.2, -0.1], 0.20, 0.5)
simul = Simulator(spec)

nspec = ARSpec([0.0, 0.0], 0.0, 1.0)
algo = OnlineNewtonStep(1.0, 1.0, 4)
#algo = OnlineMethodMoments(0.0001, 6, 4, 4)
ctx = ARContext(0.0, zeros(2))

suite = OnlineSuite(nspec, algo, simul, ctx, PrintSnapshot(100000))

listen(suite)


# spec = ARMASpec([0.5, 0.25], [-0.0], 0.0, 0.25)
# simul = Simulator(spec)

# nspec = ARMASpec([0.01 0.0], [0.0], 0.0, 0.25)
# algo = RMLAlgo(0.0001, 0.01, 2, 3)
# ctx = ARMAContext(zeros(2), zeros(1))

# suite = OnlineSuite(nspec, algo, simul, ctx, PrintSnapshot(100000))

# listen(suite)
