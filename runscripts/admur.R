library(ADMUR)
library(DEoptimR)
library(here)

# Load Data
load(here('data','sim2.RData'))

# Calibration
data.large <- data.frame( age=cra.large, sd=cra.error.large,phase=1:length(cra.large),datingType='14C')
data.small <- data.frame( age=cra.small, sd=cra.error.small,phase=1:length(cra.small),datingType='14C')
CalArray.large <- makeCalArray(intcal20, calrange = c(4500,6500))
CalArray.small <- makeCalArray(intcal20, calrange = c(4500,6500))
spd.large <- summedCalibrator(data.large, CalArray.large, normalise='full')
spd.small <- summedCalibrator(data.small, CalArray.small, normalise='full')
PD.large <- phaseCalibrator(data.large, CalArray.large, remove.external = TRUE)
PD.small <- phaseCalibrator(data.small, CalArray.small, remove.external = TRUE)


exp.large <- JDEoptim(lower=c(0), upper=c(1),fn=objectiveFunction, PDarray=PD.large, type='exp', NP=20, trace=T)
exp.small <- JDEoptim(lower=c(0), upper=c(1),fn=objectiveFunction, PDarray=PD.small, type='exp', NP=20, trace=T)

chain.large <- mcmc(PDarray=PD.large, startPars=exp.large$par, type='exp', N=100000, burn=2000, thin=5, jumps =0.0004)
chain.small <- mcmc(PDarray=PD.small, startPars=exp.small$par, type='exp', N=100000, burn=2000, thin=5, jumps =0.0004)

save(exp.large,exp.small,chain.large,chain.small,file=here('results','admur_res.RData'))



