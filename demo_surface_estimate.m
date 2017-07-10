%% 1) 2D Simulated Dataset from Sina's CODS Toolbox
clear all; clc;
data_path = './test-data/'; dataset_name = 'Toy';

load(strcat(data_path,'Toy/Toy_Data.mat'))
openfig(strcat(data_path,'Toy/Toy_simulation.fig'))

for i=1:length(X_modulated)
    Data{i} = [X_modulated{i}(1,1:10:end); zeros(size(X_modulated{i}(1,1:10:end))); X_modulated{i}(2,1:10:end); zeros(4,length(X_modulated{i}(1,1:10:end))); ...        
        -0.85*F_modulated{i}(1,1:10:end); 0.05*F_modulated{i}(1,1:10:end);  F_modulated{i}(1,1:10:end)]';
    True_states{i} = 2*ones(1,length(Data{i}))';
    for k=1:length(Data{i})
        if Data{i}(k,10) == 0 
            True_states{i}(k,1) = 1;    
        end
    end    
end

% Plot Segmentated 3D Trajectories
label_range = [1:2];
titlename = strcat(dataset_name,' Demonstrations (Segmented)');
if exist('h0','var') && isvalid(h0), delete(h0);end
h0 = plotLabeled3DTrajectories(Data, True_states, titlename, label_range);
axis tight

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
demo_id = 10;
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
plot_options.plot_labels  = {'x','y','z'};
plot_options.title        = 'Position DomainDemonstrations';

if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = ml_plot_data(position(:,1:sample:end)',plot_options);
hold on;
% ylim([-0.5 1])
% Plot resultant velocity vector
X = position(1,1:sample:end)'; Y = position(2,1:sample:end)'; Z = position(3,1:sample:end)';
U = velocity(1,1:sample:end)'; V = velocity(2,1:sample:end)'; W = velocity(3,1:sample:end)';
quiver3(X,Y,Z,U,V,W,'color',[0,0,1],'linewidth',.5); hold on;

% Normalize velocity directions
for i=1:length(U)
    vel = [U(i) V(i) W(i)]/norm([U(i) V(i) W(i)]);
    U(i) = vel(1);
    V(i) = vel(2);
    W(i) = vel(3);
end

% % Plot normalized velocity directions
quiver3(X,Y,Z,U,zeros(size(U)),zeros(size(U)),'color',[0,0.5,1],'linewidth',.5); hold on;
quiver3(X,Y,Z,zeros(size(U)),V,zeros(size(U)),'color',[0,0.5,1],'linewidth',.5); hold on;
quiver3(X,Y,Z,zeros(size(U)),zeros(size(U)),W,'color',[0,0.5,1],'linewidth',.5); hold on;

% Plot resultant forces
Fx = forces(1,1:sample:end)'; Fy = forces(2,1:sample:end)'; Fz = forces(3,1:sample:end)';
quiver3(X,Y,Z,Fx,Fy,Fz,'color',[1,0,0],'linewidth',.5); hold on;

approx_frict_x = zeros(size(Fx));
approx_frict_y = zeros(size(Fx));
approx_frict_z = zeros(size(Fx));
err_x = zeros(size(Fx));
err_y = zeros(size(Fy));
err_z = zeros(size(Fz));
for i=1:length(U)
    % Estimate approx. friction coeff
    if Fz(i) > 0
        approx_frict_z(i) = sqrt(Fx(i)^2 + Fy(i)^2)/Fz(i);
    end
    if Fx(i) > 0
        approx_frict_x(i) = sqrt(Fy(i)^2 + Fz(i)^2)/Fx(i);
    end
    if Fy(i) > 0
        approx_frict_y(i) = sqrt(Fx(i)^2 + Fz(i)^2)/Fy(i);
    end
    
    % Normalize force directions
    force = [Fx(i) Fy(i) Fz(i)]/norm([Fx(i) Fy(i) Fz(i)]);
    Fx(i) = force(1);
    Fy(i) = force(2);
    Fz(i) = force(3);
   
    % Dot-product of normalized directions
    err_x(i) = dot([U(i) 0 0] , [Fx(i) 0 0]); 
    err_y(i) = dot([0 V(i) 0] , [0 Fy(i) 0]);
    err_z(i) = dot([0 0 W(i)] , [0 0 Fz(i)]);
    
end

% Plot normalized force directions
quiver3(X,Y,Z,Fx,zeros(size(Fx)),zeros(size(Fx)),'color',[1,0.25,0],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(Fx)),Fy,zeros(size(Fx)),'color',[1,0.25,0],'linewidth',.25); hold on;
quiver3(X,Y,Z,zeros(size(Fz)),zeros(size(Fz)),Fz,'color',[1,0.25,0],'linewidth',.25);
axis tight;

% Plot Approx Friction Coefficient
if exist('h2','var') && isvalid(h2), delete(h2);end
h2 = figure('Color',[1 1 1]);
subplot(3,1,1)
stairs(phases(1:sample:end), 'LineWidth',2); 
title('Phases','Interpreter', 'LaTex', 'FontSize',20)
grid on;
subplot(3,1,2)
plot(approx_frict_x, 'LineWidth',2); hold on;
plot(approx_frict_y, 'LineWidth',2); hold on;
plot(approx_frict_z, 'LineWidth',2); 
ylim([0 2])
legend('x-normal','y-normal','z-normal')
plot(ones(length(approx_frict_x)), 'LineWidth',2, 'Color', [0 0 0]); hold on;
title('Approximate Friction $\tilde{\mu} = (f_x^2+f_y^2)^{(-1/2)}/f_z$','Interpreter', 'LaTex', 'FontSize',20)
grid on;
subplot(3,1,3)
plot(err_x, 'LineWidth',2); hold on;
plot(err_y, 'LineWidth',2); hold on;
plot(err_z, 'LineWidth',2); 
legend({'$f_{x}/||f_{x}|| - v_{x}/||v_{x}||$','$f_{y}/||f_{y}|| - v_{y}/||v_{y}||$','$f_{z}/||f_{z}|| - v_{z}/||v_{z}||$'},'Interpreter', 'LaTex')
title('Friction Plane Errors','Interpreter', 'LaTex', 'FontSize',20)
grid on;
