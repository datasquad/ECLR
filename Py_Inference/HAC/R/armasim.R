armasim <- function(t, p, q, al, ph, th, si) {
  # Function that simulates ARMA(p,q) process
  # input:    t length series to be simulated
  #           p, AR order
  #           q, MA order
  #           al, constant
  #           ph, AR parameters [ph[1], ph[2], ..., ph[p]]
  #           th, MA parameters [th[1], th[2], ..., th[q]]
  #
  # y(t) = al + ph(1)*y(t-1) + ... + ph(p)*y(t-p)
  #           + th(1)*eps(t-1) + ... + th(q)*eps(t-q) + eps(t)
  # where eps(t) comes from ~N(0,si^2)
  
  eps <- rnorm(t + 100, mean = 0, sd = si)  # error terms, 100 extra for startup
  maxlag <- max(p, q)  # find max lag
  
  if (sum(ph) == 1) {
    um <- 1
  } else {
    um <- al / (1 - sum(ph))  # unconditional mean
  }
  
  fph <- rev(ph)  # reversed AR parameter vector
  fth <- rev(th)  # reversed MA parameter vector
  y <- rep(um, t + 100)  # initialize the series with unconditional mean
  
  if (p > 0 & q > 0) {
    # ARMA model
    for (i in (maxlag + 1):(t + 100)) {
      y[i] <- al + sum(y[(i - p):(i - 1)] * fph) + sum(eps[(i - q):(i - 1)] * fth) + eps[i]
    }
  } else if (p > 0 & q == 0) {
    # AR Model
    for (i in (maxlag + 1):(t + 100)) {
      y[i] <- al + sum(y[(i - p):(i - 1)] * fph) + eps[i]
    }
  } else if (p == 0 & q > 0) {
    # MA model
    for (i in (maxlag + 1):(t + 100)) {
      y[i] <- al + sum(eps[(i - q):(i - 1)] * fth) + eps[i]
    }
  } else {
    # White noise process
    for (i in (maxlag + 1):(t + 100)) {
      y[i] <- al + eps[i]
    }
  }
  
  y <- y[101:(t + 100)]
  return(y)
}
