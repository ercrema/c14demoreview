library(nimbleCarbon)
library(rcarbon)
library(here)

# Load Data
load(here('data','sim2.RData'))


# Core Modele
exp.model <- nimbleCode({
	for (i in 1:N){
		theta[i] ~ dExponentialGrowth(a=start,b=end,r=r);
		mu[i] <- interpLin(z=theta[i], x=calBP[], y=C14BP[]);
		sigmaCurve[i] <- interpLin(z=theta[i], x=calBP[], y=C14err[]);
		sd[i] <- (sigma[i]^2+sigmaCurve[i]^2)^(1/2);
		X[i] ~ dnorm(mean=mu[i],sd=sd[i]);
	}
	r ~ dnorm(0,0.1);
})  

data("intcal20") #load the IntCal20 calibration curve
constants <- list(calBP=intcal20$CalBP,C14BP=intcal20$C14Age,C14err=intcal20$C14Age.sigma,start=6500,end=4500)
constants.small <- constants.large <- constants
constants.small$N <- length(cra.small)
constants.large$N <- length(cra.large)


d.large <- list(X=cra.large,sigma=cra.error.large)
d.small <- list(X=cra.small,sigma=cra.error.small)


m.dates.large = medCal(calibrate(d.large$X,d.large$sigma,verbose = FALSE))
m.dates.small = medCal(calibrate(d.small$X,d.small$sigma,verbose = FALSE))

if(any(m.dates.large>4500|m.dates.large<6500)){m.dates.large[m.dates.large>4500]=4500;m.dates.large[m.dates.large<6500]=6500} 
if(any(m.dates.small>4500|m.dates.small<6500)){m.dates.small[m.dates.small>4500]=4500;m.dates.small[m.dates.small<6500]=6500} 

inits.large <- function()list(r=rnorm(1,0,0.1),theta=m.dates.large)
inits.small <- list(r=rnorm(1,0,0.1),theta=m.dates.small)

samples.large<- nimbleMCMC(code = exp.model,constants = constants.large,data = d.large,niter = 20000, nchains = 3, thin=1, nburnin = 10000, progressBar = TRUE, monitors=c('r'), inits=inits.large, samplesAsCodaMCMC=TRUE,setSeed=c(123,456,789))
samples.small<- nimbleMCMC(code = exp.model,constants = constants.small,data = d.small,niter = 20000, nchains = 3, thin=1, nburnin = 10000, progressBar = TRUE, monitors=c('r'), inits=inits.small, samplesAsCodaMCMC=TRUE,setSeed=c(123,456,789))

coda::gelman.diag(samples.large)
coda::gelman.diag(samples.small)




