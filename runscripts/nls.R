library(here)
library(rcarbon)

load(here('data','sim2.RData'))
calibrated.dates.large = calibrate(cra.large,cra.error.large,verbose=FALSE)
summed.prob.large = spd(calibrated.dates.large,timeRange=c(6500,4500),verbose = FALSE)
summed.prob.grid.large = summed.prob.large$grid
fit.large <- nls(PrDens ~ exp(a + b * calBP), data = summed.prob.grid.large, start = list(a = 0, b = 0))
glm.fit.large <- -coefficients(fit.large)[2] #Estimated growth
glm.ci95.large <- -confint(fit.large,level=0.95)[2,] #95% CI 

calibrated.dates.small = calibrate(cra.small,cra.error.small,verbose=FALSE)
summed.prob.small = spd(calibrated.dates.small,timeRange=c(6500,4500),verbose = FALSE)
summed.prob.grid.small = summed.prob.small$grid
fit.small <- nls(PrDens ~ exp(a + b * calBP), data = summed.prob.grid.small, start = list(a = 0, b = 0))
glm.fit.small <- -coefficients(fit.small)[2] #Estimated growth
glm.ci95.small <- -confint(fit.small,level=0.95)[2,] #95% CI 

save(glm.fit.small,glm.ci95.small,glm.fit.large,glm.ci95.large,file=here('results','glm_res.RData'))
