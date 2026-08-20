function y = armasim(t,p,q,al,ph,th,si);
% Function that simulates ARMA(p,q) process of
% input:    t length series to be simulated
%           p, AR order
%           q, MA order
%           al, constant
%           ph, AR parameters [ph(1); ph(2); ...; ph(p)]
%           th, MA parameters [th(1); th(2); ...; th(q)]
%
% y(t) = al + ph(1)*y(t-1) + ... + ph(p)*y(t-p)
%           + th(1)*eps(t-1) + ... + th(q)*eps(t-q) + eps(t)
% where eps(t) comes from ~N(0,si^2)

eps     = randn(t+100,1)*si;% error terms, 100 extra for startup
maxlag  = max([p;q]);        % find max lag
if sum(ph)==1
    um = 1;
else
    um = al/(1-sum(ph));   % unconditional mean
end


fph     = flipud(ph);       % reversed AR parameter vector
fth     = flipud(th);       % reversed MA parameter vector
y = ones(t+100,1)*um;         % in here we safe the series, start with unconditional mean

if p>0 & q>0    % ARMA model

    for i = maxlag+1:t+100
        y(i) = al + y(i-p:i-1)'*fph + eps(i-q:i-1)'*fth + eps(i);
    end

elseif p>0 & q==0   % AR Model
    
    for i = maxlag+1:t+100
        y(i) = al + y(i-p:i-1)'*fph + eps(i);
    end

elseif p==0 & q>0   % MA model 

    for i = maxlag+1:t+100
        y(i) = al + eps(i-q:i-1)'*fth + eps(i);
    end

else    % White noise process

    for i = maxlag+1:t+100
        y(i) = al + eps(i);
    end
end
    
y = y(101:end);
end