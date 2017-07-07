function [ ] = my_distance_hist( X, dist_type )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

maxSamples = 10000;
if length(X) < maxSamples
    X_train = X;
else
    X_train = X(1:maxSamples, :); 
end

%%%%% Compute Element-wise pairwise distances %%%%%%
%%% Throughout ALL training points %%%
tic;
D = pdist(X_train, dist_type);
toc;

% Visualize pairwise distances as Histogram
figure('Color',[1 1 1])
hist_distances = 10;
histfit(D(1:hist_distances:end,:))
title('Dataset Features Pairwise Distances', 'Interpreter','LaTex')
xlabel('L_2 Norm')
grid on 
axis tight



end

