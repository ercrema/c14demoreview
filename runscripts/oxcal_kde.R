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

kde.prepare(cra=small$cra,cra.error=small$cra.error,fn=here('runscripts','oxcalscripts','run_small.oxcal'))
kde.prepare(cra=large$cra,cra.error=small$cra.error,fn=here('runscripts','oxcalscripts','run_large.oxcal'))

quickSetupOxcal()
oxcalscript.small<- read_file(here('runscripts','oxcalscripts','run_small.oxcal'))
oxcalscript.large<- read_file(here('runscripts','oxcalscripts','run_large.oxcal'))
result_file_small <- executeOxcalScript(oxcalscript.small)
result_file_large <- executeOxcalScript(oxcalscript.large)
res_small <- readLines(result_file_small)
res_large <- readLines(result_file_large)
out.small <- read_kde(res_small,sigma=1.96)
out.large <- read_kde(res_large,sigma=1.96)

save(res_small,res_large,out.small,out.large,file=here('results','oxcal_kde_res.RData'))
