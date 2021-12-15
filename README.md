# R scripts for replicating the analyses in "Statistical inference of prehistoric demography using radiocarbon dates: a review and a guide for the perplexed"

This repository contains R scripts for replicating the simulation experiments featured on figures 1 & 2 in the manuscript "Statistical inference of prehistoric demography using radiocarbon dates: a review and a guide for the perplexed" by E.Crema. 

## Simulations
The scripts `runscripts/simulate1.R` and `runscripts/simulate2.R` generate two sets of simulated radiocarbon datasets examined respectively in figures 1 and 2 in the manuscript.  `runscripts/simulate1.R` samples three sets of radiocarbon dates of different sizes (n = 10, 100, and 1,000) from a logistic population growth model with time-varying carrying capacity bounded between 7000 and 3000 cal BP. The script generates: 1) a CSV file containing the probability mass for each calendar year for the population model (`data/sim1.CSV`); and 2) three CSV files containing the sampled radiocarbon dates (`data/small_sim1_sample.csv`, `data/medium_sim1_sample.csv`, and `data/large_sim1_sample.csv`). `runscripts/simulate1.R` two sets of radiocarbon dates (n=50 and n=500) from an truncated exponential growth model with a growth rate of 0.002 and bounded between 6500 and 4500 cal BP. The sampled radiocarbon dates of the two sets are stored in the R image file `data/sim2.RData`. The scripts for generating the two figures are contained in the files `figures/figure1.R` and `figures/figure2.R`.

## Analyses

### Figure 1 (Simulation n.1)

