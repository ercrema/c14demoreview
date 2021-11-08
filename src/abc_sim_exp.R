
# Generates candidate SPDs and comapre them to user provided target SPDs
# r ... exponential growth rate
# n ... number of samples
# a ... start of window of analysis (in cal BP)
# b ... end of window of analyses (in cal BP)
# errors ... vector from which 14C errors are sampled from
# target.spd ... target spd. Vector of normalised SPD values
# NOTE: n and target.spd can be provided by a vector and a list, in which case epsilon will be calculated for matching indexes.

abc_sim_exp <- function(r,n,a,b,errors,target.spd)
{
	require(rcarbon)
	tfinal <- abs(b-a)+1
	t <- 1:(abs(b-a)+1)
	pop <- (1+r)^t[1:tfinal]
	model <- data.frame(CalBP=a:b,PrDens = pop/sum(pop))
	class(model) <- 'CalGrid'
	cra.model <- uncalibrate(model,verbose=F)

	niter  <- length(n)
	epsilon  <- numeric(length=niter)
	for (i in 1:niter)
	{
		uncal.samples = sample(cra.model$CRA,size=n[i],prob=cra.model$PrDens,replace=TRUE)
		cal.samples = calibrate(uncal.samples,sample(errors,size=n[i],replace=T),verbose=FALSE)
		spd.candidate = spd(cal.samples,timeRange=c(a,b),verbose=FALSE,spdnormalised=T)
		epsilon[i] = sqrt(sum((target.spd[[i]]-spd.candidate$grid$PrDens)^2))
	}
	return(epsilon)
}
