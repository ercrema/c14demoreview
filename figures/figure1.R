library(here)
library(rcarbon)

# Figure 1 (Comparison of Reconstructive Approaches) ----

# Extract Target
sim <- read.csv(file=here('data','sim1.csv'))
timeRange <- c(7000:3000)

# Bootstrapped KDE
load(here('results','ckde_res.RData'))
ckde.large.plot = data.frame(CalBP=timeRange)
ckde.large.plot$mean = apply(ckde.large$res.matrix,1,mean)
ckde.large.plot$lo = apply(ckde.large$res.matrix,1,quantile,probs=c(0.025),na.rm=TRUE)
ckde.large.plot$hi = apply(ckde.large$res.matrix,1,quantile,probs=c(0.975),na.rm=TRUE)
ckde.large.plot = subset(ckde.large.plot,!is.na(mean))
ckde.small.plot = data.frame(CalBP=timeRange)
ckde.small.plot$mean = apply(ckde.small$res.matrix,1,mean)
ckde.small.plot$lo = apply(ckde.small$res.matrix,1,quantile,probs=c(0.025),na.rm=TRUE)
ckde.small.plot$hi = apply(ckde.small$res.matrix,1,quantile,probs=c(0.975),na.rm=TRUE)
ckde.small.plot = subset(ckde.small.plot,!is.na(mean))
ckde.tiny.plot = data.frame(CalBP=timeRange)
ckde.tiny.plot$mean = apply(ckde.tiny$res.matrix,1,mean)
ckde.tiny.plot$lo = apply(ckde.tiny$res.matrix,1,quantile,probs=c(0.025),na.rm=TRUE)
ckde.tiny.plot$hi = apply(ckde.tiny$res.matrix,1,quantile,probs=c(0.975),na.rm=TRUE)
ckde.tiny.plot = subset(ckde.tiny.plot,!is.na(mean))
# OxCal
load(here('results','oxcal_kde_res.RData'))
oxcal.large.plot = data.frame(CalBP=out.large.oxcal$calBP)
oxcal.large.plot$mean = out.large.oxcal$m
oxcal.large.plot$lo = out.large.oxcal$lo
oxcal.large.plot$hi = out.large.oxcal$hi
oxcal.small.plot = data.frame(CalBP=out.small.oxcal$calBP)
oxcal.small.plot$mean = out.small.oxcal$m
oxcal.small.plot$lo = out.small.oxcal$lo
oxcal.small.plot$hi = out.small.oxcal$hi
oxcal.tiny.plot = data.frame(CalBP=out.tiny.oxcal$calBP)
oxcal.tiny.plot$mean = out.tiny.oxcal$m
oxcal.tiny.plot$lo = out.tiny.oxcal$lo
oxcal.tiny.plot$hi = out.tiny.oxcal$hi

# Gaussian Mixture
load(here('results','baydem_res.RData'))