#### Bootstrapped cKDE 
Composite Kernel Density Estimate (cKDE) on bootstrapped sampled calendar dates from calibrated distributions were computed using the [rcarbon](https://CRAN.R-project.org/package=rcarbon) R package version 1.4.2 using 1,000 iterations and a kernel bandwidth of 50 years (see `runscripts/bootstrapped_ckde.R`). Results are stored in the R image file `results/ckde_res.RData`.  The full script required to execute the analyses is stored in the file  `runscripts/bootstrapped_ckde.R`.  

#### _KDE Model_ 
[OxCal](https://c14.arch.ox.ac.uk/oxcal.html) version 4.4.4 was used to locally run the `KDE_Model` function. OxCal scripts are contained in the folder `runscripts/oxcalscripts/` and were generated using the custom R function `kde_prepare()` (`src/kde_prepare.R`). The functions were executed from within R using the function `executeOxcal()` (`src/executeOxcal.R`) adapted from the [oxcAAR](https://CRAN.R-project.org/package=oxcAAR) R Package version 1.1.1. Raw oxcal outputs were saved in a subdirectory (`results/oxcal_res/*`), read in R through the custom function `read_kde()` (`src/kde_read.R`), processed, and stored in the R image file `results/oxcal_kde_res.RData`. The full script required to execute the analyses is stored in the file  `runscripts/oxcal_kde.R`.  

#### Gaussian Mixture 
Finite Gaussian Mixture analyses were carried out using the [baydem](https://github.com/eehh-stanford/baydem) R package version 1.0.0. For each of the dataset 19 models were fitted with the number of mixture components _K_ ranging from 2 to 20. The parameter for the dirichlet draw of the mixture probabilities (`alpha_d`) was set to 1, whilst priors for the gamma distribution were set to `alpha_s` = 5 and `alpha_r` = 0.008. The spacing for the measurement matrix was set to 1 year. MCMC were executed by running four chains with 5000 iterations each. Due to the extremely large size of the baydem output, only the most relevant information were extracted and stored in the R image file `results/baydem_res.RData`. The full script required to execute the analyses is stored in the file `runscripts/baydem_gauss_mixture.R`.      

### Figure 2 (Simulation n.2)

#### Regression Fit on SPD
Direct regression based fit on the normalised SPDs were carried out using the `nls()` function (`runscripts/nls.R`). Results are stored in the R image file `results/glm_res.RData`.

#### Radiocarbon-dated Event Count model
Radiocarbon-dated Event Count model were employed adapting the R script provided in the supplementary material from [Carleton 2021](https://doi.org/10.1002/jqs.3256). The model was fitted on 100 sets of sampled event count sequences based on 1 year temporal bins. All other settings were left unchanged from the script provided in the suppementary material with the exception for the prior of the growth rate (parameter `B`) which was updated to a weakly informative Gaussian with a mean of 0 and a standard deviation of 0.1. To ensure a satisfactory convergence the model was fitted over three chains using 6 million iterations (half used as burnin) sampled every 300 steps. Convergence was assessed computing Gelman-Rubin's diagnostic, which returned an Rhat equal to 1. The full script required to execute the analyses can be found in the file `runscripts/rec.R`. Results are stored in the R image file `results/rec_res.RData`. 

#### Maximum Likelihood Approach
Maximum likelihood approach model fitting were carried out using the [ADMUR](https://CRAN.R-project.org/package=ADMUR) R package version 1.0.3. Parameter uncertainties were measured using the `mcmc()` function with 100,000 iterations, 2,000 burn-in steps, a thinning interval of 5, with a jump parameter of 0.0004.The full script required to execute the analyses can be found in the file `runscripts/admur.R`. Results are stored in the R image file `results/admur_res.RData`. 

#### Bayesian Hierarchichal model with measurement error
Bayesian Hierarchical model fitting with measurement error were carried out using the [nimbleCarbon](https://CRAN.R-project.org/package=nimbleCarbon) R package version 0.1.2. Posterior parameters were obtained by running three chains with 10,000 iterations with 3,000 steps used as burnin. Convergence was assessed computing Gelman-Rubin's diagnostic, which returned an Rhat equal to 1. The full script required to execute the analyses can be found in the file `runscripts/nimbleCarbon.R`. Results are stored in the R image file `results/nimbleCarbon_res.RData`. 

#### Approximate Bayesian Computation
Approximate Batesian Computation (ABC) was carried out using a custom script (`src/abc_sim_exp.R`) based on routines made available on the [rcarbon](https://CRAN.R-project.org/package=rcarbon) R package and introduced in [Di Napoli et al 2021](https://doi.org/10.1038/s41467-021-24252-z). Fit between candidate and target SPDs were computed by calculating the euclidean distance of between normalised probabilities of corresponding years. The posterior distribution was obtained using the rejection algorithm with a tolerance level of 0.1% and 250,000 simulations. The full script required to execute the analyses is stored in the file `runscripts/abc.R`. Results are stored in the R image file `results/abc_res.RData`.       

## Notes on Computing Requirement and Costs
Please not that the execution of the scripts `baydem_gauss_mixture.R`, `rec.R`, and `abc.R` require multiple cores, and that the runtime for `abc.R`, `oxcal_kde.R`, `baydem_gauss_mixture.R`, and `rec.R` is over 24 hours. 

## Structure of the repository
```
.
├── c14demoreview.Rproj
├── data
│   ├── large_sim1_sample.csv
│   ├── sim1.csv
│   ├── sim2.RData
│   ├── simulate1.R
│   ├── simulate2.R
│   ├── small_sim1_sample.csv
│   └── tiny_sim1_sample.csv
├── figures
│   ├── figure1.pdf
│   ├── figure1.R
│   ├── figure2.pdf
│   └── figure2.R
├── README.md
├── results
│   ├── abc_res.RData
│   ├── admur_res.RData
│   ├── baydem_res.RData
│   ├── ckde_res.RData
│   ├── glm_res.RData
│   ├── nimbleCarbon_res.RData
│   ├── oxcal_kde_res.RData
│   ├── oxcal_res
│   │   ├── large_res
│   │   ├── large_res.js
│   │   ├── large_res.log
│   │   ├── large_res.txt
│   │   ├── small_res
│   │   ├── small_res.js
│   │   ├── small_res.log
│   │   ├── small_res.txt
│   │   ├── tiny_res
│   │   ├── tiny_res.js
│   │   ├── tiny_res.log
│   │   └── tiny_res.txt
│   └── rec_res.RData
├── runscripts
│   ├── abc.R
│   ├── admur.R
│   ├── baydem_gauss_mixture.R
│   ├── bootstrapped_ckde.R
│   ├── nimbleCarbon.R
│   ├── nls.R
│   ├── oxcal_kde.R
│   ├── oxcalscripts
│   │   ├── run_large.oxcal
│   │   ├── run_small.oxcal
│   │   └── run_tiny.oxcal
│   └── rec.R
└── src
    ├── abc_sim_exp.R
    ├── executeOxcal.R
    ├── kde_prepare.R
    └── kde_read.R


```

## R Packages
```
attached base packages:
[1] parallel  stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] coda_0.19-4        DEoptimR_1.0-9     here_1.0.1         doSNOW_1.0.19     
 [5] snow_0.4-4         iterators_1.0.13   foreach_1.5.1      oxcAAR_1.1.1      
 [9] ADMUR_1.0.3        rcarbon_1.4.2      nimbleCarbon_0.1.2 nimble_0.12.1     
[13] baydem_1.0.0       magrittr_2.0.1    

loaded via a namespace (and not attached):
  [1] minqa_1.2.4           colorspace_2.0-2      deldir_1.0-6         
  [4] ellipsis_0.3.2        ggridges_0.5.3        brms_2.15.0          
  [7] rprojroot_2.0.2       rsconnect_0.8.24      markdown_1.1         
 [10] base64enc_0.1-3       spatstat.data_2.1-0   rstan_2.21.2         
 [13] DT_0.18               fansi_0.5.0           mvtnorm_1.1-2        
 [16] mathjaxr_1.4-0        bridgesampling_1.1-2  codetools_0.2-18     
 [19] splines_4.1.2         doParallel_1.0.16     knitr_1.36           
 [22] shinythemes_1.2.0     polyclip_1.10-0       bayesplot_1.8.1      
 [25] projpred_2.0.2        jsonlite_1.7.2        nloptr_1.2.2.2       
 [28] spatstat.linnet_2.3-0 spatstat.sparse_2.0-0 shiny_1.6.0          
 [31] compiler_4.1.2        backports_1.3.0       assertthat_0.2.1     
 [34] Matrix_1.3-4          fastmap_1.1.0         cli_3.1.0            
 [37] later_1.2.0           htmltools_0.5.1.1     prettyunits_1.1.1    
 [40] tools_4.1.2           igraph_1.2.7          gtable_0.3.0         
 [43] glue_1.5.0            reshape2_1.4.4        dplyr_1.0.7          
 [46] spatstat_2.2-0        V8_3.4.2              Rcpp_1.0.7           
 [49] vctrs_0.3.8           nlme_3.1-153          crosstalk_1.1.1      
 [52] xfun_0.28             stringr_1.4.0         ps_1.6.0             
 [55] lme4_1.1-27.1         mime_0.11             miniUI_0.1.1.1       
 [58] lifecycle_1.0.1       gtools_3.9.2          goftest_1.2-3        
 [61] MASS_7.3-54           zoo_1.8-9             scales_1.1.1         
 [64] spatstat.core_2.3-2   colourpicker_1.1.0    promises_1.2.0.1     
 [67] spatstat.utils_2.2-0  Brobdingnag_1.2-6     inline_0.3.19        
 [70] shinystan_2.5.0       gamm4_0.2-6           curl_4.3.2           
 [73] gridExtra_2.3         ggplot2_3.3.5         loo_2.4.1            
 [76] StanHeaders_2.21.0-7  rpart_4.1-15          stringi_1.7.5        
 [79] dygraphs_1.1.1.6      boot_1.3-28           pkgbuild_1.2.0       
 [82] rlang_0.4.12          pkgconfig_2.0.3       matrixStats_0.61.0   
 [85] lattice_0.20-45       tensor_1.5            purrr_0.3.4          
 [88] rstantools_2.1.1      htmlwidgets_1.5.3     processx_3.5.2       
 [91] tidyselect_1.1.1      plyr_1.8.6            R6_2.5.1             
 [94] generics_0.1.1        DBI_1.1.1             pillar_1.6.4         
 [97] withr_2.4.2           mgcv_1.8-36           xts_0.12.1           
[100] abind_1.4-5           sp_1.4-6              tibble_3.1.5         
[103] crayon_1.4.2          utf8_1.2.2            spatstat.geom_2.3-0  
[106] grid_4.1.2            callr_3.7.0           threejs_0.3.3        
[109] digest_0.6.28         xtable_1.8-4          httpuv_1.6.1         
[112] RcppParallel_5.1.4    stats4_4.1.2          munsell_0.5.0        
[115] shinyjs_2.0.0   
```

## Funding
This research was supported by a Philip Leverhulme Prize (PLP-2019-304). 

## Licence
CC-BY 3.0

