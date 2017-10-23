%% Example of Passive Interaction Controller with DS w/Planar Free Motion
% Inputs to the function
close all, clear all

% set up a simple robot and a figure that plots it
robot = create_simple_robot();
fig1 = initialize_robot_figure(robot);
title('Feasible Robot Workspace','Interpreter','LaTex')

% Base Offset
base = [-1 1]';

% Choose initial linear DS parameters
ds_type = 10;          % 1: lin DS converging to origin, 2: DS diverging from origin, 
                      % 3: vector field in x, 4: vector field in y, 5: curve
                      % 6,7: diag/target 1/2, 8,9: converg curves 1/2
                      % 10: spring-like linear DS
target = [0 0]';      % Target of DS

% Choose Modulation Type
mod_type = 'data';    % 'data': with trajectories, 'rand': random matrices
                      % 'rot':  with random rotation matrices
% Axis limits
limits = [-2.5 0.5 -0.45 1.2];

% Plot Linear DS and Draw Shaping Data
[ fig1, reshaped_ds, Data ] = simulate_lmds(ds_type, target, mod_type, limits, fig1);

%% Simulate Passive DS Controller
% Remove Old Simulation if it exists
if exist('hd','var'), delete(hd); end
if exist('hx','var'), delete(hx); end

%% Setting robot to starting point
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
dt = 0.005;
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