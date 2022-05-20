import Statistics: median

#binned statistics -- fast histograms with a statistic calculated at each bin
"""
Compute a fast binned statistic for an array of y-values along some array of x-values,
essentially a histogram with the chosen statistic computed at each bin.

This function is an analog to the existing scipy.stats.binned_statistic function, but written in native Julia, and this implementation is faster than the SciPy version!

Returns the bin edges, bin centers, and corresponding binned statistic. Currently implemented stats operations are sum, mean, median, variance, standard deviation, and an option to pass a custom function.
The median / custom function implementation is much slower than the others (~30x slower than sum, which is the fastest), but included to match with scipy.stats.binned_statistic. It could easily be improved but left in lazy state for now.

Usage examples:
```julia
x = rand(2048,2048); y = rand(2048,2048)
edges, centers, binnedSum = binnedStatistic(x,y,nbins=500,statistic=:sum)

edges, centers, binnedSum = binnedStatistic(x,y) #defaults to :sum with 100 bins

edges, centers, binnedVar = binnedStatistic(x,y,statistic=:var) #compute the variance in each bin, leaving default of 100 bins

f(x) = sum(x.^2) #example of user defined function, must be vectorized but return a single scalar Float64 value
edges, centers, binnedF = binnedStatistic(x,y,statistic=:f,f=f)
```

This can technically be done with the existing Histogram functionality above, but it's very slow, and this new way is ~15-20x faster.
Example using existing histogram routine in `StatsBase`:

```julia
function histSum(x::Array,y::Array,bins::Int=100) #compute the sum on each bin in a histogram, using the existing functionality in StatsBase
    h = fit(Histogram, vec(x), aweights(y), nbins=bins)
    h.edges, h.weights
end
```

`julia> x = rand(2048,2048); y = rand(2048,2048)
julia> using BenchmarkTools
julia> @btime histSum(x,y)
    268.793 ms (8 allocations: 1.20 KiB)`

if using this new, faster version we obtain a ~15-20x speed-up:

`julia> @btime binnedStatistic(x,y)
    14.165 ms (3 allocations: 1.83 KiB)`

These tests were performed using Julia 1.6.1 on a system running Linux Mint 20.3 Cinnamon with a Intel Core i7-1065G7 CPU (4 cores @ 1.3 GHz)
"""
function binnedStatistic(x::Array{Float64,}, y::Array{Float64,}; nbins::Int=100, statistic::Symbol=:sum, f::Function=binnedStatistic,binMax=nothing,binMin=nothing,centered=false)
    if length(x) > 0 && nbins < 1
        throw(ArgumentError("number of bins must be ≥ 1 for a non-empty array, got $nbins"))
    end
    if length(vec(x)) != length(vec(y))
        throw(ArgumentError("length of x must match length of y"))
    end
    binMax = binMax == nothing ? maximum(x) : binMax
    binMin = binMin == nothing ? minimum(x) : binMin
    if binMax == binMin
        throw(ArgumentError("No valid binning is possible between minimum $binMin and maximum $binMax"))
    end
    result = zeros(nbins)
    Δ = nbins / (binMax - binMin) #spacing
    sub = centered == false ? binMin : binMin+Δ/2 #subtract binMin + Δ/2 to "center" bins (i.e. binMin and binMax are centers, not edges)
    if statistic == :sum
        for (x, y) in zip(x, y)
            i = min(nbins, 1 + floor(Int, Δ * max(0., x - sub))) #which bin are we in at this x?
            result[i] += y
        end
    elseif statistic == :mean || statistic == :std || statistic == :var
        N = zeros(nbins)
        for (x, y) in zip(x, y)
            i = min(nbins, 1 + floor(Int, Δ * max(0., x - sub)))
            result[i] += y
            N[i] += 1 #need to keep track of number of counts in each bin for mean, std, var
        end
        N[N .== 0.] .= 1. #no dividing by zero
        result ./= N
        if statistic == :std || statistic == :var
            μ = copy(result)
            result = zeros(nbins)
            for (x, y) in zip(x, y)
                i = min(nbins, 1 + floor(Int, Δ * max(0., x - sub)))
                result[i] += (y-μ[i])^2
            end
            result ./= N
            if statistic == :std
                @. result = √result
            end
        end
    elseif statistic == :median || statistic == :f #this is much slower than other options
        result = zeros(nbins)
        i = min.(nbins, 1 .+ floor.(Int, Δ * max.(0., x .- sub)))
        for ind in unique(i)
            result[ind] = statistic == :median ? median(y[i.==ind]) : f(y[i.==ind])
        end
    else
        throw(ArgumentError("Valid statistic options are :sum, :mean, :std, :var, :median, or :f (use :f for custom function), got $statistic"))
    end
    edges = centered == false ? range(binMin, stop=binMax, length=nbins+1) : range(binMin, stop=binMax, length=nbins+1) .+ Δ/2
    centers = [(edges[i]+edges[i+1])/2 for i=1:length(edges)-1]
    return edges, centers, result
end
