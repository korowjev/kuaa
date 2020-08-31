function centersecond(moments::Array{Float64, 1}, automs::Array{Float64, 1})
    mean = moments[1]
    var = moments[2] - mean^2
    covs = [a - mean^2 for a in automs]
    (mean, var, covs)
end