# Plot figure
pdf(file=here('figures','figure1.pdf'),width=10,height=10)
par(mfrow=c(3,3))
plot(NULL,type='l',xlim=c(7000,3000),ylim=c(0,max(ckde.large.plot$hi,na.rm=T)),xlab='CalBP',ylab='KDE',main='a')
polygon(c(7000:3000,3000,7000),c(sim$PrDens,0,0),border=NA,col='lightgrey')
polygon(c(ckde.large.plot$CalBP,rev(ckde.large.plot$CalBP)),c(ckde.large.plot$lo,rev(ckde.large.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(ckde.large.plot$CalBP,ckde.large.plot$mean,lwd=2,lty=2)

plot(NULL,type='l',xlim=c(7000,3000),ylim=c(0,max(ckde.small.plot$hi,na.rm=T)),xlab='CalBP',ylab='KDE',main='b')
polygon(c(7000:3000,3000,7000),c(sim$PrDens,0,0),border=NA,col='lightgrey')
polygon(c(ckde.small.plot$CalBP,rev(ckde.small.plot$CalBP)),c(ckde.small.plot$lo,rev(ckde.small.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(ckde.small.plot$CalBP,ckde.small.plot$mean,lwd=2,lty=2)

plot(NULL,type='l',xlim=c(7000,3000),ylim=c(0,max(ckde.tiny.plot$hi,na.rm=T)),xlab='CalBP',ylab='KDE',main='c')
polygon(c(7000:3000,3000,7000),c(sim$PrDens,0,0),border=NA,col='lightgrey')
polygon(c(ckde.tiny.plot$CalBP,rev(ckde.tiny.plot$CalBP)),c(ckde.tiny.plot$lo,rev(ckde.tiny.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(ckde.tiny.plot$CalBP,ckde.tiny.plot$mean,lwd=2,lty=2)


plot(NULL,type='l',xlim=c(7000,3000),ylim=c(0,max(oxcal.large.plot$hi,na.rm=T)),xlab='CalBP',ylab='KDE',main='d')
polygon(c(7000:3000,3000,7000),c(sim$PrDens*5*sum(oxcal.large.plot$mean),0,0),border=NA,col='lightgrey')
polygon(c(oxcal.large.plot$CalBP,rev(oxcal.large.plot$CalBP)),c(oxcal.large.plot$lo,rev(oxcal.large.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(oxcal.large.plot$CalBP,oxcal.large.plot$mean,lwd=2,lty=2)

plot(NULL,type='l',xlim=c(7000,3000),ylim=c(0,max(oxcal.small.plot$hi,na.rm=T)),xlab='CalBP',ylab='KDE',main='e')
polygon(c(7000:3000,3000,7000),c(sim$PrDens*5*sum(oxcal.small.plot$mean),0,0),border=NA,col='lightgrey')
polygon(c(oxcal.small.plot$CalBP,rev(oxcal.small.plot$CalBP)),c(oxcal.small.plot$lo,rev(oxcal.small.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(oxcal.small.plot$CalBP,oxcal.small.plot$mean,lwd=2,lty=2)

plot(NULL,type='l',xlim=c(7000,3000),ylim=c(0,max(oxcal.tiny.plot$hi,na.rm=T)),xlab='CalBP',ylab='KDE',main='f')
polygon(c(7000:3000,3000,7000),c(sim$PrDens*5*sum(oxcal.tiny.plot$mean),0,0),border=NA,col='lightgrey')
polygon(c(oxcal.tiny.plot$CalBP,rev(oxcal.tiny.plot$CalBP)),c(oxcal.tiny.plot$lo,rev(oxcal.tiny.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(oxcal.tiny.plot$CalBP,oxcal.tiny.plot$mean,lwd=2,lty=2)


plot(NULL,type='n',xlim=c(7000,3000),ylim=c(0,max(baydem.large.plot$hi,na.rm=T)),xlab='CalBP',ylab='Probability',main='g')
polygon(c(7000:3000,3000,7000),c(sim$PrDens,0,0),border=NA,col='lightgrey')
polygon(c(baydem.large.plot$CalBP,rev(baydem.large.plot$CalBP)),c(baydem.large.plot$lo,rev(baydem.large.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(baydem.large.plot$CalBP,baydem.large.plot$m,lwd=2,lty=2)

plot(NULL,type='n',xlim=c(7000,3000),ylim=c(0,max(baydem.small.plot$hi,na.rm=T)),xlab='CalBP',ylab='Probability',main='h')
polygon(c(7000:3000,3000,7000),c(sim$PrDens,0,0),border=NA,col='lightgrey')
polygon(c(baydem.small.plot$CalBP,rev(baydem.small.plot$CalBP)),c(baydem.small.plot$lo,rev(baydem.small.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(baydem.small.plot$CalBP,baydem.small.plot$m,lwd=2,lty=2)

plot(NULL,type='n',xlim=c(7000,3000),ylim=c(0,max(baydem.tiny.plot$hi,na.rm=T)),xlab='CalBP',ylab='Probability',main='i')
polygon(c(7000:3000,3000,7000),c(sim$PrDens,0,0),border=NA,col='lightgrey')
polygon(c(baydem.tiny.plot$CalBP,rev(baydem.tiny.plot$CalBP)),c(baydem.tiny.plot$lo,rev(baydem.tiny.plot$hi)),border=NA,col=rgb(0,0,1,0.2))
lines(baydem.tiny.plot$CalBP,baydem.tiny.plot$m,lwd=2,lty=2)

dev.off()

