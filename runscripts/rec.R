library(here)
library(rcarbon)
library(nimble)

# Load Simulated Data ----
load(here('data','sim2.RData'))

# Calibrate and prepare REC matrices ----
Ndates.large <- length(cra.large)
Ndates.small <- length(cra.small)
c14post.large <- calibrate(cra.large,cra.error.large)
c14post.small <- calibrate(cra.small,cra.error.small)

resolution <- 10
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


# Nimble Model Fitting ----
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

# Data Prep
Y.large <- as.matrix(rece_sample.large[,2:1001])
N.large <- dim(Y.large)[1]
J.large <- dim(Y.large)[2]
X.large <- 0:(N.large-1)
Nsub.large <- seq(1,N.large,10)
nbData.large <- list(Y=Y.large[Nsub.large,],X=X.large[Nsub.large])
nbConsts.large <- list(N=length(Nsub.large),J=J.large)
nbInits.large <- list(B=0,B0=0,b=rep(0,J.large),b0=rep(0,J.large),sigB=0.0001,sigB0=0.0001)

Y.small <- as.matrix(rece_sample.small[,2:1001])
N.small <- dim(Y.small)[1]
J.small <- dim(Y.small)[2]
X.small <- 0:(N.small-1)
Nsub.small <- seq(1,N.small,10)
nbData.small <- list(Y=Y.small[Nsub.small,],X=X.small[Nsub.small])
nbConsts.small <- list(N=length(Nsub.small),J=J.small)
nbInits.small <- list(B=0,B0=0,b=rep(0,J.small),b0=rep(0,J.small),sigB=0.0001,sigB0=0.0001)




# Define Model
nbModel.large <- nimbleModel(code=nbCode,data=nbData.large,inits=nbInits.large,constants=nbConsts.large)
C_nbModel.large <- compileNimble(nbModel.large, showCompilerOutput = FALSE)
nbModel_conf.large <- configureMCMC(nbModel.large)
nbModel_conf.large$monitors <- c("B","B0","sigB","sigB0")
nbModel_conf.large$addMonitors2(c("b","b0"))
nbModel_conf.large$removeSamplers(c("B","B0","b","b0","sigB","sigB0"))
nbModel_conf.large$addSampler(target=c("B","B0","sigB","sigB0"),type="AF_slice")
for(j in 1:J.large){
   nbModel_conf.large$addSampler(target=c(paste("b[",j,"]",sep=""),paste("b0[",j,"]",sep="")),type="AF_slice")
}
nbModelMCMC.large <- buildMCMC(nbModel_conf.large)
C_nbModelMCMC.large <- compileNimble(nbModelMCMC.large,project=nbModel.large)

nbModel.small <- nimbleModel(code=nbCode,data=nbData.small,inits=nbInits.small,constants=nbConsts.small)
C_nbModel.small <- compileNimble(nbModel.small, showCompilerOutput = FALSE)
nbModel_conf.small <- configureMCMC(nbModel.small)
nbModel_conf.small$monitors <- c("B","B0","sigB","sigB0")
nbModel_conf.small$addMonitors2(c("b","b0"))
nbModel_conf.small$removeSamplers(c("B","B0","b","b0","sigB","sigB0"))
nbModel_conf.small$addSampler(target=c("B","B0","sigB","sigB0"),type="AF_slice")
for(j in 1:J.small){
   nbModel_conf.small$addSampler(target=c(paste("b[",j,"]",sep=""),paste("b0[",j,"]",sep="")),type="AF_slice")
}
nbModelMCMC.small <- buildMCMC(nbModel_conf.small)
C_nbModelMCMC.small <- compileNimble(nbModelMCMC.small,project=nbModel.small)

# Run Model
samples.large <- runMCMC(C_nbModelMCMC.large,nburnin=100000, niter=200000, thin=10, nchains=3,samplesAsCodaMCMC=TRUE,setSeed=c(123,456,789))
samples.small <- runMCMC(C_nbModelMCMC.small,nburnin=100000, niter=200000, thin=10, nchains=3,samplesAsCodaMCMC=TRUE,setSeed=c(123,456,789))

coda::gelman.diag(samples.large.rec$samples)
coda::gelman.diag(samples.small.rec$samples)

save(samples.large.rec,samples.small.rec,file=here('results','rec_res.RData'))
