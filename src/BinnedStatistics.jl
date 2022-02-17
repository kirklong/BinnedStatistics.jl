module BinnedStatistics
import Statistics: median
include("binnedStat1D.jl")
#will add multidimensional version soon, akin to binned_statistic_dd in scipy
export
  binnedStatistic

end
