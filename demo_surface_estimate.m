%% 1) 2D Simulated Dataset from Sina's CODS Toolbox


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
titlename = strcat(dataset_name,' Demonstrations (',labels,')');
if exist('h7','var') && isvalid(h7), delete(h7);end
h7 = plotLabeled3DTrajectories(Data, True_states, titlename, label_range);
axis tight

%% Compute more features for Data Analysis
demo_id = 1;
data    = Data{demo_id}';
phases  = True_states{demo_id}(1:end-1)';

% Convert positions to velocities
position    = data(1:3,1:end-2);
velocity   = [diff(position(1,:));diff(position(2,:));diff(position(3,:))];
velocity   = sgolayfilt(velocity', 3, 151)';

% Convert positions to velocities
forces     = data(8:10,1:end-1);

% Sample
sample = 20;

% Plot original data
plot_options              = [];
plot_options.is_eig       = false;
plot_options.labels       = phases(1:sample:end);
plot_options.points_size  = 10;
plot_options.class_names  = {'Reach', 'Roll','Back'};
plot_options.title        = 'Position Domain  Rolling Demonstrations';

if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = ml_plot_data(position(:,1:sample:end)',plot_options);
hold on;

% Plot velocities
X = position(1,1:sample:end)'; Y = position(2,1:sample:end)'; Z = position(3,1:sample:end)';
U = velocity(1,1:sample:end)'; V = velocity(2,1:sample:end)'; W = velocity(3,1:sample:end)';
quiver3(X,Y,Z,U,zeros(size(U)),zeros(size(U)),'color',[0,0,1],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(U)),V,zeros(size(U)),'color',[0,0,1],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(U)),zeros(size(U)),W,'color',[0,0,1],'linewidth',.25); hold on;
quiver3(X,Y,Z,U,V,W,'color',[0,1,1],'linewidth',.25); hold on;

% Plot forces
Fx = forces(1,1:sample:end)'; Fy = forces(2,1:sample:end)'; Fz = forces(3,1:sample:end)';
quiver3(X,Y,Z,Fx,zeros(size(Fx)),zeros(size(Fx)),'color',[1,0,0],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(Fx)),Fy,zeros(size(Fx)),'color',[1,0,0],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(Fz)),zeros(size(Fz)),Fz,'color',[1,0,0],'linewidth',.25);
quiver3(X,Y,Z,Fx,Fy,Fz,'color',[0,1,1],'linewidth',.25); hold on;

%% 3) Real 'Peeling' (max) 32-D dataset, 5 Unique Emission models, 3 time-series
% Demonstration of a Bimanual Peeling Task consisting of 
% 3 (32-d) time-series X = {x_1,..,x_T} with variable length T. 
% Dimensions:
clc; 
clear all; close all
data_path = '../ICSC-HMM/test-data/'; display = 0; 

% Type of data processing
% O: no data manipulation -- 1: zero-mean -- 2: scaled by range * weights
normalize = 2; 

% Select dimensions to use
dim = 'active'; 

% Define weights for dimensionality scaling
weights = [3*ones(1,3) 1/2*ones(1,4) 1/15*ones(1,3) 1/2*ones(1,3)]';
switch dim                
    case 'active'
    case 'robots' 
        weights = [weights 1/3*ones(1,3) 2*ones(1,4) 1/15*ones(1,3) 1/5*ones(1,3)]';        
end

% Define if using first derivative of pos/orient
use_vel = 0;

[data, TruePsi, Data, True_states, Data_] = load_peeling_dataset( data_path, dim, display, normalize, weights, use_vel);
dataset_name = 'Peeling';




