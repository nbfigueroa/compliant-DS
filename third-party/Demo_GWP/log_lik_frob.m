function loglik=log_lik_frob(matrices,M)

[D,D,F,C]=size(matrices);
N=F*C;

V=reshape(M,D,D,N);
S=reshape(matrices,D,D,N);
log_p=zeros(N,1);
for n=1:N
    %dif=logm(V(:,:,n))-logm(S(:,:,n));
    %dist=-1000*sqrt(trace(dif'*dif)); 
    dist=-10000*sqrt(trace((V(:,:,n)-S(:,:,n))'*(V(:,:,n)-S(:,:,n))));    
    log_p(n)=dist;
end

loglik=sum(log_p,1);

end


