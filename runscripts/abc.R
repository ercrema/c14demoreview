library(rcarbon)
library(doSNOW)
library(foreach)
library(here)

# Load Data
load(here('data','sim2.RData'))

# Source abc function
source(here('src','abc_sim_exp.R'))

# Calibrate and generate target SPD
cal.large <- calibrate(cra.large,cra.error.large)
cal.small <- calibrate(cra.small,cra.error.small)
spd.large <- spd(cal.large,timeRange=c(6500,4500),spdnormalised=T)
spd.small <- spd(cal.small,timeRange=c(6500,4500),spdnormalised=T)

# Generate priors
nsim = 1000000
set.seed(123)
r = rnorm(nsim,mean=0,sd=0.1)

# Setup parallel computing
ncores = 3
cl <- makeCluster(ncores)
registerDoSNOW(cl)
pb <- txtProgressBar(max = nsim, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress = progress)

res <- foreach (i=1:nsim,.packages=c('rcarbon'),.options.snow = opts) %dopar%
{
	set.seed(i)
	res.large  <- abc_sim_exp(r[i],n=length(cra.large),a=6500,b=4500,errors=cra.error.large,target.spd=spd.large)
	res.small  <- abc_sim_exp(r[i],n=length(cra.small),a=6500,b=4500,errors=cra.error.small,target.spd=spd.small)
	return(c(res.large,res.small))
}

res.abc = unlist(res) |> matrix(nrow=2) |> t() |> as.data.frame()
colnames(res.abc) <- c('epsilon.large','epsilon.small')
res.abc$r = r

save(res.abc,file=here('results','abc_res.RData'))








