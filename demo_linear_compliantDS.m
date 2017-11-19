%% Example of Passive Interaction Controller with DS w/Planar Free Motion
% Inputs to the function
close all; clear all; clc

% set up a simple robot and a figure that plots it
robot = create_simple_robot();
fig1 = initialize_robot_figure(robot);
title('Feasible Robot Workspace','Interpreter','LaTex')

% Base Offset
base = [-1 1]';
% Axis limits
limits = [-2.5 0.5 -0.45 1.2];

% Plot Attractor
target = [0 0]';       % Target of DS
scatter(target(1),target(2),100,[0 0 0],'+'); hold on;

% Draw Reference Trajectory
data = draw_mouse_data_on_DS(fig1, limits, 1);
Data = [];
for l=1:length(data)
    Data = [Data data{l}];
end
% First point of reference trajectory \xi_0
xi_0 = Data(1:2,1);

%% Choose DS parameters
if exist('hs','var');     delete(hs);    end
if exist('ha1','var');    delete(ha1);   end
if exist('ha2','var');    delete(ha2);   end
if exist('ht','var');     delete(ht);    end
if exist('h_dec','var');  delete(h_dec); end
if exist('h_data','var'); delete(h_data);end

% Choose compliant DS mixing type                        
mix_type = 3;          % 1: fixed: needs value of alpha_1
                       % 2: logistic: logistic curve, needs center of trans
                       % 3: probabilistic classifier: rvm for binary
                       % non-linear state-space partition from transitions
                       % 4: continuous                      
                       
x = [-2.5:0.01:0]; 
switch mix_type    
    case 1
        param = 0.5;       % Set desired value for alpha
        y = param*ones(1,length(x));
        
    case 2
        trans_point = Data(1:2,1)*(1/2);  % Set desired transition point to mid-point
        ht = scatter(trans_point(1),trans_point(2),200,[0 0 0],'filled','^');
        a = 1; b = 0;                     % DS order
        c = -norm(trans_point - target);  % transition point
        s = -12/c;
        log_fct = @(x) gen_logistic_fnct(x, a, b, c, s);
        y = feval(log_fct,x);
        param   = log_fct;
        mix_fct = log_fct;
        % Plot values of mixing function to see where transition occur
        h_dec = plot_mixing_fct_2d(limits, param, target);
        
    case 3
        start        = 'converging'; % 'converging','tracking'
        transitions  = [2/3 1/5];
        rbf_width    = 0.5;
        
        % Generate labeled trajectories from transition definition
        [data_labels, trans_points] = generate_labeled_trajectory(Data, transitions, start);       
        
        %Set RVM OPTIONS%
        clear rvm_options
        rvm_options.useBias = true;
        rvm_options.kernel_ = 'gauss';
        rvm_options.width   = rbf_width;
        rvm_options.maxIts  = 100;
        
        % Train RVM Classifier
        try
            [predict_labels, model] = rvm_classifier(Data(1:2,:)', data_labels' , rvm_options, []);
        catch
            warning('RBF kernel width ill-defined..');
        end
        
        % Plot RVM decision boundary        
        [h_data, h_dec] = my_plot_rvm_boundary( Data(1:2,:)', data_labels',model, limits, 'draw'); 
                
        % Plot Transition Points and Data labels        
        ht = scatter(trans_points(1,2:end-1),trans_points(2,2:end-1),200,[0 0 0],'filled','^');
        
        % Create function handle for State-Space Partitioning
        rvm_fct = @(x) rvm_predict_probability(x, model);
        y = feval(rvm_fct,Data(1:2,:)');
        x = linspace(-2.50,0,length(y)); 
        param = rvm_fct;
end

% Plot Dynamical System
ds_lin = @(x) lin_compliant_ds(target,x, mix_type,xi_0, param);
hs = plot_ds_model(fig1, ds_lin, target, limits,'high'); hold on;
title('Linear Compliant Dynamics $\dot{\xi}=\alpha(\xi)f_c(\xi) + (1 - \alpha(\xi))f_t(\xi)$', 'Interpreter','LaTex')

%% Plot Mixing Function
fig2 = figure('Color',[1 1 1]);
figure(fig2),ha1 = plot(x,y,'Color',[1 0 0], 'LineWidth',2); hold on;
figure(fig2),ha2 = plot(x,1-y,'Color',[0 1 0],'LineWidth',2);
legend({'$\alpha_c$','$\alpha_t$'},'Interpreter','LaTex','FontSize',20)
xlabel('$-||\xi - \xi^*||$','Interpreter','LaTex','FontSize',20)
title('Mixing Function $\alpha(\xi)$','Interpreter','LaTex','FontSize',20)
grid on;
axis([-2.5 0 0 1]);
hold off

%% Simulate Passive DS Controller function
dt = 0.005;
simulate_passiveDS(fig1, robot, base, ds_lin, target, dt);
