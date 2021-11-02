library(rcarbon)
library(here)

# Simulate a logistic growth model with K varying as a function of a covariate
x <- c(7000,6600,5900,5300,4600,4000,3900,3500,3200,3100,3000)
y <- c(0.8,1.1,1,0.8,0.2,0.5,0.8,1.5,0.3,0.1,0.2)
env.model  <- lm(y~poly(x,4))
K <- predict(env.model,newdata=data.frame(x=7000:3000))
a <- 7000
b <- 3000
k <- 0.1
r <- 0.0018
t = 1:(abs(b-a)+1)
nt = length(t)
pop2fill = numeric(nt-1)
pop = c(k,pop2fill)
    
for (i in 2:nt)
{
	pop[i] = K[i] / (1 + ((K[i]-pop[i-1])/pop[i-1])*exp(-r))
}
df.prob = data.frame(CalBP=a:b,PrDens= pop/sum(pop))
write.csv(df.prob,file=here('data','sim.csv'))
# Sample Dates
## Large
N = 300
set.seed(123)
cra <- uncalibrate(sample(df.prob$CalBP,size=N,replace = TRUE,prob=df.prob$PrDens))$rCRA
cra.error <- rep(20,N)
phi_m <- exp(-cra / 8033)
sig_m <- cra.error * phi_m / 8033
write.csv(data.frame(cra=cra,cra.error=cra.error,phi_m=phi_m,sig_m=sig_m),file=here('data','large_sim_sample.csv'))
## Small
N = 10
cra <- uncalibrate(sample(df.prob$CalBP,size=N,replace = TRUE,prob=df.prob$PrDens))$rCRA
cra.error <- rep(20,N)
phi_m <- exp(-cra / 8033)
sig_m <- cra.error * phi_m / 8033
write.csv(data.frame(cra=cra,cra.error=cra.error,phi_m=phi_m,sig_m=sig_m),file=here('data','small_sim_sample.csv'))


