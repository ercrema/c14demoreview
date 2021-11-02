library(here)
library(baydem)
rc_meas <- import_rc_data(here('data','sample_data.csv'),phi_m_col='phi_m',sig_m_col='sig_m')
rc_save_file <- file.path("./", "rc_example_small.rds")
analysis_name <- "rc_example_small"
set_rc_meas("./",analysis_name,rc_meas)
analysis <- readRDS(rc_save_file)
tau_range <- calc_tau_range(analysis$rc_meas,calibration_curve="intcal20",dtau=5)
density_model <- list(type="trunc_gauss_mix", tau_min=tau_range$tau_min,tau_max=tau_range$tau_max,K=2:5)
set_density_model('./',analysis_name,density_model)
set_calib_curve('./',analysis_name,"intcal20")
analysis <- readRDS(rc_save_file)
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
do_bayesian_inference("./",analysis_name,hp)

# Store Output
analysis <- readRDS(rc_save_file)
