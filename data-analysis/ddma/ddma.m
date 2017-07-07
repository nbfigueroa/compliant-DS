function [X, centers] = ddma(dat, lab, neigen, gamma, t, neighbor)
% 
% By Yixiang Huang, School of Mechanical Engineering, 
%                   Shanghai Jiao Tong University
% Email: huang.yixiang@sjtu.edu.cn with comments & questions
% Last modified on Feb.28,2015
%
% This program implements the function of discriminant diffusion maps 
% analysis (DDMA)[1], which is developed based on the manifold learning
% method of diffusion maps [2]. 
%
% Function Name: Discriminant Diffusion Maps Analysis (DDMA)
%       dat        --- data set, n-by-p matrix. Rows are observations
%       lab        --- discriminant information gained by
%                      pre-classification step (e.g. KNN)
%       gamma      --- discriminant constant: a number between 1 and 3
%       neigen     --- the target dimensionality, a positive interger,
%                      neigen <= p
%       t          --- optional time parameter in diffusion map, 
%                      default value 1.                           
% Output: 
%       X          --- non-trivial diffusion coordinates.(entered column-wise)  
%       centers    --- centers of each class
%
%
% References: 
% [1] Yixiang Huang, Xuan F. Zha, Jay Lee, Chengliang Liu. Discriminant 
%     Diffusion Maps Analysis: A Robust Manifold Learner For Dimensionality 
%     Reduction And Its Applications in machine condition monitoring and
%     fault diagnosis. Mechanical Systems and Signal Processing, 34(1-2), 
%     2013: 277-297. 
% [2] S. Lafon, Diffusion Maps and Geometric Harmonics. Dissertation Thesis,
%     Mathematics Department, Yale University, USA, 2004. 
% 
% 

[n,p]=size(dat); 
k=max(lab); 
D=squareform(pdist(dat)); 
eps_val=zeros(k,k); 
centers=zeros(k,p);

if neigen> p || isempty(neigen)
    neigen = p;
    disp('Error: Invalide target dimensionality.')
end  

for i=1:k
    centers(i,:)=mean(dat(lab(:)==i,:));
    for j=i:k               
        Dc_sort=sort(D(lab(:)==i,lab(:)==j),2);
        ks=min([neighbor, size(Dc_sort,1)-1, size(Dc_sort,2)-1]);
        dist_knn = Dc_sort(:,1+ks);  
        mean_val = mean(dist_knn);
        eps_val(i,j) = mean_val;   
        eps_val(j,i) = eps_val(i,j);  
    end    
end           
% 
Deps=zeros(n,n);
for i=1:n
    for j=i:n
        if lab(i)==lab(j)
            Deps(i,j)=eps_val(lab(i),lab(i))*gamma;
        else
            Deps(i,j)=min([eps_val(lab(i),lab(i)),eps_val(lab(j),...
                      lab(j)),eps_val(lab(i),lab(j))])/gamma;
        end
        Deps(j,i)=Deps(i,j);
    end
end

K = exp(-D.^2./(Deps));  
v = sqrt(sum(K)); 
v = v(:);
A = K./(v*v');  
M = max(max(A)); 
threshold=1E-8; 
A=sparse(A.*double(A>threshold*M));    
[U,S,V]=svds(A,neigen+1); 
psi=U./(U(:,1)*ones(1,neigen+1)); 
phi=U.*(U(:,1)*ones(1,neigen+1)); 
eigenvals=diag(S);
lambda_t=eigenvals(2:end).^t; 
lambda_t=lambda_t.*double(lambda_t>threshold);      
lambda_t=ones(n,1)*lambda_t';
% Calculate diffusion coordinates
X = psi(:,2:neigen+1).*lambda_t(:,1:neigen);

return
