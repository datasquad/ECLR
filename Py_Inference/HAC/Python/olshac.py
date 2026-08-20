"""
OLS Regression with HAC (Heteroskedasticity and Autocorrelation Consistent) Standard Errors

This module implements OLS estimation with White and Newey-West standard errors.
Converted from MATLAB/R implementation.
"""

import numpy as np
import pandas as pd
from scipy import stats


def olshac(y, x, output=1, B=0):
    """
    Perform OLS estimation with White and Newey-West standard errors.
    
    Parameters
    ----------
    y : array_like
        Vector with dependent variable
    x : array_like
        Matrix with explanatory variables
        Function will automatically add a constant if the first col
        is not a vector of ones
    output : int, optional
        1 = printed output (default: 1)
    B : int, optional
        Lag lengths for Newey-West standard errors
        If 0, automatically calculated as ceil(4*(n/100)^(2/9))
    
    Returns
    -------
    dict
        Dictionary with the following elements:
        - b : Estimated parameters
        - bse : Standard errors for bhat
        - wh_bse : White standard errors for bhat
        - nw_bse : Newey-West standard errors for bhat
        - res : Estimated residuals
        - n : Number of observations used
        - rss : Residual sum of squares
        - r2 : R-squared
    """
    
    # Convert inputs to numpy arrays
    y = np.asarray(y).flatten()
    x = np.asarray(x)
    
    # Ensure x is 2D
    if x.ndim == 1:
        x = x.reshape(-1, 1)
    
    # Store initial length for reporting missing observations
    ninit = len(y)
    
    # Select those rows that have observations for all variables
    valid_mask = ~(np.isnan(y) | np.any(np.isnan(x), axis=1))
    y = y[valid_mask]
    x = x[valid_mask, :]
    
    # Test whether first column is vector of ones
    temp = x[x[:, 0] == 1, 0]
    if len(temp) != len(x):
        x = np.column_stack([np.ones(len(x)), x])  # add constant if not included in x
    
    n = x.shape[0]  # sample size
    k = x.shape[1]  # number of explanatory vars (incl constant)
    
    xxi = np.linalg.inv(x.T @ x)
    
    b = xxi @ x.T @ y
    res = y - x @ b
    rss = np.sum(res**2)
    ssq = rss / (n - k)
    s = np.sqrt(ssq)
    bse = np.sqrt(np.diag(ssq * xxi))
    tstat = b / bse
    ym = y - np.mean(y)
    r2 = 1 - (np.sum(res**2) / np.sum(ym**2))
    adjr2 = 1 - ((n - 1) / (n - k)) * (1 - r2)
    fstat = ((np.sum(ym**2) - np.sum(res**2)) / (k - 1)) / (np.sum(res**2) / (n - k))
    dw = 2 * (1 - np.corrcoef(res[:-1], res[1:])[0, 1])
    
    # Calculation of robust standard errors
    
    # White standard errors
    repmat_res = np.kron(np.ones((1, x.shape[1])), res.reshape(-1, 1)).T
    resx = repmat_res * x.T
    resx = resx.T  # Shape: (n, k)
    wh_vcm = xxi @ (resx.T @ resx) @ xxi
    wh_bse = np.sqrt(np.diag(wh_vcm))
    
    # Newey-West standard errors
    if B == 0:
        # Recalculate B only if not provided as input
        B = int(np.ceil(4 * (n / 100)**(2 / 9)))
    
    xox = resx.T @ resx
    for i in range(1, B):
        w = 1 - (i / B)
        za = resx[i:, :].T @ resx[:n-i, :]
        xox = xox + w * (za + za.T)
    
    nw_vcm = xxi @ xox @ xxi
    nw_bse = np.sqrt(np.diag(nw_vcm))
    
    # Save the outputs
    out = {
        'b': b,
        'bse': bse,
        'wh_bse': wh_bse,
        'nw_bse': nw_bse,
        'res': res,
        'n': n,
        'rss': rss,
        'r2': r2
    }
    
    if output:
        # Calculate p-values
        pval = 2 * (1 - stats.t.cdf(np.abs(tstat), n - k))
        pvalf = 1 - stats.f.cdf(fstat, k - 1, n - k)
        
        print("=" * 59)
        print("=" * 5 + " Regression Output " + "=" * 35)
        print(f"Obs used = {n:4.0f}, missing obs = {ninit - n:4.0f}")
        print(f"Rsquared = {r2:5.4f}")
        print(f"adj_Rsq  = {adjr2:5.4f}")
        print("=" * 5 + " Estimated Model Parameters " + "=" * 27)
        print("=   Par       se      se(White)    se(NW)  " + "=" * 11)
        
        # Display parameter estimates
        output_df = pd.DataFrame({
            'Par': [f"{val:9.4f}" for val in b],
            'se': [f"{val:9.4f}" for val in bse],
            'se_White': [f"{val:9.4f}" for val in wh_bse],
            'se_NW': [f"{val:9.4f}" for val in nw_bse]
        })
        print(output_df.to_string(index=False))
        
        print("=" * 5 + " Model Statistics " + "=" * 35)
        print(f" Fstat = {fstat:5.4f} ({pvalf:5.4f})")
        print(f" standard error = {np.sqrt(ssq):5.4f}")
        print(f" RSS = {rss:5.4f}")
        print(f" Durbin-Watson  = {dw:5.4f}")
        print("=" * 59)
    
    return out


if __name__ == "__main__":
    # Simple test
    np.random.seed(123)
    n = 50
    X = np.column_stack([np.ones(n), np.random.randn(n), np.random.randn(n)])
    y = X @ np.array([1, 2, -1]) + np.random.randn(n)
    
    print("Testing olshac with simple data...")
    results = olshac(y, X, output=1)
