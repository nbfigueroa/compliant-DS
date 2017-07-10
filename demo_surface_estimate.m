%% 1) 2D Simulated Dataset from Sina's CODS Toolbox
data_path = './test-data/';

load(strcat(data_path,'Toy/Toy_Data.mat'))
openfig(strcat(data_path,'Toy/Toy_simulation.fig'))

%% Concatenate Data
for i=1:length(X_modulated)
    Data{i} = [X_modulated{i}(1,1:10:end); zeros(size(X_modulated{i}(1,1:10:end))); X_modulated{i}(2,1:10:end); ...
        -0.5*F_modulated{i}(1,1:10:end); zeros(size(X_modulated{i}(1,1:10:end)));  F_modulated{i}(1,1:10:end)];
    True_states{i} = 2*ones(length(Data{i}));
    free_motion = F_modulated{i}(1,:)==0;
    True_states{i}(1,free_motion) = 1;    
end

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
%% 3) Real 'Peeling' (max) 13-D dataset, 5 Unique Emission models, 3 time-series
% Demonstration of a Bimanual Peeling Task consisting of 
% 3 (32-d) time-series X = {x_1,..,x_T} with variable length T. 
% Dimensions:
clc; clear all; close all;
data_path = './test-data/'; type = 'aligned'; % 'aligned'/'rotated'
dataset_name = 'Peeling'; demos = [1]; labels = 'human'; % 'human'/'icsc-hmm'; 

[Data, True_states] = load_peeling_demos( data_path, demos, labels);
label_range = [2:3];

% Plot Segmentated 3D Trajectories
titlename = strcat(dataset_name,' Demonstrations (Segmented)');
if exist('h0','var') && isvalid(h0), delete(h0);end
h0 = plotLabeled3DTrajectories(Data, True_states, titlename, label_range);
axis tight

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     Data Analysis for physically-inspired discretization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute more features for Data Analysis
demo_id = 3;
data    = Data{demo_id}';
phases  = True_states{demo_id}(1:end-2)';

% Convert positions to velocities
position    = data(1:3,1:end-1);
velocity   = [diff(position(1,:));diff(position(2,:));diff(position(3,:))];
velocity   = sgolayfilt(velocity', 3, 151)';
position    = data(1:3,1:end-2);
% Convert positions to velocities
forces     = data(8:10,1:end-2);

% Sample
sample = 1;

% Plot original data
plot_options              = [];
plot_options.is_eig       = false;
plot_options.labels       = phases(1:sample:end);
plot_options.points_size  = 20;
plot_options.class_names  = {'Reach', 'Roll','Back'};
plot_options.plot_labels  = {'x','y','z'};
plot_options.title        = 'Position Domain  Rolling Demonstrations';

if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = ml_plot_data(position(:,1:sample:end)',plot_options);
hold on;

% Plot resultant velocity vector
X = position(1,1:sample:end)'; Y = position(2,1:sample:end)'; Z = position(3,1:sample:end)';
U = velocity(1,1:sample:end)'; V = velocity(2,1:sample:end)'; W = velocity(3,1:sample:end)';
quiver3(X,Y,Z,U,V,W,'color',[0,0,1],'linewidth',.25); hold on;

% Normalize velocity directions
for i=1:length(U)
    vel = [U(i) V(i) W(i)]/norm([U(i) V(i) W(i)]);
    U(i) = vel(1);
    V(i) = vel(2);
    W(i) = vel(3);
end

% Plot normalized velocity directions
quiver3(X,Y,Z,U,zeros(size(U)),zeros(size(U)),'color',[0,0.5,1],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(U)),V,zeros(size(U)),'color',[0,0.5,1],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(U)),zeros(size(U)),W,'color',[0,0.5,1],'linewidth',.25); hold on;

% Plot resultant forces
Fx = forces(1,1:sample:end)'; Fy = forces(2,1:sample:end)'; Fz = forces(3,1:sample:end)';
% quiver3(X,Y,Z,Fx,Fy,Fz,'color',[1,0,0],'linewidth',.25); hold on;

approx_frict = zeros(size(Fx));
dotxy = zeros(size(Fx));
dotxz = zeros(size(Fy));
dotyz = zeros(size(Fz));
for i=1:length(U)
    % Estimate approx. friction coeff
    if Fz(i) > 0
        approx_frict(i) = sqrt(Fx(i)^2 + Fy(i)^2)/Fz(i);
    end
    
    % Normalize force directions
    force = [Fx(i) Fy(i) Fz(i)]/norm([Fx(i) Fy(i) Fz(i)]);
    Fx(i) = force(1);
    Fy(i) = force(2);
    Fz(i) = force(3);
   
    % Dot-product of normalized directions
    dotxy(i) = dot([U(i) V(i)],[Fx(i) Fy(i)]); 
    dotxz(i) = dot([U(i) W(i)],[Fx(i) Fz(i)]);
    dotyz(i) = dot([V(i) W(i)],[Fy(i) Fz(i)]);
    
end

% Plot normalized force directions
quiver3(X,Y,Z,Fx,zeros(size(Fx)),zeros(size(Fx)),'color',[1,0.25,0],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(Fx)),Fy,zeros(size(Fx)),'color',[1,0.25,0],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(Fz)),zeros(size(Fz)),Fz,'color',[1,0.25,0],'linewidth',.25);

% Plot Approx Friction Coefficient
if exist('h2','var') && isvalid(h2), delete(h2);end
h2 = figure('Color',[1 1 1]);
subplot(3,1,1)
stairs(phases(1:sample:end), 'LineWidth',2); 
title('Phases','Interpreter', 'LaTex', 'FontSize',20)
grid on;
subplot(3,1,2)
plot(approx_frict, 'LineWidth',2); hold on;
plot(ones(length(approx_frict)), 'LineWidth',2, 'Color', [0 0 0]); hold on;
title('Approximate Friction $\tilde{\mu} = (f_x^2+f_y^2)^{(-1/2)}/f_z$','Interpreter', 'LaTex', 'FontSize',20)
grid on;
subplot(3,1,3)
plot(dotxy, 'LineWidth',2); hold on;
plot(dotxz, 'LineWidth',2); hold on;
plot(dotyz, 'LineWidth',2); 
legend({'$f_{xy}/||f_{xy}|| \cdot v_{xy}/||v_{xy}||$','$f_{xz}/||f_{xz}|| \cdot v_{yz}/||v_{yz}||$','$f_{yz}/||f_{yz}|| \cdot v_{yz}/||v_{yz}||$'},'Interpreter', 'LaTex')
title('Dot products of normalized directions','Interpreter', 'LaTex', 'FontSize',20)
grid on;
