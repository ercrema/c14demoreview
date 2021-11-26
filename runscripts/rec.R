library(here)
library(rcarbon)
library(nimble)
library(parallel)
library(coda)

# Load Simulated Data ----
load(here('data','sim2.RData'))

# Calibrate and prepare REC matrices ----
Ndates.large <- length(cra.large)
Ndates.small <- length(cra.small)
c14post.large <- calibrate(cra.large,cra.error.large)
c14post.small <- calibrate(cra.small,cra.error.small)

resolution <- 50
#sample_date_range.large <- range(unlist(lapply(c14post.large$grids,function(x)range(x[,1]))))
#sample_date_range.small <- range(unlist(lapply(c14post.small$grids,function(x)range(x[,1]))))
sample_date_range.large <- c(4500,6500)
sample_date_range.small <- c(4500,6500)
calSampleApprox <- function(x,t1,t2,r){
    n <- length(x)
    funs <- lapply(x,approxfun)
    y_list <- lapply(1:n,function(j)funs[[j]](seq(t1,t2,r)))
    y_mat <- do.call(cbind,y_list)
    y_mat[which(is.na(y_mat))] <- 0
    return(y_mat)
}

c14_matrix.large <- calSampleApprox(c14post.large$grids,sample_date_range.large[1],sample_date_range.large[2],resolution)
Dates.large <- seq(sample_date_range.large[1],sample_date_range.large[2],resolution)
rece_sample.large <- data.frame(Date=Dates.large)
for(a in 1:1000){
    count_sample.large <- apply(c14_matrix.large,2,function(x)sample(Dates.large,size=1,prob=x))
    count_df.large <- as.data.frame(table(count_sample.large))
    names(count_df.large) <- c("Date","Count")
    rece_sample.large <- merge(rece_sample.large,count_df.large,by="Date",all=T)
    colnames(rece_sample.large) <- c('Date',paste0('Count',1:a))
}

rece_sample.large <- as.matrix(rece_sample.large[,-1])
rece_sample.large[which(is.na(rece_sample.large))] <- 0
colnames(rece_sample.large) <- 1:1000
rece_sample.large <- as.data.frame(cbind(Dates.large,rece_sample.large))
rece_sample.large <- rece_sample.large[with(rece_sample.large,order(-Dates.large)),]


c14_matrix.small <- calSampleApprox(c14post.small$grids,sample_date_range.small[1],sample_date_range.small[2],resolution)
Dates.small <- seq(sample_date_range.small[1],sample_date_range.small[2],resolution)
rece_sample.small <- data.frame(Date=Dates.small)
for(a in 1:1000){
    count_sample.small <- apply(c14_matrix.small,2,function(x)sample(Dates.small,size=1,prob=x))
    count_df.small <- as.data.frame(table(count_sample.small))
    names(count_df.small) <- c("Date","Count")
    rece_sample.small <- merge(rece_sample.small,count_df.small,by="Date",all=T)
    colnames(rece_sample.small) <- c('Date',paste0('Count',1:a))
}

rece_sample.small <- as.matrix(rece_sample.small[,-1])
rece_sample.small[which(is.na(rece_sample.small))] <- 0
colnames(rece_sample.small) <- 1:1000
rece_sample.small <- as.data.frame(cbind(Dates.small,rece_sample.small))
rece_sample.small <- rece_sample.small[with(rece_sample.small,order(-Dates.small)),]


# Data Prep
matrix.sample.size = 300
Y.large <- as.matrix(rece_sample.large[,2:(matrix.sample.size+1)])
N.large <- dim(Y.large)[1]
J.large <- dim(Y.large)[2]
X.large <- 0:(N.large-1)
Nsub.large <- seq(1,N.large,10)
nbData.large <- list(Y=Y.large[Nsub.large,],X=X.large[Nsub.large])
nbConsts.large <- list(N=length(Nsub.large),J=J.large)
nbInits.large <- list(B=0,B0=0,b=rep(0,J.large),b0=rep(0,J.large),sigB=0.0001,sigB0=0.0001)

