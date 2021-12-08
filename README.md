# R scripts for replicating the analyses in "Statistical inference of prehistoric demography using radiocarbon dates: a review and a guide for the perplexed"

This repository contains R scripts for replicating the simulation experiments featured on figures 1 & 2 in the manuscript "Statistical inference of prehistoric demography using radiocarbon dates: a review and a guide for the perplexed" by E.Crema. 

## Structure of the repository

## Simulations
The scripts `runscripts/simulate1.R` and `runscripts/simulate2.R` generate two sets of simulated radiocarbon datasets examined respectively in figures 1 and 2 in the manuscript.  `runscripts/simulate1.R` samples three sets of radiocarbon dates of different sizes (n = 10, 100, and 1,000) from a logistic population growth model with time-varying carrying capacity bounded between 7000 and 3000 cal BP. The script generates: 1) a CSV file containing the probability mass for each calendar year for the population model (`data/sim1.CSV`); and 2) three CSV files containing the sampled radiocarbon dates (`data/small_sim1_sample.csv`, `data/medium_sim1_sample.csv`, and `data/large_sim1_sample.csv`). `runscripts/simulate1.R` two sets of radiocarbon dates (n=50 and n=500) from an truncated exponential growth model with a growth rate of 0.002 and bounded between 6500 and 4500 cal BP. The sampled radiocarbon dates of the two sets are stroed in the R image file `data/sim2.RData`.  

## Analyses

### Figure 1

#### Bootstrapped cKDE 
Composite Kernel Density Estimate (cKDE) on bootstrapped sampled calendar dates from calibrated distributions were computed using the [rcarbon](https://CRAN.R-project.org/package=rcarbon) R package version 1.4.1 using 1,000 iterations and a kernel bandwidth of 50 years (see `runscripts/bootstrapped_ckde.R`). Results are stored in the R image file `results/ckde_res.RData`.  The full script required to execute the analyses is stored in the file  `runscripts/bootstrapped_ckde.R`.  

#### _KDE Model_ 
[OxCal](https://c14.arch.ox.ac.uk/oxcal.html) version 4.4.4 was used to locally run the `KDE_Model` function. OxCal scripts are contained in the folder `runscripts/oxcalscripts/` and were generated using the custom R function `kde_prepare()` (`src/kde_prepare.R`). The functions were executed from within R using the [oxcAAR](https://CRAN.R-project.org/package=oxcAAR) R Package version 1.1.1, and the outputs were read through the custom R function `read_kde()` (`src/kde_read.R`) and are stored in the R image file `results/oxcal_kde_res.RData`. The full script required to execute the analyses is stored in the file  `runscripts/oxcal_kde.R`.  

#### Gaussian Mixture 
Finite Gaussian Mixture analyses were carried out using the [baydem](https://github.com/eehh-stanford/baydem) R package version 1.0.0. For each of the dataset 19 models were fitted with the number of mixture components _K_ ranging from 2 to 20. The parameter for the dirichlet draw of the mixture probabilities (`alpha_d`) was set to 1, whilst priors for the gamma distribution were set to `alpha_s` = 5 and `alpha_r` = 0.008. The spacing for the measurement matrix was set to 1 year. MCMC were executed by running four chains with 5000 iterations each. Due to the extremely large size of the baydem output, only the most relevant information were extracted and stored in the R image file `results/baydem_res.RData`. The full script required to execute the analyses is stored in the file `runscripts/baydem_gauss_mixture.R`.      

### Figure 2

#### GLM (Generalised Linear Model)



#### Radiocarbon-dated Event Count model

#### Maximum Likelihood Approach
Maximum likelihood approach model fitting were carried out using the [ADMUR](https://CRAN.R-project.org/package=ADMUR) R package version 1.0.3. 


#### Bayesian Hierarchichal model with measurement error
Bayesian Hierarchical model fitting with measurement error were carriou using the [nimbleCarbon](https://CRAN.R-project.org/package=nimbleCarbon) R package version 0.1.2.

#### Approximate Bayesian Computation
Approximate Batesian Computation (ABC) was carried out using a custom script (`src/abc_sim_exp.R`) based on routines made available on the [rcarbon](https://CRAN.R-project.org/package=rcarbon) R package and introduced in [Di Napoli et al 2021](https://doi.org/10.1038/s41467-021-24252-z). Fit between candidate and target SPDs were computed by calculating the euclidean distance of between normalised probabilities of corresponding years. The posterior distribution was obtained using the rejection algorithm with a tolerance level of 0.1% and 100,000 simulations. The full script required to execute the analyses is stored in the file `runscripts/abc.R`. Results are stored in the R image file `results/abc_res.RData`.       

## Notes on Computing Requirement and Costs


## Funding
This research was supported by a Philip Leverhulme Prize (PLP-2019-304). 

## Licence
CC-BY 3.0

