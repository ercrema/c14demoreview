library(rcarbon)
library(here)
library(oxcAAR)
library(readr)
source(here('src','kde_prepare.R'))
source(here('src','kde_read.R'))


# Read Data ----
large <- read.csv(file=here('data','large_sim_sample.csv'))
small <- read.csv(file=here('data','small_sim_sample.csv'))
sim <- read.csv(file=here('data','sim.csv'))

kde.prepare(cra=small$cra,cra.error=small$cra.error,fn=here('runscripts','run_small.oxcal'))
kde.prepare(cra=large$cra,cra.error=small$cra.error,fn=here('runscripts','run_large.oxcal'))

quickSetupOxcal()
oxcalscript.small<- read_file(here('runscripts','run_small.oxcal'))
oxcalscript.large<- read_file(here('runscripts','run_large.oxcal'))
result_file_small <- executeOxcalScript(oxcalscript.small)
result_file_large <- executeOxcalScript(oxcalscript.large)
res_small <- readLines(result_file_small)
res_large <- readLines(result_file_large)
out.small <- read_kde(res_small,sigma=1.96)
out.large <- read_kde(res_large,sigma=1.96)




# plot(x$calBP,x$m/sum(x$m)/5,type='l',ylim=c(0,max(x$hi)/sum(x$m)/5),xlim=c(7000,3000))
# polygon(c(x$calBP,rev(x$calBP)),c(x$hi/sum(x$m)/5,rev(x$lo/sum(x$m)/5)),border=NA,col=rgb(0,0,1,0.2))
# lines(sim$CalBP,sim$PrDens,col=2,lwd=2)




