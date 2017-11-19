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
data = draw_mouse_data_on_DS(fig1, limits);
Data = [];
for l=1:length(data)
    Data = [Data data{l}];
end
% First point of reference trajectory \xi_0
xi_0 = Data(1:2,1);

%% Select transition points and compliant behavior type
start        = 'converging'; % 'converging','tracking'
transitions  = [3/4 1/2 1/5];
rbf_width    = 0.75;

% Generate labeled trajectories from transition definition
[data_labels, trans_points] = generate_labeled_trajectory(Data, transitions, start);

% Plot Transition Points and Data labels
if exist('htrans','var');  delete(htrans); end
htrans = scatter(trans_points(1,2:end-1),trans_points(2,2:end-1),200,[0 0 0],'filled','^'); 

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
if exist('h_dec','var');  delete(h_dec); end
if exist('h_data','var'); delete(h_data); end
[h_data, h_dec] = my_plot_rvm_boundary( Data(1:2,:)', data_labels', model, limits, 'draw');
