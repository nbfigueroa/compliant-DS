%% Testing DS modeling approaches

% Prepare Data for DS Learning
subs = 5;
data =   [X_demos(1:subs:end), Z_demos(1:subs:end), U_demos(1:subs:end), W_demos(1:subs:end)]';
data_0 = [X_demos_0(1:subs:end), Z_demos_0(1:subs:end), U_demos_0(1:subs:end), W_demos_0(1:subs:end)]';
target = data(1:2,end);

%% 1) Fixed Original Linear Dynamics
figure('Color',[1 1 1]);
fig1 = subplot(1,3,1);
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
A = -[10 0;0 10]; b = [0 0]';
ds_lin = @(x) lin_ds(A,b,x);
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
plot_ds_model(fig1, ds_lin, target); hold on;
axis tight
title('Original Linear Dynamics', 'Interpreter','LaTex')

xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of the y axis
limits = [xLimits yLimits];

% 2) Mix Stable Linear Dynamics approx from Demonstrations
n_comp = 4;
em_iterations = 1;
clear options;
options.n_iter = em_iterations;        % Max number of EM iterations
options.solver = 'sedumi';             % Solver
options.criterion = 'mse';             % Solver
options.c_reg = 1e-6;                  % Pos def eps margin
options.c_reg_inv = 5e-1;
options.verbose = 1;                   % Verbose (0-5)
options.warning = true;                % Display warning information

% Prior for the attractor
options.prior.mu = target;
options.prior.sigma_inv = [1 0; 0 1];
lambda = em_mix_lds_inv_max(data, n_comp, options);

% Plot result
fig2 = subplot(1,3,2);
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
plot_streamlines_mix_lds(lambda, limits);
axis tight
title('Stable Mix LPV Systems from Demo', 'Interpreter','LaTex')

% 3) Stable Non-Linear Dynamics approx from Demonstrations
% learn SEDS model
clear options;
nb_gaussians = 4;
options.objective = 'mse';    % 'likelihood'
options.tol_mat_bias = 10^-6; % A very small positive scalar to avoid
                              % instabilities in Gaussian kernel [default: 10^-1                             
options.display = 1;          % An option to control whether the algorithm
                              % displays the output of each iterations [default: true]                            
options.tol_stopping=10^-6;   % A small positive scalar defining the stoppping
                              % tolerance for the optimization solver [default: 10^-10]
options.max_iter = 1000;      % Maximum number of iteration for the solver [default: i_max=1000]
                        
[Priors_0, Mu_0, Sigma_0] = initialize_SEDS(data_0,nb_gaussians); %finding an initial guess for GMM's parameter
[Priors Mu Sigma]=SEDS_Solver(Priors_0,Mu_0,Sigma_0,data_0,options); %running SEDS optimization solver
ds_seds = @(x) GMR(Priors,Mu,Sigma,x,1:2,3:4);
fig3 = subplot(1,3,3);
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
plot_ds_model(fig3, ds_seds, target);
axis tight
title('SEDS Dynamics from Demo', 'Interpreter','LaTex')

%% Reshape 'Original Dynamics with GP-MDS'
figure('Color',[1 1 1])
% hyper-parameters for gaussian process
% these can be learned from data but we will use predetermined values here
ell = 0.25; % lengthscale. bigger lengthscale => smoother, less precise ds
sf = 0.25; % signal variance 
sn = 0.1; % measurement noise 
thres = 0.1;

% we pack the hyper paramters in logarithmic form in a structure
hyp.cov = log([ell; sf]);
hyp.lik = log(sn);
% for convenience we create a function handle to gpr with these hyper
% parameters and with our choice of mean, covaraince and likelihood
% functions. Refer to gpml documentation for details about this. 
gp_handle = @(train_in, train_out, query_in) gp(hyp, ...
    @infExact, {@meanZero},{@covSEiso}, @likGauss, ...
    train_in, train_out, query_in);

% 1) Construct LMDS Data for Original Linear Dynamics
lmds_data = [];
dsi = 1;
dei = length(data);
lmds_data = [lmds_data, generate_lmds_data_2d(data(1:2,dsi:dei)-repmat(target,[1 length(data)]),data(3:4,dsi:dei),ds_lin(data(1:2,dsi:dei)-repmat(target,[1 length(data)])),thres)];

% Define our reshaped dynamics
reshaped_ds = @(x) gp_mds_2d(ds_lin, gp_handle, lmds_data, x);
fig4 = subplot(1,3,1);
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
% to understand where the gp has influence
plot_gp_variance_2d(fig4,gp_handle, lmds_data(1:2,:)+repmat(target, 1,size(lmds_data,2))); hold on;
% Reshaped dynamics
plot_ds_model(fig4, reshaped_ds, target); hold on;
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
axis tight
title('Reshaped Original Linear Dynamics', 'Interpreter','LaTex')


% 2) Construct LMDS Data for Stable Linear Dynamics
ds_mix  = @(x) get_dyn_mix_lds(lambda, x);
lmds_data = [];
dsi = 1;
dei = length(data);
lmds_data = [lmds_data, generate_lmds_data_2d(data(1:2,dsi:dei)-repmat(target,[1 length(data)]),data(3:4,dsi:dei),ds_mix(data(1:2,dsi:dei)-repmat(target,[1 length(data)])),thres)];

% Define our reshaped dynamics
reshaped_ds = @(x) gp_mds_2d(ds_mix, gp_handle, lmds_data, x);
fig5 = subplot(1,3,2);
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
% to understand where the gp has influence
plot_gp_variance_2d(fig5,gp_handle, lmds_data(1:2,:)+repmat(target, 1,size(lmds_data,2))); hold on;
% Reshaped dynamics
plot_ds_model(fig5, reshaped_ds, target); hold on;
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
axis tight
title('Reshaped Stable Linear Dynamics', 'Interpreter','LaTex')

% 3) Construct LMDS Data for SEDS
lmds_data = [];
dsi = 1;
dei = length(data);
lmds_data = [lmds_data, generate_lmds_data_2d(data(1:2,dsi:dei)-repmat(target,[1 length(data)]),data(3:4,dsi:dei),ds_seds(data(1:2,dsi:dei)-repmat(target,[1 length(data)])),thres)];

% Define our reshaped dynamics
reshaped_ds = @(x) gp_mds_2d(ds_seds, gp_handle, lmds_data, x);
fig6 = subplot(1,3,3);
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
% to understand where the gp has influence
plot_gp_variance_2d(fig6,gp_handle, lmds_data(1:2,:)+repmat(target, 1,size(lmds_data,2))); hold on;
% Reshaped dynamics
plot_ds_model(fig6, reshaped_ds, target); hold on;
scatter(target(1,1),target(2,1),50,[0 0 0],'filled'); hold on
scatter(data(1,:),data(2,:),10,[0 0 0],'filled'); hold on
axis tight
title('Reshaped SEDS', 'Interpreter','LaTex')
