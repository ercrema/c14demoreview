library(rcarbon)
library(doSNOW)
library(foreach)
library(here)

# Load Data
load(here('data','sim2.RData'))

# Source abc function
source(here('src','abc_sim_exp.R'))

# Create vector with number of samples
nn <- c(length(cra.large),length(cra.small))

# Calibrate and generate target SPD
cal.large <- calibrate(cra.large,cra.error.large)
cal.small <- calibrate(cra.small,cra.error.small)
spd.large <- spd(cal.large,timeRange=c(6500,4500),spdnormalised=T)
spd.small <- spd(cal.small,timeRange=c(6500,4500),spdnormalised=T)
# Extract normalised SPD values
spd.large.dens <- spd.large$grid$PrDens
spd.small.dens <- spd.small$grid$PrDens
spd.target.dens <- list(spd.large.dens,spd.small.dens)

# Generate priors
nsim = 100000
set.seed(123)
r = rnorm(nsim,mean=0,sd=0.1)

# Setup parallel computing
ncores = 8
cl <- makeCluster(ncores)
registerDoSNOW(cl)
pb <- txtProgressBar(max = nsim, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress = progress)

res <- foreach (i=1:nsim,.packages=c('rcarbon'),.options.snow = opts) %dopar%
{
	set.seed(i)
	res  <- abc_sim_exp(r[i],n=nn,a=6500,b=4500,errors=cra.error.large,target.spd=spd.target.dens)
	return(res)
}

res.abc = unlist(res) |> matrix(nrow=2) |> t() |> as.data.frame()
colnames(res.abc) <- c('epsilon.large','epsilon.small')
res.abc$r = r

save(res.abc,file=here('results','abc_res.RData'))
