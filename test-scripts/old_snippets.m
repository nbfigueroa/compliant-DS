%% 2) Real 'Dough-Rolling' 12D dataset, 3 Unique Emission models, 12 time-series
% Demonstration of a Dough Rolling Task consisting of 
% 15 (13-d) time-series X = {x_1,..,x_T} with variable length T. 
clc; clear all; close all;
data_path = './test-data/'; type = 'aligned'; % 'aligned'/'rotated'
dataset_name = 'Rolling'; demos = [1:2]; labels = 'human'; % 'human'/'icsc-hmm'; 

% Define if using first derivative of pos/orient
[Data, True_states] = load_rolling_demos( data_path, type, demos, labels);
label_range = [1:3];

% Plot Segmentated 3D Trajectories
titlename = strcat(dataset_name,' Demonstrations (Segmented)');
if exist('h0','var') && isvalid(h0), delete(h0);end
h0 = plotLabeled3DTrajectories(Data, True_states, titlename, label_range);
axis tight

%% 2) Stable Linear Dynamics approx from Demonstrations
% Optimization options
clear sld_options;
sld_options.solver = 'fmincon';              % YALMIP solvers, e.g. 'sedumi'|NLP solvers 'fmincon' | 'fminsdp'
sld_options.criterion = 'mse';               % 'mse'|'logdet'(only for fminsdp)
sld_options.c_reg = 1e-3;                    % Pos def eps margin
sld_options.verbose = 0;                     % Verbose (0-5)
sld_options.warning = false;                 % Display warning information
sld_options.attractor = target;              % Set the attractor a priori
sld_options.weights = ones(1,size(data,2));  % Weights for each sample

[A, b] = estimate_stable_lds(data, sld_options);
ds_sld = @(x) lin_ds(A,b,x);


%% Simulate Passive DS Controller
dt = 0.005;
% Setting robot to starting point
disp('Select a starting point for the simulation...')
disp('Once the simulation starts you can perturb the robot with the mouse to get an idea of its compliance.')
try
    xs = get_point(fig1) - base;
    % Another option (Start around demonstrations) :
    % xs  =  Data(1:2,1) - base + 0.15*randn(1,2)'
    qs = simple_robot_ikin(robot, xs);
    robot.animate(qs);
catch
    disp('could not find joint space configuration. Please choose another point in the workspace.')
end

% Run Simulation
[hd, hx] = simulation_passive_control(fig1, robot, base, reshaped_ds, target, qs, dt);

%% Check Feasibility of Demonstrations
for i=1:length(Data)
    try
        xi  =  Data(1:2,i) - base;
        qi = simple_robot_ikin(robot, xi);
        robot.delay = realmin;
        robot.animate(qi);
    catch
        disp('could not find joint space configuration. Please choose another point in the workspace.')
    end
end