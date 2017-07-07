%% %% Try Power Analysis
load('./mat/peeling_data_labels.mat')
pos_act   = data_act(1:3,:);
vel_act   = [diff(pos_act(1,:));diff(pos_act(2,:));diff(pos_act(3,:))];
vel_act   = sgolayfilt(vel_act', 3, 151)';
force_act = data_act(8:10,2:end);
pow_act   = vel_act.*force_act;


labels_new = labels;
labels_new(labels==11) = 9;
labels_new(labels==13) = 9;

%% Plot 3d Power Domain
figure('Color',[1 1 1])
labels_ids = unique(labels_new);
colors = hsv(length(labels_ids)+2);

data = pow_act;

for i=1:2:length(pow_act)
plot3(data(1,i),data(2,i),data(3,i),'.--','Color',colors(labels_new(1,i) == labels_ids,:)); hold on;
end
xlabel('\Omega_x');ylabel('\Omega_y');zlabel('\Omega_z');
title('$\Omega= \dot{x}\cdot\mathbf{f}_{ext}$ Power Domain of Peeling Demonstrations', 'Interpreter','LaTex')
grid on;
axis tight;

%% Plot 3d positions

figure('Color',[1 1 1])
labels_ids = unique(labels_new);
colors = hsv(length(labels_ids)+2);

subplot(2,1,1)
data = vel_act;
for i=1:2:length(data)
plot3(data(1,i),data(2,i),data(3,i),'.--','Color',colors(labels_new(1,i) == labels_ids,:)); hold on;
end
hold on;

plot3(0,0,0,'*','Color',[0 0 0],'MarkerSize',50); hold on;

xlabel('$\dot{x}_1$','Interpreter','LaTex');ylabel('$\dot{x}_2$','Interpreter','LaTex');zlabel('$\dot{x}_3$','Interpreter','LaTex');
title('Velocity Domain of Peeling Demonstrations', 'Interpreter','LaTex')
grid on;
axis tight;

subplot(2,1,2)
data = pos_act;
for i=1:2:length(data)
plot3(data(1,i),data(2,i),data(3,i),'.--','Color',colors(labels_new(1,i) == labels_ids,:)); hold on;
end
hold on;

xlabel('$x_1$','Interpreter','LaTex');ylabel('$x_2$','Interpreter','LaTex');zlabel('$x_3$','Interpreter','LaTex');
title('Position Domain of Peeling Demonstrations', 'Interpreter','LaTex')
grid on;
axis tight;


%% Non-linear Embedding Analysis
clc;

% X = [vel_act;force_act]; 
X = pow_act; 
samples = 2;
X = X(:,1:samples:end); 
labels_ = labels_new(1:samples:end);

% Prepare labels for Manifold Embedding
prelab = labels_;
prelab(labels_ == 8) = 1;
prelab(labels_ == 9) = 2;

% Adjust data to N x M (dimension x samples)
[N,M] = size(X);

% Plot original data
plot_options            = [];
plot_options.is_eig     = false;
plot_options.labels     = prelab;
plot_options.class_names = {'Peel', 'Reach-to-Peel'};
plot_options.title      = '$\Omega= \dot{x}\cdot\mathbf{f}_{ext}$ Power Domain of Peeling Demonstrations';

if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = ml_plot_data(X',plot_options);


%% Apply Discriminant Diffusion Maps
d  = 3;  % Reduced dimensionality
r  = 1;  % Discriminant constant
t  = 3;  % Scale factor, a positive interger 
nb = 5;  % The number of neighbour


% Prepare labels for DDMA
prelab = labels_;
prelab(labels_ == 8) = 1;
prelab(labels_ == 9) = 2;

% Discriminant Diffusion Map estimation
[X_r, ctrs] = ddma(X', prelab', d, r, t, nb);

%% Plot transformed data
plot_options            = [];
plot_options.is_eig     = false;
plot_options.labels     = prelab(1,:);
plot_options.class_names = {'Peel', 'Reach-to-Peel'};
plot_options.title      = 'Discriminant Diffusion Map Embedding $\phi(\Omega)$ of Peeling Dataset';

if exist('h2','var') && isvalid(h2), delete(h1);end
h2 = ml_plot_data(X_r(:,:),plot_options);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find suitable range for rbf kernel %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
my_distance_hist( X', 'euclidean' )

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     Learn Optimal C - SUPPORT VECTOR MACHINE  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare labels for Classification
y = labels_;
y(labels_ == 8) = -1;
y(labels_ == 9) = 1;

%% Test C-SVM on Data (Assuming you ran CV first)
clear options
% Optimal Values from CV on Xk dataset
options.svm_type    = 0;    % 0: C-SVM, 1: nu-SVM
options.C           = C_opt; % Misclassification Penalty
options.sigma       = w_opt;  % radial basis function: exp(-gamma*|u-v|^2), gamma = 1/(2*sigma^2)

% Train SVM Classifier (12k+3D pts = 8s,....)
tic;
[y_est, model] = svm_classifier(X', y', options, []);
toc;

% Model Stats
clc
totSV = model.totalSV;
ratioSV = totSV/length(y);
posSV = model.nSV(1)/totSV;
negSV = model.nSV(2)/totSV;
boundSV = sum(abs(model.sv_coef) == options.C)/totSV;

fprintf('*SVM Model Statistic*\n Total SVs: %d, SV/M: %1.4f \n +1 SV : %1.4f, -1 SVs: %1.4f, Bounded SVs: %1.4f \n', ...
    totSV, ratioSV, posSV, negSV,  boundSV);

[test_stats] = class_performance(y,y_est);
fprintf('*Classifier Performance on Train set (%d points)* \n Acc: %1.5f, F-1: %1.5f, FPR: %1.5f, TPR: %1.5f \n', ...
    length(y), test_stats.ACC, test_stats.F1, test_stats.FPR, test_stats.TPR)


%% Plot SVM decision boundary (3D)
svm_3d_matlab_vis(model,X',y, {'Peel', 'Reach-to-Peel'})

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Grid-search on CV to find 'optimal' hyper-parameters for C-SVM with RBF %
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Set options for SVM Grid Search and Execute
clear options
options.svm_type   = 0;             % SVM Type (0:C-SVM, 1:nu-SVM)
options.limits_C   = [10^0, 10^5]; % Limits of penalty C
options.limits_w   = [0.0001, 0.01]; % Limits of kernel width \sigma
options.steps      = 10;            % Step of parameter grid 
options.K          = 5;             % K-fold CV parameter
options.log_grid   = 1;             % Log-Spaced grid of Parameter Ranges

%% Do Cross-Validarion (K = 1 is pure grid search, K = N is N-CV)
tic;
[ ctest , ctrain , cranges ] = ml_grid_search_class( X', y', options );
toc;

%% Get CV statistics

% Extract parameter ranges
range_C  = cranges(1,:);
range_w  = cranges(2,:);

% Extract parameter ranges
stats = ml_get_cv_grid_states(ctest,ctrain);

% Visualize Grid-Search Heatmap
cv_plot_options              = [];
cv_plot_options.title        = strcat('3-D, Power Features v*f -- C-SVM :: Grid Search with RBF');
cv_plot_options.param_names  = {'C', '\sigma'};
cv_plot_options.param_ranges = [range_C ; range_w];
cv_plot_options.log_grid     = 1; 
cv_plot_options.svm_metrics  = 1;

if exist('hcv','var') && isvalid(hcv), delete(hcv);end
hcv = ml_plot_cv_grid_states(stats,cv_plot_options);

% Find 'optimal hyper-parameters'
[max_acc,ind] = max(stats.test.acc.mean(:));
[C_max, w_max] = ind2sub(size(stats.train.acc.mean),ind);
C_opt = range_C(C_max)
w_opt = range_w(w_max)
