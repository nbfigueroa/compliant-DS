%% Example of Passive Interaction Controller with DS on Point-Mass
% Inputs to the function
% Choose initial linear DS parameters
ds_type = 1;          % 1: lin DS converging to origin, 2: DS diverging from origin, 
                      % 3: vector field in x, 4: vector field in y, 5: curve
                      % 6,7: diag/target 1/2, 8,9: converg curves 1/2
target = [0 0]';      % Target of DS
if ds_type < 6 && ds_type > 2
    limits = [0 1 0 1];     % Axis Limits for drawing
else    
    limits = [-1 1 -0.5 1]; % Axis Limits for drawing
end
% Choose Modulation Type
mod_type = 'rot';   % 'data': with trajectories, 'rand': random matrices
                    % 'rot':  with random rotation matrices

%% Plot Linear DS and Draw Shaping Data
% if exist('fig1','var') && isvalid(fig1), delete(figdata1);end
fig1 = figure('Color',[1 1 1]);
ds_lin = @(x) lin_ds([],x, ds_type);
plot_ds_model(fig1, ds_lin, target, limits); hold on;
axis tight
title('Original Linear Dynamics $\dot{x}=f_o(x)$', 'Interpreter','LaTex')
   
switch mod_type

    case 'data'        
        data = draw_mouse_data_on_DS(fig1, limits);
        Data = [];
        for l=1:length(data)
            Data = [Data data{l}];
        end
        display('Press Enter to Reshape DS')
        pause;
        
        % Reshape 'Original Dynamics with GP-MDS'
        % hyper-parameters for gaussian process
        % these can be learned from data but we will use predetermined values here
        ell = 0.1; % lengthscale. bigger lengthscale => smoother, less precise ds
        sf = 0.15; % signal variance
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
        
        % Construct LMDS Data for Original Linear Dynamics
        lmds_data = [];
        dsi = 1;
        dei = length(Data);
        lmds_data = [lmds_data, generate_lmds_data_2d(Data(1:2,dsi:dei)-repmat(target,[1 length(Data)]),Data(3:4,dsi:dei),ds_lin(Data(1:2,dsi:dei)-repmat(target,[1 length(Data)])),thres)];
        
        % Define our reshaped dynamics
        reshaped_ds = @(x) gp_mds_2d(ds_lin, gp_handle, lmds_data, x);
        % to understand where the gp has influence
        plot_gp_variance_2d(fig1, gp_handle, lmds_data(1:2,:)+repmat(target, 1,size(lmds_data,2))); hold on;
        scatter(Data(1,:),Data(2,:),10,[1 0 0],'filled')
        
    case 'rand'
        display('Select Center of Modulation')
        % Center of Local Activation
        c = get_point(fig1);
        % Influence of Local Activation
        ls = 10;
        hold on;
        scatter(c(1),c(2),10,[1 0 0],'filled')
        exp_funct = @(x) exp_loc_act(ls, c, x);
        plot_exp_2d(fig1, exp_funct); hold on;
        h = plot_ds_model(fig1, ds_lin, target, limits);
        
        % Define our reshaped dynamics
        reshaped_ds = @(x) lmds_2d(ds_lin, exp_funct, mod_type, x);
        display('Press Enter to Reshape DS')
        pause;
        delete(h)
        
    case 'rot'   
        display('Select Center of Modulation')
        % Center of Local Activation
        c = get_point(fig1);
        % Influence of Local Activation
        ls = 10;
        hold on;
        scatter(c(1),c(2),10,[1 0 0],'filled')
        exp_funct = @(x) exp_loc_act(ls, c, x);
        plot_exp_2d(fig1, exp_funct); hold on;
        h = plot_ds_model(fig1, ds_lin, target, limits);
        
        % Define our reshaped dynamics
        reshaped_ds = @(x) lmds_2d(ds_lin, exp_funct, mod_type, x);
        display('Press Enter to Reshape DS')
        pause;
        delete(h)
        
end

% Reshaped dynamics

plot_ds_model(fig1, reshaped_ds, target, limits); hold on;
title('Reshaped Dynamics $\dot{x}=f(x)=M(x)f_o(x)$ ', 'Interpreter','LaTex')
display('Reshaping Done.');

clear lin_ds reshaped_ds
