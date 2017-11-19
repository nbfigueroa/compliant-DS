%% Example of Locally Modulated Dynamical Systems (from Simple Linear Dynamics)
% clear all; close all; clc

% Inputs to the function
% Choose initial linear DS parameters
ds_type = 1;          % 1: lin DS converging to origin, 2: DS diverging from origin, 
                      % 3: vector field in x, 4: vector field in y, 5: curve
                      % 6,7: diag/target 1/2, 8,9: converg curves 1/2
target = [0 0]';      % Target of DS

% Choose Modulation Type
mod_type = 'data';   % 'data': with trajectories, 'rand': random matrices
                     % 'rot':  with random rotation matrices                   

limits = [-3 1 -0.75 1.5];

% Plot Linear DS and Draw Shaping Data
[fig] = simulate_lmds(ds_type, target, mod_type, limits);
