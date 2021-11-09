library(here)
library(baydem)

# Small Sample ----
small.data <- import_rc_data(here('data','small_sim_sample.csv'),phi_m_col='phi_m',sig_m_col='sig_m')
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
hp$alpha_s <- 10
# The gamma distribution rate parameter for sigma, yielding a mode of 50
hp$alpha_r <- (10 - 1) / 50
# Spacing for the measurement matrix (years)
hp$dtau <- 1

# Run Bayesian Analyses in Stan
do_bayesian_inference(here('results'),"baydem_small_res",hp)

# Bayesian Summary
do_bayesian_summary(here('results'),"baydem_small_res")


# Large Sample -----
large.data <- import_rc_data(here('data','large_sim_sample.csv'),phi_m_col='phi_m',sig_m_col='sig_m')
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
hp$alpha_s <- 10
# The gamma distribution rate parameter for sigma, yielding a mode of 50
hp$alpha_r <- (10 - 1) / 50
# Spacing for the measurement matrix (years)
hp$dtau <- 1

# Run Bayesian Analyses in Stan
do_bayesian_inference(here('results'),"baydem_large_res",hp)

# Bayesian Summary
do_bayesian_summary(here('results'),"baydem_large_res")