Y.small <- as.matrix(rece_sample.small[,2:matrix.sample.size+1])
N.small <- dim(Y.small)[1]
J.small <- dim(Y.small)[2]
X.small <- 0:(N.small-1)
Nsub.small <- seq(1,N.small,10)
nbData.small <- list(Y=Y.small[Nsub.small,],X=X.small[Nsub.small])
nbConsts.small <- list(N=length(Nsub.small),J=J.small)
nbInits.small <- list(B=0,B0=0,b=rep(0,J.small),b0=rep(0,J.small),sigB=0.0001,sigB0=0.0001)

# Nimble Runscript  ----
runScript <- function(seed,d,inits,constants,niter,nburnin,thin)
{
	# load library for each core
	library(nimble)
	# core model
	nbCode <- nimbleCode({
		B ~ dnorm(0,0.1)
		B0 ~ dnorm(0,100)
		sigB ~ dunif(1e-10,10)
		sigB0 ~ dunif(1e-10,10)
		for (j in 1:J) {
			b[j] ~ dnorm(mean=B,sd=sigB)
			b0[j] ~ dnorm(mean=B0,sd=sigB0)
			for (n in 1:N){
				p[n,j] ~ dunif(1e-10,1)
				r[n,j] <- exp(b0[j] + X[n] * b[j])
				Y[n,j] ~ dnegbin(size=r[n,j],prob=p[n,j])
			}
		}
	})


	nbModel <- nimbleModel(code=nbCode,data=d,inits=inits,constants=constants)
	C_nbModel <- compileNimble(nbModel, showCompilerOutput = FALSE)
	nbModel_conf <- configureMCMC(nbModel)
	nbModel_conf$monitors <- c("B","B0","sigB","sigB0")
	nbModel_conf$addMonitors2(c("b","b0"))
	nbModel_conf$removeSamplers(c("B","B0","b","b0","sigB","sigB0"))
	nbModel_conf$addSampler(target=c("B","B0","sigB","sigB0"),type="AF_slice")
	for(j in 1:constants$J){
		nbModel_conf$addSampler(target=c(paste("b[",j,"]",sep=""),paste("b0[",j,"]",sep="")),type="AF_slice")
	}
	nbModel_conf$thin = thin
	nbModel_conf$thin2 = thin
	nbModelMCMC <- buildMCMC(nbModel_conf)
	C_nbModelMCMC <- compileNimble(nbModelMCMC,project=nbModel)
	out <- runMCMC(C_nbModelMCMC,nburnin=nburnin, niter=niter, nchains=1,samplesAsCodaMCMC=TRUE,setSeed=c(seed))
	return(out)
}

# Run MCMC in parallel ----
ncores <- 3
cl <- makeCluster(ncores)
# Run the model in parallel:
seeds <- c(123, 456, 789)
niter = 8000000
nburnin = 4000000
thin = 400


output.small <- parLapply(cl = cl, X = seeds, fun= runScript,d = nbData.small,constants = nbConsts.small, inits=nbInits.small, niter=niter,nburnin = nburnin, thin=thin)
output.large <- parLapply(cl = cl, X = seeds, fun= runScript,d = nbData.large,constants = nbConsts.large, inits=nbInits.large, niter=niter,nburnin = nburnin, thin=thin)
stopCluster(cl)

res.small.out1  = lapply(output.small,function(x){x$samples})
res.small.out2  = lapply(output.small,function(x){x$samples2})
rec.small1 = mcmc.list(res.small.out1)
rec.small2 = mcmc.list(res.small.out2)

gelman.diag(rec.small1)
gelman.diag(rec.small2)

res.large.out1  = lapply(output.large,function(x){x$samples})
res.large.out2  = lapply(output.large,function(x){x$samples2})
rec.large1 = mcmc.list(res.large.out1)
rec.large2 = mcmc.list(res.large.out2)
coda::gelman.diag(rec.large1)
coda::gelman.diag(rec.large2)

save(rec.small1,rec.small2,rec.large1,rec.large2,file=here('results','rec_res.RData'))
