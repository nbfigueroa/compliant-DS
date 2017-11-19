clear all
close all
clc
warning off
%%
% We load original tensor field:
load T.mat

%Subsampling factor:
inc=2;
[I,J,F,C]=size(T);
train_dat=zeros(I,J,F,C);
%Grid size or patch size, max_grid must be an even number:
max_grid=10;tam_grid=max_grid/inc;Ndatos=tam_grid^2;
desp=0;desp2=0;

%Training field:
train_dat(:,:,1:inc:F,1:inc:C)=T(:,:,1:inc:F,1:inc:C);

%%
%GWP parameters:
D=3;v=4;Ngps=D*v;
V=zeros(D,D);
V=[0.0003 0 0;0 0.0002 0;0 0 0.0001];
L=chol(V,'lower');

%2D spatial coordinates:
x=1:inc:max_grid;
x2=repmat(x',tam_grid,1);
x1=ones(tam_grid,1);
for i=1+inc:inc:max_grid
x1=[x1;i*ones(tam_grid,1)];    
end
X=[x1 x2];

cn=1;
lim=max_grid-1;
super_D=zeros(3,3,F,C);
despx=0;
%We move the patch accross the whole field:
for n=1:(F/lim)+1 
        desp2=0;
        despy=0;
    for m=1:(C/lim)+1
    %% Training: 
        Dat=T(:,:,1+desp:inc:max_grid+desp,1+desp2:inc:desp2+max_grid);
        theta=[0.01  1];
        lp=theta(1);
        lp2=theta(2);
        kernel=kernCreate(X,'rbf');
        kernel=kernExpandParam(kernel,[log(theta(1)) log(theta(2))]);
        KxxN=kernCompute(kernel,X);
        Ktemp=jitChol(KxxN);
        Kxx=Ktemp'*Ktemp;
        
        %initial u values from the GP's:
        for i=1:v
            for j=1:D 
            u{i,j}=real(gsamp(zeros(length(Kxx),1),Kxx,1));
                if i==1 && j==1
                    u_vector=u{i,j};
                else
                    u_vector=[u_vector u{i,j}];
                end
            end
        end
        % GWP construction:
        [M]=GWP_construct(u,L,v);
        fn=str2func('log_lik_frob');
        cur_log_like=fn(Dat,M);
        
        %elliptical slice sampling and MCMC parameters:
        burn=500;%Burn-in samples
        iterations=6000; %Number of iterations
        lr=0.5;%Learning step for elliptical slice sampling
        run=1;
        runs=10;
        ff.xx=u_vector;
        ff.S=Dat;
        ff.v=v;
        ff.V=M;
        ff.u=u;
        ff.L=L;
        cont=1;
        %Proposal distribution for Metropolis-Hastings:
        sigma2prop = 0.00001;
        muprior = 1;
        sigma2prior = 1;
        mediaL=[L(1,1);L(2,1);L(2,2);L(3,1);L(3,2);L(3,3)];
        sigmaLprop=0.000001*ones(6,1);
        muLprior = ones(6,1);
        sigmaLprior=ones(6,1);
        for ii = (1-burn):iterations

           if mod(ii,100) == 0
             fprintf('Run %03d/%3d Iter %05d / %05d\r', run, runs, ii, iterations);
           end
           [ff, cur_log_like] =elliptical_slice(ff,u_vector,lr,fn,cur_log_like);
           fp=ff.u{1,1}';
           [lp, flag] = sample_hyper(lp, sigma2prop, X, fp, kernel, muprior, sigma2prior);
           ff.S=Dat;
           ff.v=v;
           ff.L=L;

                if(flag==1)
                kernel=kernExpandParam(kernel,[log(lp) log(lp2)]);
                KxxN=kernCompute(kernel,X);
                Ktemp=jitChol(KxxN);
                Kxx=Ktemp'*Ktemp;

                    for i=1:v
                        for j=1:D
                        u{i,j}=real(gsamp(zeros(length(Kxx),1),Kxx,1));
                            if i==1 && j==1
                            u_vector=u{i,j};
                            else
                            u_vector=[u_vector u{i,j}];
                            end
                        end
                    end
                end
             
              sam(:, cont) = ff.xx;
              loglikes(cont) = cur_log_like;
              lps(cont)=lp;
              cont=cont+1;
        end
        [maxi, pos]=max(loglikes);
        u_post=sam(:,pos);
        lp=lps(pos);
        kernel=kernExpandParam(kernel,[log(lp) log(lp2)]);
        KxxN=kernCompute(kernel,X);
        Ktemp=jitChol(KxxN);
        Kxx=Ktemp'*Ktemp;

        inicio=1;
        fin=Ndatos;
        for i=1:v
            for j=1:D
                    uP{i,j}=u_post(inicio:fin);
                    inicio=inicio+Ndatos;
                    fin=Ndatos+fin;            
            end
        end
        ff.u=uP;
        [M]=GWP_construct(ff.u,L,v);
        err_frob=frob_error(M,Dat);
        frob_err(cn)=mean(err_frob);    
        %% Validation:
        incre=1;
        x=1:incre:max_grid-1;
        x2=repmat(x',max_grid-1,1);
        x1=1*ones(max_grid-1,1);
        for i=1+incre:incre:max_grid-1
        x1=[x1;i*ones(max_grid-1,1)];    
        end
        Xtest=[x1 x2];
        p=(max_grid-1)^2;
        T_val=T(:,:,1+desp:incre:desp+max_grid-1,1+desp2:incre:desp2+max_grid-1);

        Ktx=kernCompute(kernel,Xtest,X);
        A=Ktx;
        inv_Kxx=pdinv(Kxx);
        produc1=A*inv_Kxx;
        produc2=A*inv_Kxx*A';
        producto1=produc1;
        producto2=produc2;
        for i=1:Ngps-1
             producto1=blkdiag(producto1,produc1);
             producto2=blkdiag(producto2,produc2);
        end

        med=producto1*u_post;
            if p==1
            covar=eye(p*v*D)-(producto2);
            else
            Ktest=kernCompute(kernel,Xtest);
            temp=Ktest;
                for i=1:Ngps-1
                temp=blkdiag(temp,Ktest);
                end
            covar=temp-(producto2);
            end
        u_pred=real(gsamp(med,covar,1));
        inicio=1;
        fin=p;
        for i=1:v
            for j=1:D
                    uPr{i,j}=u_pred(inicio:fin);
                    inicio=inicio+p;
                    fin=p+fin;            
            end
        end
        
        tensor=GWP_construct(uPr,L,v);
        tensor(:,:,1:2:max_grid-1,1:2:max_grid-1)=T_val(:,:,1:2:max_grid-1,1:2:max_grid-1);
        super_D(:,:,1+despx:max_grid+despx-1,1+despy:max_grid+despy-1)=tensor;
        [F_error]=frob_error(tensor,T_val);
        frob_err_v(cn)=mean(F_error);     
        cn=cn+1;
        desp2=desp2+lim-1; 
        despy=despy+max_grid-2;
    end
    desp=desp+lim-1;
    despx=despx+max_grid-2;
end

