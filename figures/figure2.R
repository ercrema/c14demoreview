library(here)

# Figure 2 (Comparison of model-fitting approaches) ----
## GLM
load(here('results','glm_res.RData'))

## REC
load(here('results','rec_res.RData'))
rec.fit.large <- mean(do.call(rbind,rec.large1)[,'B'])
rec.ci95.large <- quantile(do.call(rbind,rec.large1)[,'B'],c(0.025,0.975))

rec.fit.small <- mean(do.call(rbind,rec.small1)[,'B'])
rec.ci95.small <- quantile(do.call(rbind,rec.small1)[,'B'],c(0.025,0.975))
## ADMUR 
load(here('results','admur_res.RData'))
admur.fit.large <- exp.large.admur$par
admur.ci95.large <- quantile(chain.large.admur$res,prob=c(0.025,0.975))
admur.fit.small <- exp.small.admur$par
admur.ci95.small <- quantile(chain.small.admur$res,prob=c(0.025,0.975))

## NimbleCarbon
load(here('results','nimbleCarbon_res.RData'))
nc.fit.large = mean(unlist(samples.large.nc))
nc.ci95.large = quantile(unlist(samples.large.nc),c(0.025,0.975))
nc.fit.small = mean(unlist(samples.small.nc))
nc.ci95.small = quantile(unlist(samples.small.nc),c(0.025,0.975))

## ABC
load(here('results','abc_res.RData'))
nsim = nrow(res.abc)
threshold = 0.001
top.skim = nsim*threshold
post.large = res.abc$r[order(res.abc$epsilon.large,decreasing=FALSE)[1:top.skim]]
post.small = res.abc$r[order(res.abc$epsilon.small,decreasing=FALSE)[1:top.skim]]
abc.fit.large = mean(post.large)
abc.ci95.large = quantile(post.large,c(0.025,0.975))
abc.fit.small = mean(post.small)
abc.ci95.small = quantile(post.small,c(0.025,0.975))

## Plot

### Plot Settings
gap = 0.07
col1 = '#66C2A5'
col2 = '#FC8D62'
coldot = 'black'

tiff(file=here('figures','figure2.tiff'),width=150,height=130,units = 'mm',res = 1200)

plot(NULL,xlim=c(1,9.5),ylim=c(0.0006,0.003),axes=FALSE,xlab='',ylab='Exponential Growth Rate')
rect(xleft=1-gap,xright=1+gap,ybottom=glm.ci95.large[1],ytop=glm.ci95.large[2],col=col1,border=NA)
points(1,glm.fit.large,pch=20,col=coldot,cex=1.2)
rect(xleft=1.5-gap,xright=1.5+gap,ybottom=glm.ci95.small[1],ytop=glm.ci95.small[2],col=col2,border=NA)
points(1.5,glm.fit.small,pch=20,col=coldot,cex=1.2)

rect(xleft=3-gap,xright=3+gap,ybottom=rec.ci95.large[1],ytop=rec.ci95.large[2],col=col1,border=NA)
points(3,rec.fit.large,pch=20,col=coldot,cex=1.2)
rect(xleft=3.5-gap,xright=3.5+gap,ybottom=rec.ci95.small[1],ytop=rec.ci95.small[2],col=col2,border=NA)
points(3.5,rec.fit.small,pch=20,col=coldot,cex=1.2)

rect(xleft=5-gap,xright=5+gap,ybottom=admur.ci95.large[1],ytop=admur.ci95.large[2],col=col1,border=NA)
points(5,admur.fit.large,pch=20,col=coldot,cex=1.2)
rect(xleft=5.5-gap,xright=5.5+gap,ybottom=admur.ci95.small[1],ytop=admur.ci95.small[2],col=col2,border=NA)
points(5.5,admur.fit.small,pch=20,col=coldot,cex=1.2)

rect(xleft=7-gap,xright=7+gap,ybottom=nc.ci95.large[1],ytop=nc.ci95.large[2],col=col1,border=NA)
points(7,nc.fit.large,pch=20,col=coldot,cex=1.2)
rect(xleft=7.5-gap,xright=7.5+gap,ybottom=nc.ci95.small[1],ytop=nc.ci95.small[2],col=col2,border=NA)
points(7.5,nc.fit.small,pch=20,col=coldot,cex=1.2)

rect(xleft=9-gap,xright=9+gap,ybottom=abc.ci95.large[1],ytop=abc.ci95.large[2],col=col1,border=NA)
points(9,abc.fit.large,pch=20,col=coldot,cex=1.2)
rect(xleft=9.5-gap,xright=9.5+gap,ybottom=abc.ci95.small[1],ytop=abc.ci95.small[2],col=col2,border=NA)
points(9.5,abc.fit.small,pch=20,col=coldot,cex=1.2)

axis(2)
axis(1,at=c(1.25,3.25,5.25,7.25,9.25),labels=c('a','b','c','d','e'))

abline(h=0.002,lty=2)
legend(x=1.2,y=0.003,legend=c('95% CI with n=500','95% CI with n=50','Mean Estimate'),col=c(col1,col2,1),pch=c(NA,NA,20),lwd=c(7,7,0),pt.cex=1.5,bty='n')
box()
dev.off()
