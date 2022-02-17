# BinnedStatistics

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://kirklong.github.io/BinnedStatistics.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://kirklong.github.io/BinnedStatistics.jl/dev)
[![Build Status](https://github.com/kirklong/BinnedStatistics.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/kirklong/BinnedStatistics.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/kirklong/BinnedStatistics.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/kirklong/BinnedStatistics.jl)


This is a lightweight repo that mimics the functionality of SciPy's binned statistic ([`scipy.stats.binned_statistic`](https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.binned_statistic.html#scipy.stats.binned_statistic)) in native Julia. This was coded with performance in mind &mdash; it's ~2x as fast as the SciPy implementation when using PyCall, and ~10-30x faster than using a somewhat hacky implementation from the `StatsBase` Histogram functionality. As of now it only exports the 1D binned statistic function, but I plan to extend this to incorporate multiple dimensions soon! Documentation in progress, but there's a decent doc-string if you type `?binnedStatistic` at the REPL after importing the module. 
