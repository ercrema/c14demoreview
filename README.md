# R scripts for replicating the analyses in "Statistical inference of prehistoric demography using radiocarbon dates: a review and a guide for the perplexed"

This repository contains R scripts for replicating the simulation experiments featured on figures 1 & 2 in the manuscript "Statistical inference of prehistoric demography using radiocarbon dates: a review and a guide for the perplexed" by E.Crema. 

## Structure of the repository

## Simulations
The scripts `runscripts/simulate1.R` and `runscripts/simulate2.R` generate two sets of simulated radiocarbon datasets examined respectively in figures 1 and 2 in the manuscript.  `runscripts/simulate1.R` samples three sets of radiocarbon dates of different sizes (n = 10, 100, and 1,000) from a logistic population growth model with time-varying carrying capacity bounded between 7000 and 3000 cal BP. The script generates: 1) a CSV file containing the probability mass for each calendar year for the population model (`data/sim1.CSV`); and 2) three CSV files containing the sampled radiocarbon dates (`data/small_sim1_sample.csv`, `data/medium_sim1_sample.csv`, and `data/large_sim1_sample.csv`). `runscripts/simulate1.R` two sets of radiocarbon dates (n=50 and n=500) from an truncated exponential growth model with growth rate 0.002 and bounded between 6500 and 4500 cal BP. The sampled radiocarbon dates of the two sets are stroed in the R image file `data/sim2.RData`.  

## Analyses

### Figure 1

#### Bootstrapped cKDE 

#### _KDE Model_ 

#### Gaussian Mixture 

### Figure 2

#### GLM (Generalised Linear Model)

#### Radiocarbon-dated Event Count model

#### Maximum Likelihood Approach

#### Bayesian Hierarchichal model with measurement error

#### Approximate Bayesian Computation


## Notes on Computing Requirement and Costs


## Funding
This research was supported by a Philip Leverhulme Prize (PLP-2019-304). 

## Licence
CC-BY 3.0

