"""
ARMA Simulation Module

This module implements ARMA(p,q) process simulation.
Converted from MATLAB/R implementation.
"""

import numpy as np


def armasim(t, p, q, al, ph, th, si):
    """
    Simulate an ARMA(p,q) process.
    
    Parameters
    ----------
    t : int
        Length of the series to be simulated
    p : int
        AR order
    q : int
        MA order
    al : float
        Constant term
    ph : array_like
        AR parameters [ph[0], ph[1], ..., ph[p-1]]
    th : array_like
        MA parameters [th[0], th[1], ..., th[q-1]]
    si : float
        Standard deviation of error terms
    
    Returns
    -------
    numpy.ndarray
        Simulated ARMA series of length t
    
    Notes
    -----
    y(t) = al + ph(1)*y(t-1) + ... + ph(p)*y(t-p)
              + th(1)*eps(t-1) + ... + th(q)*eps(t-q) + eps(t)
    where eps(t) comes from ~N(0,si^2)
    
    The function generates 100 extra observations for startup which are discarded.
    """
    
    # Convert parameters to numpy arrays
    ph = np.asarray(ph)
    th = np.asarray(th)
    
    # Generate error terms (100 extra for startup)
    eps = np.random.normal(0, si, t + 100)
    
    # Find maximum lag
    maxlag = max(p, q)
    
    # Calculate unconditional mean
    if np.sum(ph) == 1:
        um = 1
    else:
        um = al / (1 - np.sum(ph))
    
    # Reversed parameter vectors
    fph = ph[::-1]  # reversed AR parameter vector
    fth = th[::-1]  # reversed MA parameter vector
    
    # Initialize the series with unconditional mean
    y = np.full(t + 100, um)
    
    # Generate ARMA process
    if p > 0 and q > 0:
        # ARMA model
        for i in range(maxlag, t + 100):
            y[i] = al + np.sum(y[i-p:i] * fph) + np.sum(eps[i-q:i] * fth) + eps[i]
    elif p > 0 and q == 0:
        # AR Model
        for i in range(maxlag, t + 100):
            y[i] = al + np.sum(y[i-p:i] * fph) + eps[i]
    elif p == 0 and q > 0:
        # MA model
        for i in range(maxlag, t + 100):
            y[i] = al + np.sum(eps[i-q:i] * fth) + eps[i]
    else:
        # White noise process
        for i in range(maxlag, t + 100):
            y[i] = al + eps[i]
    
    # Return series after discarding first 100 observations
    y = y[100:]
    return y


if __name__ == "__main__":
    # Test the function
    np.random.seed(123)
    
    # Test AR(1) process
    print("Testing AR(1) process:")
    y_ar = armasim(t=100, p=1, q=0, al=0, ph=[0.8], th=[], si=1.0)
    print(f"Mean: {np.mean(y_ar):.4f}, Std: {np.std(y_ar):.4f}")
    print(f"First 10 values: {y_ar[:10]}")
    
    # Test MA(1) process
    print("\nTesting MA(1) process:")
    y_ma = armasim(t=100, p=0, q=1, al=0, ph=[], th=[0.6], si=1.0)
    print(f"Mean: {np.mean(y_ma):.4f}, Std: {np.std(y_ma):.4f}")
    print(f"First 10 values: {y_ma[:10]}")
    
    # Test ARMA(1,1) process
    print("\nTesting ARMA(1,1) process:")
    y_arma = armasim(t=100, p=1, q=1, al=0, ph=[0.9], th=[0.7], si=0.1)
    print(f"Mean: {np.mean(y_arma):.4f}, Std: {np.std(y_arma):.4f}")
    print(f"First 10 values: {y_arma[:10]}")
