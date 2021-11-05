abc_sim_exp <- function(r,n,a,b,errors,target.spd)
{
	require(rcarbon)
	tfinal <- abs(b-a)+1
	t <- 1:(abs(b-a)+1)
	pop <- (1+r)^t[1:tfinal]
	model <- data.frame(CalBP=a:b,PrDens = pop/sum(pop))
	class(model) <- 'CalGrid'
	cra.model <- uncalibrate(model,verbose=F)
	uncal.samples = sample(cra.model$CRA,size=n,prob=cra.model$PrDens,replace=TRUE)
	cal.samples = calibrate(uncal.samples,sample(errors,size=n,replace=T),verbose=FALSE)
	spd.candidate = spd(cal.samples,timeRange=c(a,b),verbose=FALSE,spdnormalised=T)
	epsilon = sqrt(sum((target.spd$grid$PrDens-spd.candidate$grid$PrDens)^2))
	return(epsilon)
}
