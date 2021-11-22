library(here)
library(baydem)

# Small Sample ----
small.data <- import_rc_data(here('data','small_sim1_sample.csv'),phi_m_col='phi_m',sig_m_col='sig_m')
set_rc_meas(here('results'),"baydem_small_res",small.data)
analysis <- readRDS(here('results','baydem_small_res.rds'))
tau_range <- calc_tau_range(analysis$rc_meas,calibration_curve="intcal20",dtau=5)
density_model <- list(type="trunc_gauss_mix", tau_min=tau_range$tau_min,tau_max=tau_range$tau_max,K=2:20)
set_density_model(here('results'),"baydem_small_res",density_model)
set_calib_curve(here('results'),"baydem_small_res","intcal20")
analysis <- readRDS(here('results','baydem_small_res.rds'))
hp <- list()
# Parameter for the dirichlet draw of the mixture probabilities
hp$alpha_d <- 1 
# The gamma distribution shape parameter for sigma
hp$alpha_s <- 5
# The gamma distribution rate parameter for sigma, yielding a mode of 50
hp$alpha_r <- (5 - 1) / 500
# Spacing for the measurement matrix (years)
hp$dtau <- 1

# Run Bayesian Analyses in Stan
do_bayesian_inference(here('results'),"baydem_small_res",hp,control=list(samps_per_chain=5000))

# Bayesian Summary
do_bayesian_summary(here('results'),"baydem_small_res")


# Large Sample -----
large.data <- import_rc_data(here('data','large_sim1_sample.csv'),phi_m_col='phi_m',sig_m_col='sig_m')
set_rc_meas(here('results'),"baydem_large_res",large.data)
analysis <- readRDS(here('results','baydem_large_res.rds'))
tau_range <- calc_tau_range(analysis$rc_meas,calibration_curve="intcal20",dtau=5)
density_model <- list(type="trunc_gauss_mix", tau_min=tau_range$tau_min,tau_max=tau_range$tau_max,K=2:20)
set_density_model(here('results'),"baydem_large_res",density_model)
set_calib_curve(here('results'),"baydem_large_res","intcal20")
analysis <- readRDS(here('results','baydem_large_res.rds'))
hp <- list()
# Parameter for the dirichlet draw of the mixture probabilities
hp$alpha_d <- 1 
# The gamma distribution shape parameter for sigma
hp$alpha_s <- 5
# The gamma distribution rate parameter for sigma, yielding a mode of 50
hp$alpha_r <- (5 - 1) / 500
# Spacing for the measurement matrix (years)
hp$dtau <- 1

# Run Bayesian Analyses in Stan
do_bayesian_inference(here('results'),"baydem_large_res",hp,control=list(samps_per_chain=5000))


# Bayesian Summary
do_bayesian_summary(here('results'),"baydem_large_res")

# Exctract best fitted model estimates ----
baydem.small <- readRDS(here('results','baydem_small_res.rds'))
bestK.small <- baydem.small$K_best
baydem.small.plot <- data.frame(CalBP=BCADtoBP(baydem.small$bayesian_summary$tau))
ind.lo.small <- which(baydem.small$bayesian_summary$probs == 0.025)
ind.hi.small <- which(baydem.small$bayesian_summary$probs == 0.975)
ind.m.small <- which(baydem.small$bayesian_summary$probs == 0.5)
baydem.small.plot$lo <- baydem.small$bayesian_summary$Qdens[ind.lo.small,]
baydem.small.plot$hi <- baydem.small$bayesian_summary$Qdens[ind.hi.small,]
baydem.small.plot$m <- baydem.small$bayesian_summary$Qdens[ind.m.small,]

baydem.large <- readRDS(here('results','baydem_large_res.rds'))
bestK.large <- baydem.large$K_best
baydem.large.plot <- data.frame(CalBP=BCADtoBP(baydem.large$bayesian_summary$tau))
ind.lo.large <- which(baydem.large$bayesian_summary$probs == 0.025)
ind.hi.large <- which(baydem.large$bayesian_summary$probs == 0.975)
ind.m.large <- which(baydem.large$bayesian_summary$probs == 0.5)
baydem.large.plot$lo <- baydem.large$bayesian_summary$Qdens[ind.lo.large,]
baydem.large.plot$hi <- baydem.large$bayesian_summary$Qdens[ind.hi.large,]
baydem.large.plot$m <- baydem.large$bayesian_summary$Qdens[ind.m.large,]

save(bestK.small,bestK.large,baydem.small.plot,baydem.large.plot,file=here('results','baydem_res.RData'))



