%% Example of Passive Interaction Controller with DS w/Planar Free Motion
% Inputs to the function
close all; clear all; clc

%% set up a simple robot and a figure that plots it
robot = create_simple_robot();
fig1 = initialize_robot_figure(robot);
title('Feasible Robot Workspace','Interpreter','LaTex')

% Base Offset
base = [-1 1]';
% Axis limits
limits = [-2.5 0.5 -0.45 1.2];

% Plot Attractor
target = [0 0]';       % Target of DS
scatter(target(1),target(2),50,[0 0 0],'+'); hold on;

% Draw Data or Use pre-drawn data
draw_data = 1;

% Choose initial linear DS parameters
ds_type = 1;          % 1: lin DS converging to origin, 2: DS diverging from origin, 
                      % 3: vector field in x, 4: vector field in y, 5: curve
                      % 6,7: diag/target 1/2, 8,9: converg curves 1/2
                      % 10: spring-like linear DS, 11: modulated compliant DS
if ds_type == 11
    alpha = 0.1;
else
    alpha = [];
end                       

% Choose Modulation Type
mod_type = 'data';    % 'data': with trajectories, 'rand': random matrices
                      % 'rot':  with random rotation matrices               
                      
% Choose Reshaping Type
reshape_type = 'lmds-gp';  % 'lmds-gp': use locally modulated DS with GP
                           % 'lmds-gmm': use locally modulated DS with GMM
                           % 'diff': use globally modulated DS with Diffeo.                      

% Plot Linear DS and Draw Shaping Data
if draw_data
    [ fig1, reshaped_ds, Data ] = simulate_lmds(ds_type, target, mod_type, limits, fig1, alpha);
else
    % Plot Linear DS and Pre-Recorded Data
    [ fig1, reshaped_ds, Data ] = simulate_lmds(ds_type, target, mod_type, limits, fig1, alpha, Data);
end

%% Simulate Passive DS Controller function
dt = 0.005;
simulate_passiveDS(fig1, robot, base, reshaped_ds, target, dt);

