library(rcarbon)
library(here)
library(oxcAAR)
library(readr)
source(here('src','kde_prepare.R'))
source(here('src','kde_read.R'))


# Read Data ----
large <- read.csv(file=here('data','large_sim1_sample.csv'))
small <- read.csv(file=here('data','small_sim1_sample.csv'))
tiny <- read.csv(file=here('data','tiny_sim1_sample.csv'))

kde.prepare(cra=small$cra,cra.error=small$cra.error,fn=here('runscripts','oxcalscripts','run_small.oxcal'))
kde.prepare(cra=large$cra,cra.error=large$cra.error,fn=here('runscripts','oxcalscripts','run_large.oxcal'))
kde.prepare(cra=tiny$cra,cra.error=tiny$cra.error,fn=here('runscripts','oxcalscripts','run_tiny.oxcal'))

quickSetupOxcal()
oxcalscript.tiny<- read_file(here('runscripts','oxcalscripts','run_tiny.oxcal'))
oxcalscript.small<- read_file(here('runscripts','oxcalscripts','run_small.oxcal'))
oxcalscript.large<- read_file(here('runscripts','oxcalscripts','run_large.oxcal'))
result_file_tiny <- executeOxcalScript(oxcalscript.tiny)
result_file_small <- executeOxcalScript(oxcalscript.small)
result_file_large <- executeOxcalScript(oxcalscript.large)
res_tiny.oxcal <- readLines(result_file_tiny)
res_small.oxcal <- readLines(result_file_small)
res_large.oxcal <- readLines(result_file_large)
out.tiny.oxcal <- read_kde(res_tiny.oxcal,sigma=1.96)
out.small.oxcal <- read_kde(res_small.oxcal,sigma=1.96)
out.large.oxcal <- read_kde(res_large.oxcal,sigma=1.96)

save(res_tiny.oxcal,res_small.oxcal,res_large.oxcal,out.tiny.oxcal,out.small.oxcal,out.large.oxcal,file=here('results','oxcal_kde_res.RData'))
