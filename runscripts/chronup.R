# Load Libraries and Data ----
library(chronup)
library(here)
load(here('data','sim2.RData'))
large.dates  <- data.frame(cra.large,cra.error.large)
small.dates  <- data.frame(cra.small,cra.error.small)

# Calibrate and Built Matrix ----
chronun_matrix_large <- chronup::build_c14_matrix(c14_dates = large.dates,BP = T,resolution = -1)
chronun_matrix_small <- chronup::build_c14_matrix(c14_dates = small.dates,BP = T,resolution = -1)

# Prepare  RECE ----
new_times.large  <- seq(chronun_matrix_large$time_range[1],chronun_matrix_large$time_range[2],-1)
new_times.small  <- seq(chronun_matrix_small$time_range[1],chronun_matrix_small$time_range[2],-1)
new_breaks.large  <- seq(chronun_matrix_large$time_range[1],chronun_matrix_large$time_range[2]-10,-10)
new_breaks.small  <- seq(chronun_matrix_large$time_range[1],chronun_matrix_large$time_range[2]-10,-10)

J  <- 100000
ncores <- 3
cl  <- parallel::makeCluster(ncores)
parallel::clusterEvalQ(cl,{wd<-getwd();library(chronup)})
rece.large  <- pbapply::pbsapply(cl=cl,X=1:J,FUN=chronup::sample_event_counts,chronun_matrix=chronun_matrix_large$chronun_matrix,times=new_times.large,breaks=new_breaks.large)
rece.small  <- pbapply::pbsapply(cl=cl,X=1:J,FUN=chronup::sample_event_counts,chronun_matrix=chronun_matrix_small$chronun_matrix,times=new_times.small,breaks=new_breaks.small)
parallel::stopCluster(cl)


# Fit Model ----
mids <- function(x){
y <- x[-length(x)] + (diff(x)/2)
return(y)
}
bin_centers.large <- mids(new_breaks.large)
sub_interval.large <- which(bin_centers.large <= 6500 & bin_centers.large >= 4500)
bin_centers.small <- mids(new_breaks.small)
sub_interval.small <- which(bin_centers.small <= 6500 & bin_centers.small >= 4500)

# Large
n_rece_samples.large <- dim(rece.large)[2]
n_bins.large <- dim(rece.large)[1]
x0.large <- rep(1, n_bins.large)
x1.large <- (1:n_bins.large) * 10
X.large <- matrix(rep(c(x0.large, x1.large), n_rece_samples.large),nrow = n_bins.large)
startvals <- c(0,0)
startscales <- c(0.1, 0.0002)
mcmc_samples_adapt.large <- regress(Y = rece.large[sub_interval.large,],X = X.large[sub_interval.large,],model = "pois",startvals = startvals,scales = startscales,adapt = T)

burnin <- floor(dim(mcmc_samples_adapt.large$samples)[1] * 0.2)
indeces <- seq(burnin, dim(mcmc_samples_adapt.large$samples)[1], 1)
new_startvals <- colMeans(mcmc_samples_adapt.large$samples[indeces,])

burnin <- floor(dim(mcmc_samples_adapt.large$scales)[1] * 0.2)
indeces <- seq(burnin, dim(mcmc_samples_adapt.large$scales)[1], 1)
new_startscales <- colMeans(mcmc_samples_adapt.large$scales[indeces,])

mcmc_samples.large <- regress(Y = rece.large[sub_interval.large,],X = X.large[sub_interval.large,],model = "pois",startvals = new_startvals,scales = new_startscales,adapt = F)


# Large
n_rece_samples.small <- dim(rece.small)[2]
n_bins.small <- dim(rece.small)[1]
x0.small <- rep(1, n_bins.small)
x1.small <- (1:n_bins.small) * 10
X.small <- matrix(rep(c(x0.small, x1.small), n_rece_samples.small),nrow = n_bins.small)
startvals <- c(0,0)
startscales <- c(0.1, 0.0002)
mcmc_samples_adapt.small <- regress(Y = rece.small[sub_interval.small,],X = X.small[sub_interval.small,],model = "pois",startvals = startvals,scales = startscales,adapt = T)

burnin <- floor(dim(mcmc_samples_adapt.small$samples)[1] * 0.2)
indeces <- seq(burnin, dim(mcmc_samples_adapt.small$samples)[1], 1)
new_startvals <- colMeans(mcmc_samples_adapt.small$samples[indeces,])

burnin <- floor(dim(mcmc_samples_adapt.small$scales)[1] * 0.2)
indeces <- seq(burnin, dim(mcmc_samples_adapt.small$scales)[1], 1)
new_startscales <- colMeans(mcmc_samples_adapt.small$scales[indeces,])

mcmc_samples.small <- regress(Y = rece.small[sub_interval.small,],X = X.small[sub_interval.small,],model = "pois",startvals = new_startvals,scales = new_startscales,adapt = F)



# Extract Posteriors ----
burnin <- floor(dim(mcmc_samples.large)[1] * 0.2)
indeces <- seq(burnin, dim(mcmc_samples.large)[1], 1)
beta.large = mcmc_samples.large[indeces,2]

burnin <- floor(dim(mcmc_samples.small)[1] * 0.2)
indeces <- seq(burnin, dim(mcmc_samples.small)[1], 1)
beta.small = mcmc_samples.small[indeces,2]

# Save output ----
save(beta.large,beta.small,file=here('results','chronup_res.RData'))






