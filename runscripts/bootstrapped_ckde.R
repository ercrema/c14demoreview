library(rcarbon)
library(here)

# Read Data ----
large <- read.csv(file=here('data','large_sim1_sample.csv'))
small <- read.csv(file=here('data','small_sim1_sample.csv'))
sim <- read.csv(file=here('data','sim1.csv'))
# Calibrate ----
cal.large <- calibrate(large$cra,large$cra.error)
cal.small <- calibrate(small$cra,small$cra.error)

# Bootstrapping ----
boot.large <- sampleDates(cal.large,nsim=1000,boot=TRUE)
boot.small <- sampleDates(cal.small,nsim=1000,boot=TRUE)

# Composite KDE ---
ckde.large <- ckde(boot.large,timeRange=c(7000,3000),bw=50)
ckde.small <- ckde(boot.small,timeRange=c(7000,3000),bw=50)

save(ckde.large,ckde.small,file=here('results','ckde_res.RData'))
