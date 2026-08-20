function out = OLShac(y,x,output,B);
% This function performs an OLS estimation
% input:    y, vector with dependent variable
%           x, matrix with explanatory variable 
%               function will automatically add a constant if the first col
%               is not a vector  of ones
%           output, 1 = printed output
%           B, lag lengths for Newey-West standard errors
% output:   Structure called OLS with the following elements:
%           .b, estimated parameters
%           .bse, standard errors for bhat
%           .wh_bse, White standard errors for bhat
%           .nw_bse, Newey-West standard errors for bhat
%           .res, estimated residuals
%           .n, number of observations used
%           .rss, residual sum of squares
%           .r2, Rsquared

% This checks how many inputs have been provided and chooses defaults for
% missing inputs
switch nargin
    case 2
        output = 1;
        B = 0;  % will later be replaced by default value
    case 3
        B = 0;  % will later be replaced by default value
    case 4
        % nothing
    otherwise
        error('2 to 4 inputs are required!')
end


% select those rows that have observations for all variables
ninit = length(y);
testnan = [isnan(y) isnan(x)];
testnan = (sum(testnan,2)==0);
y = y(testnan);
x = x(testnan,:);
% test whether first column is vector of ones
temp = (x(x(:,1)==1));
if length(temp) ~= length(x)
  x = [ones(length(x),1) x];  % add constant of not included in x
end

[n,k] = size(x);        % sample size - n, number of explan vars (incl constant) - k   
xxi   = inv(x'*x);      

n     = n;
b     = xxi*x'*y;
res   = y - x*b;
rss   = res'*res;
ssq   = rss/(n-k);
s     = sqrt(ssq);
bse   = ssq*xxi;
bse   = sqrt(diag(bse));
tstat = b./bse;
ym    = y - mean(y);
r2    = 1 - (res'*res)/(ym'*ym);
adjr2 = 1 - (n-1)*(1-r2)/(n-k);
fstat = ((((ym'*ym))-(res'*res))/(k-1))/((res'*res)/(n-k));
dw    = corrcoef([res(1:end-1) res(2:end)]);
dw    = 2*(1-dw(2,1)); 


% calculation of robust standard errors

% White standard errors
resx  = repmat(res,1,size(x,2)).*x;
wh_vcm = xxi*(resx'*resx)*xxi;
wh_bse = sqrt(diag(wh_vcm));

% Newey-West standard errors
if B==0 % recalculate B only if not provided as input
    B = ceil(4*(n/100)^(2/9)); % This is the lag length in the Newey West calculation
end
xox = resx(1:end,:)'*resx(1:end,:);
for i = 1:B-1;
  w = 1-(i/B);
  za = resx(1+i:end,:)'*resx(1:end-i,:);
  xox = xox+w*(za+za');
end;
nw_vcm = xxi*xox*xxi;
nw_bse = sqrt(diag(nw_vcm));

% Save the outputs
out.b      = b;
out.bse    = bse;
out.wh_bse = wh_bse;
out.nw_bse = nw_bse;
out.res    = res;
out.n      = n;
out.rss    = rss;
out.r2     = r2;

if output
pval  = 2*(1-tcdf(abs(tstat),n-k));    
pvalf = 1- fcdf(fstat,k-1,n-k);    
try      % if stats toolbox is available
    pval  = 2*(1-tcdf(abs(tstat),n-k));
    pvalf = 1- fcdf(fstat,k-1,n-k);
catch
    try     % if NAG toolbox is available
        pval  = 2*(1-g01eb(abs(tstat),n-k));
        pvalf = g01ed(fstat,k-1,n-k,'tail','U');
    catch
        pval = -999*ones(size(tstat));
        pvalf = -999;
    end
end    
    
fprintf('===========================================================\n');
fprintf('===== Regression Output  ==================================\n');
fprintf('Obs used = %4.0f, missing obs = %4.0f \n',n,(ninit-n));
fprintf('Rsquared = %5.4f \n',r2);
fprintf('adj_Rsq  = %5.4f \n',adjr2);
fprintf('===== Estimated Model Parameters ==========================\n');
fprintf('=   Par       se      se(White)    se(NW)  ==================\n');
format short;
disp([b bse wh_bse nw_bse]);
fprintf('===== Model Statistics ====================================\n');
fprintf(' Fstat = %5.4f (%5.4f)\n',[fstat;pvalf]);
fprintf(' standard error = %5.4f\n',sqrt(ssq));
fprintf(' RSS = %5.4f\n',rss);
fprintf(' Durbin-Watson  = %5.4f\n',dw);
fprintf('===========================================================\n');
end