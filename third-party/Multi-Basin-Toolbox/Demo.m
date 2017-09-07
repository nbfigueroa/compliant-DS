clc;
clear all;

%% Setting Input Data

load 'data/ring.mat';
%load data/toy.mat;  
 
%input=X';
%output=y';

%% My data
input = X_(1:5:end,:);

%%
method = 'T-MSC'; % method = {'CG-SC', 'S-MSC', 'T-MSC', 'F-MSC', 'V-MSC'}
support = 'SVDD'; % support type = {'SVDD', 'GP'}
supportopt = struct('ker','rbf','arg',0.45,'C',0.5,... % SVDD
    'gpparam',[100*ones(size(input,2),1); 1; 10]); %GP

options = struct('hierarchical',false,'K',2,'epsilon',0.05,...
    'R1',0.01,'R2',0.01);
voronoiopt = struct('samplerate', 0.2,'voronoiMethod','T-MSC',...
    'hierarchical',true,'K',4,'epsilon',0.05,... % T-SVC
    'R1',0.02,'R2',0.02,... % F-SVC
    'eta',0.1);

[tinput, clstmodel] = msclustering(input, method, support, supportopt, options, voronoiopt);

% Ploting the results

% if size(tinput,1)==2
        plotmsc(tinput,clstmodel);    
%     title('T-SVC SIGMA 0.2 C 0.5');
% end

 
%% Performance Evaluation 

ARI = calARI(output,clstmodel.cluster_labels+1); % Adjusted Rand Index
