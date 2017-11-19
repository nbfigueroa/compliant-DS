function [lp, flag] = sample_hyper(ztau, sigma2prop, x, f, kern, muprior, sigma2prior)

zast = normrnd(ztau, sqrt(sigma2prop));
logpztau = logpunorm(ztau, x, f, kern, muprior, sigma2prior);
logpzast = logpunorm(zast, x, f, kern, muprior, sigma2prior);
A = min(1, exp(logpzast - logpztau));
if rand < A
    lp = zast;
    flag = 1;
else
    lp = ztau;
    flag = 0;
end
end

function logprob = logpunorm(l, x, f, kern, muprior, sigma2prior)

logpl = log(lognpdf(l, muprior, sqrt(sigma2prior)));
kern.inverseWidth = l;
K = kernCompute(kern, x);

% K_prior=K;
% for i=1:Ngps-1
%     K_prior=blkdiag(K_prior,K);
% end

[invK, U] = pdinv(K);
logDetK = logdet(K, U);
logpugl = -0.5*logDetK - 0.5*f'*invK*f - 0.5*length(f)*log(2*pi);
logprob = logpugl + logpl;
end



