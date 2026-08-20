%====================================================
% In here we 
% 1) simulate three different processes
%       a) regression model with that meets GM assumptions
%       b) regression model with heteroskedastic errors
%       c) regression model with AC errors
% 2) Perform parameter inference using normal, White and NW se
% 3) Evaluate whether tests have correct size
%
%====================================================

function main
clc     % Clears the command window
randn('state',123467);      % ensures that random number generator starts with same random number

% Parameters for DGP
% y = x*b + u
n       = 200;                     % length of the simulated series
nsim    = 10000;                    % number of simulations
x       = [ones(n,1) randn(n,2)];   % constant and two randomly generated series
b       = [0.5; 1.0; -0.5];         % true parameter vector
sig     = 0.1;                      % standard deviation of error terms

% Parameters for the AR error terms
p = 1;      % AR order
q = 1;      % MA order
% process parameters
alpha = 0.0;
phi   = [0.9];
theta = [0.7];
sigar = 0.1;    % standard error of innovation term


% save t-stats for DGP with GM errors here, col1: OLS se, Col2: White,
% Col3: NW; only safe results for b(2)
tsave = zeros(nsim,3);

% simulate model with GM (gmerr), heteroskedatic (hserr) or
% autocorrelated (arerr) errors
for i = 1 : nsim
%     gmerr = randn(n,1)*sig;                             % GM errors
%     hserr = [randn(n/2,1)*sig;randn(n/2,1)*(sig/5)];    % heterosk errors
    arerr = armasim(n,p,q,alpha,phi,theta,sigar);         % AR errors
    y = x*b + arerr;                                      % DGP with selected errors
    results = OLShac(y,x,0);        % estimate and save results in "results"
    bmb0 = results.b(2) - b(2);     % difference of estimated value from true value
    tsave(i,:) = [bmb0/results.bse(2) bmb0/results.wh_bse(2) bmb0/results.nw_bse(2)];
end

cv5  = norminv(0.975);   % 2 tailed 5% cv, Normal
cv1  = norminv(0.995);   % 2 tailed 1% cv, Normal
cv5t = tinv(0.975,n-length(b));   % 2 tailed 5% cv, t-Distr
cv1t = tinv(0.995,n-length(b));   % 2 tailed 1% cv, t-Distr

count5 = (abs(tsave(:,2:3))>cv5);    % 1 if test stat exceed cv, 0 otherwise
count1 = (abs(tsave(:,2:3))>cv1);    % 1 if test stat exceed cv, 0 otherwise
count5 = [(abs(tsave(:,1))>cv5t) count5];
count1 = [(abs(tsave(:,1))>cv1t) count1];

prop5 = sum(count5)./nsim; % proportion of rejections of true H0 at 5%
prop1 = sum(count1)./nsim; % proportion of rejections of true H0 at 1%

disp('Rejections for standard OLS, White and NW based t-tests');
disp('   OLS       White       NW');
disp('at 5%');
disp(prop5);
disp('at 1%');
disp(prop1);

end