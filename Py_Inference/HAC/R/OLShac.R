OLShac <- function(y, x, output = 1, B = 0) {
  # This function performs an OLS estimation
  # input:    y, vector with dependent variable
  #           x, matrix with explanatory variable 
  #               function will automatically add a constant if the first col
  #               is not a vector of ones
  #           output, 1 = printed output
  #           B, lag lengths for Newey-West standard errors
  # output:   List with the following elements:
  #           $b, estimated parameters
  #           $bse, standard errors for bhat
  #           $wh_bse, White standard errors for bhat
  #           $nw_bse, Newey-West standard errors for bhat
  #           $res, estimated residuals
  #           $n, number of observations used
  #           $rss, residual sum of squares
  #           $r2, Rsquared
  
  # Ensure x is a matrix
  if (!is.matrix(x)) {
    x <- as.matrix(x)
  }
  
  # Store initial length for reporting missing observations
  ninit <- length(y)
  
  # Select those rows that have observations for all variables
  complete_cases <- complete.cases(y, x)
  y <- y[complete_cases]
  x <- x[complete_cases, , drop = FALSE]
  
  # Test whether first column is vector of ones
  temp <- x[x[, 1] == 1, 1]
  if (length(temp) != nrow(x)) {
    x <- cbind(1, x)  # add constant if not included in x
  }
  
  n <- nrow(x)  # sample size
  k <- ncol(x)  # number of explanatory vars (incl constant)
  
  xxi <- solve(t(x) %*% x)
  
  b <- xxi %*% t(x) %*% y
  res <- y - x %*% b
  rss <- sum(res^2)
  ssq <- rss / (n - k)
  s <- sqrt(ssq)
  bse <- sqrt(diag(ssq * xxi))
  tstat <- b / bse
  ym <- y - mean(y)
  r2 <- 1 - (sum(res^2) / sum(ym^2))
  adjr2 <- 1 - ((n - 1) / (n - k)) * (1 - r2)
  fstat <- ((sum(ym^2) - sum(res^2)) / (k - 1)) / (sum(res^2) / (n - k))
  dw <- 2 * (1 - cor(res[-n], res[-1]))
  
  # Calculation of robust standard errors
  
  # White standard errors
  repmat_res <- kronecker(matrix(1, nrow = 1, ncol = ncol(x)), res)
  resx <- repmat_res * x
  wh_vcm <- xxi %*% (t(resx) %*% resx) %*% xxi
  wh_bse <- sqrt(diag(wh_vcm))
  
  # Newey-West standard errors
  if (B == 0) {
    # Recalculate B only if not provided as input
    B <- ceiling(4 * (n / 100)^(2 / 9))
  }
  
  xox <- t(resx) %*% resx
  for (i in 1:(B - 1)) {
    w <- 1 - (i / B)
    za <- t(resx[(i + 1):n, , drop = FALSE]) %*% resx[1:(n - i), , drop = FALSE]
    xox <- xox + w * (za + t(za))
  }
  nw_vcm <- xxi %*% xox %*% xxi
  nw_bse <- sqrt(diag(nw_vcm))
  
  # Save the outputs
  out <- list(
    b = b,
    bse = bse,
    wh_bse = wh_bse,
    nw_bse = nw_bse,
    res = res,
    n = n,
    rss = rss,
    r2 = r2
  )
  
  if (output) {
    # Calculate p-values
    pval <- 2 * (1 - pt(abs(tstat), n - k))
    pvalf <- 1 - pf(fstat, k - 1, n - k)
    
    cat("===========================================================\n")
    cat("===== Regression Output  ==================================\n")
    cat(sprintf("Obs used = %4.0f, missing obs = %4.0f \n", n, ninit - n))
    cat(sprintf("Rsquared = %5.4f \n", r2))
    cat(sprintf("adj_Rsq  = %5.4f \n", adjr2))
    cat("===== Estimated Model Parameters ==========================\n")
    cat("=   Par       se      se(White)    se(NW)  ==================\n")
    
    # Display parameter estimates
    formatted_output <- data.frame(
      Par = sprintf("%9.4f", b),
      se = sprintf("%9.4f", bse),
      se_White = sprintf("%9.4f", wh_bse),
      se_NW = sprintf("%9.4f", nw_bse)
    )
    print(formatted_output, row.names = FALSE)
    
    cat("===== Model Statistics ====================================\n")
    cat(sprintf(" Fstat = %5.4f (%5.4f)\n", fstat, pvalf))
    cat(sprintf(" standard error = %5.4f\n", sqrt(ssq)))
    cat(sprintf(" RSS = %5.4f\n", rss))
    cat(sprintf(" Durbin-Watson  = %5.4f\n", dw))
    cat("===========================================================\n")
  }
  
  return(out)
}
