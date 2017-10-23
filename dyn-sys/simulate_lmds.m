function [ fig1, reshaped_ds, Data ] = simulate_lmds(ds_type, target, mod_type, limits, varargin)

% If robot figure, take figure handle
if nargin > 4
    fig1 = varargin{1};
else
    fig1 = figure('Color',[1 1 1]);
end

if ((ds_type > 3) & (ds_type < 5))
    target = [0 0]';
    display('no target');
end

% Construct and plot chosen Linear DS
ds_lin = @(x) lin_ds(target, x, ds_type);
hs = plot_ds_model(fig1, ds_lin, target, limits,'high'); hold on;
% axis tight
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
        ell = 0.15; % lengthscale. bigger lengthscale => smoother, less precise ds
        sf = 0.2; % signal variance
        sn = 0.2; % measurement noise        
        thres = 0.05;
        
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
        % Delete lin DS model
        delete(hs)
        % Plot variance, to understand where the gp has influence             
        hv = plot_gp_variance_2d(limits, gp_handle, lmds_data(1:2,:)+repmat(target, 1,size(lmds_data,2)));    
               
    case 'rand'
        display('Select Center of Modulation')
        % Center of Local Activation
        axis(limits);
        c = get_point(fig1);
        % Influence of Local Activation
        ls = 10;
        hold on;
        scatter(c(1),c(2),10,[1 0 0],'filled')
        exp_funct = @(x) exp_loc_act(ls, c, x);
        plot_exp_2d(fig1, exp_funct); hold on;
        
        % Define our reshaped dynamics
        reshaped_ds = @(x) lmds_2d(ds_lin, exp_funct, mod_type, x);
        display('Press Enter to Reshape DS')
        pause;
        
        % Delete lin DS model
        delete(hs)
        
    case 'rot'   
        display('Select Center of Modulation')
        % Center of Local Activation
        axis(limits);
        c = get_point(fig1);
        % Influence of Local Activation
        ls = 10;
        hold on;
        scatter(c(1),c(2),10,[1 0 0],'filled')
        exp_funct = @(x) exp_loc_act(ls, c, x);
        h_exp = plot_exp_2d(fig1, exp_funct); hold on;
        
        % Define our reshaped dynamics
        reshaped_ds = @(x) lmds_2d(ds_lin, exp_funct, mod_type, x);
        display('Press Enter to Reshape DS')
        pause;
        
        % Delete lin DS model
        delete(hs)
        
end
% Plot Reshaped dynamics
hs = plot_ds_model(fig1, reshaped_ds, target, limits, 'high'); 
title('Reshaped Dynamics $\dot{x}=f(x)=M(x)f_o(x)$ ', 'Interpreter','LaTex')
display('Reshaping Done.');

end

