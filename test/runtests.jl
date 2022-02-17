using BinnedStatistics
using Test

@testset "BinnedStatistics.jl" begin
    x = [1.,1.,2.,5.,7.]; y = [1.,1.,2.,1.5,3.] #use the SciPy example as a test: https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.binned_statistic.html#scipy.stats.binned_statistic
    edges, centers, res = binnedStatistic(x,y,nbins=2)
    @test res == [4.,4.5]
    @test edges == [1.,4.,7.]
    @test centers == [2.5,5.5]
    e,c, res = binnedStatistic(x,y,statistic=:mean,nbins=2)
    @test res == [4. /3.,4.5/2.]
    e,c, varRes = binnedStatistic(x,y,statistic=:var,nbins=2)
    @test varRes == [sum((y[1:3].-res[1]).^2),sum((y[4:end].-res[2]).^2)]./[3.,2.]
    e,c, stdRes = binnedStatistic(x,y,statistic=:std,nbins=2)
    @test stdRes == sqrt.(varRes)
    e,c, res = binnedStatistic(x,y,statistic=:median,nbins=2)
    @test res == [1.,(1.5+3.)/2.]
    f(x)=sum(x.^2)
    e,c, res = binnedStatistic(x,y,statistic=:f,f=f,nbins=2)
    @test res == [6.,(1.5^2+3^2)]
end
