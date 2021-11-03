library(rcarbon)
library(here)
a = 6500
b = 4500
r = 0.002
t = 0:(a-b)
pi = ((1+r)^t)/(sum((1+r)^t))
# plot(a-t,pi,xlim=c(a,b),type='l',xlab='Cal BP',ylab='Probability Mass',ylim=c(0,max(pi))) 

#large sample
set.seed(12345)
n = 500
calendar.dates.large = sample(a:b,size=n,prob=pi,replace=TRUE)
cra.large = round(uncalibrate(calendar.dates.large)$rCRA) #back-calibrate in 14C ages
cra.error.large = rep(20,n) #assign error of 20 years

#small sample
set.seed(12345)
n= 50
calendar.dates.small = sample(a:b,size=n,prob=pi,replace=TRUE)
cra.small = round(uncalibrate(calendar.dates.small)$rCRA) #back-calibrate in 14C ages
cra.error.small = rep(20,n) #assign error of 20 years


### GLM ####
# calibrated.dates.large = calibrate(cra.large,cra.error.large,verbose=FALSE)
# summed.prob.large = spd(calibrated.dates.large,timeRange=c(6500,4500),verbose = FALSE)
# summed.prob.grid.large = summed.prob.large$grid
# fit.large <- nls(PrDens ~ exp(a + b * calBP), data = summed.prob.grid.large, start = list(a = 0, b = 0))
# -coefficients(fit.large)[2] #Estimated growth
# -confint(fit.large,level=0.95)[2,] #95% CI 
# 
# 
# calibrated.dates.small = calibrate(cra.small,cra.error.small,verbose=FALSE)
# summed.prob.small = spd(calibrated.dates.small,timeRange=c(6500,4500),verbose = FALSE)
# summed.prob.grid.small = summed.prob.small$grid
# fit.small <- nls(PrDens ~ exp(a + b * calBP), data = summed.prob.grid.small, start = list(a = 0, b = 0))
# -coefficients(fit.small)[2] #Estimated growth
# -confint(fit.small,level=0.95)[2,] #95% CI 


save(cra.large,cra.small,cra.error.large,cra.error.small,file=here('data','sim2.RData'))


