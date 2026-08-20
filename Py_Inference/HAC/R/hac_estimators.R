#====================================================
# In here we 
# 1) simulate three different processes
#       a) regression model with that meets GM assumptions
#       b) regression model with heteroskedastic errors
#       c) regression model with AC errors
# 2) Perform parameter inference using normal, White and NW se
# 3) Evaluate whether tests have correct size
#
#====================================================

# Clear the environment
rm(list = ls())

# Clear console
cat("\014")

# Load necessary functions
source('armasim.R')
source('OLShac.R')

# Set the seed for reproducibility
set.seed(123467)

# Parameters for DGP
# y = x*b + u
n <- 200                     # length of the simulated series
nsim <- 10000                # number of simulations
x <- cbind(1, matrix(rnorm(n * 2), n, 2))  # constant and two randomly generated series
b <- c(0.5, 1.0, -0.5)       # true parameter vector
sig <- 0.1                   # standard deviation of error terms

# Parameters for the AR error terms
p <- 1        # AR order
q <- 1        # MA order
alpha <- 0.0  # constant
phi <- 0.9    # AR parameter
theta <- 0.7  # MA parameter
sigar <- 0.1  # standard error of innovation term

# Initialize matrix to save t-statistics for DGP with ARMA errors
# Col 1: OLS se, Col 2: White, Col 3: NW
# Only save results for b[2]
tsave <- matrix(0, nrow = nsim, ncol = 3)

# Simulate model with GM (gmerr), heteroskedastic (hserr) or
# autocorrelated (arerr) errors
cat("\nRunning Monte Carlo simulation...\n")
for (i in 1:nsim) {
  # Uncomment one of the following error specifications:
  # gmerr <- rnorm(n) * sig                                    # GM errors
  # hserr <- c(rnorm(n/2) * sig, rnorm(n/2) * (sig/5))         # heteroskedastic errors
  arerr <- armasim(n, p, q, alpha, phi, theta, sigar)          # AR errors
  
  y <- x %*% b + arerr                      # DGP with selected errors
  results <- OLShac(y, x, output = 0)       # estimate and save results
  bmb0 <- results$b[2] - b[2]               # difference of estimated value from true value
  tsave[i, ] <- c(bmb0 / results$bse[2], 
                  bmb0 / results$wh_bse[2], 
                  bmb0 / results$nw_bse[2])
  
  # Progress indicator
  if (i %% 1000 == 0) {
    cat(sprintf("Progress: %d/%d (%.1f%%)\n", i, nsim, (i/nsim)*100))
  }
}

# Critical values
cv5 <- qnorm(0.975)                    # 2-tailed 5% cv, Normal
cv1 <- qnorm(0.995)                    # 2-tailed 1% cv, Normal
cv5t <- qt(0.975, df = n - length(b)) # 2-tailed 5% cv, t-Distribution
cv1t <- qt(0.995, df = n - length(b)) # 2-tailed 1% cv, t-Distribution

# Count rejections (1 if test stat exceed cv, 0 otherwise)
count5 <- cbind(abs(tsave[, 1]) > cv5t, abs(tsave[, 2:3]) > cv5)
count1 <- cbind(abs(tsave[, 1]) > cv1t, abs(tsave[, 2:3]) > cv1)

# Calculate proportion of rejections of true H0
prop5 <- colSums(count5) / nsim  # proportion at 5%
prop1 <- colSums(count1) / nsim  # proportion at 1%

# Display results
cat('\n')
cat('===========================================================\n')
cat('Rejections for standard OLS, White and NW based t-tests\n')
cat('===========================================================\n')
cat('   OLS       White       NW\n')
cat('at 5%\n')
cat(sprintf('%7.4f   %7.4f   %7.4f\n', prop5[1], prop5[2], prop5[3]))
cat('at 1%\n')
cat(sprintf('%7.4f   %7.4f   %7.4f\n', prop1[1], prop1[2], prop1[3]))
cat('===========================================================\n')
