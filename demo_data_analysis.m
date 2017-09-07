%% 1) 2D Simulated Sliding Dataset, 2 Unique Emission models, 3 time-series
clc; clear all; close all;
data_path = './test-data/'; dataset_name = 'Toy';

[ Data, True_states ] = load_toy_data( data_path );

% Plot Segmentated 3D Trajectories
label_range = [1:2];
titlename = strcat(dataset_name,' Demonstrations (Segmented)');
if exist('h0','var') && isvalid(h0), delete(h0);end
h0 = plotLabeled3DTrajectories(Data, True_states, titlename, label_range);
axis tight

%% 2) Real 'Peeling' (max) 13-D dataset, 2 Unique Emission models, 3 time-series
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

%% 3) Real 'Sanding' 13-D dataset, 3 Unique Emission models, 3 time-series
clc; clear all; close all;
data_path = './test-data/'; type = 'aligned'; % 'aligned'/'rotated'
dataset_name = 'Sanding'; demos = [1]; labels = 'human'; % 'human'/'icsc-hmm'; 
% [Data_seq True_states_seq] = load_peeling_demos( data_path, demos, labels)

load(strcat(data_path,'/Sanding/proc_data.mat'))
id = 1;
X = proc_data{id}.X;
t = proc_data{id}.t;
% figure('Color',[1 1 1]);
% plot3(X(1,:),X(2,:),X(3,:))
% plotEEData( X, [] , '')
good_data = [1 5962];
X_good = X(:,good_data(1):good_data(2));
t_good = t(:,good_data(1):good_data(2));
figure('Color',[1 1 1]);
plot3(X_good(1,:),X_good(2,:),X_good(3,:)); hold on;
scatter3(X_good(1,1),         X_good(2,1),          X_good(3,1), 50,[0 1 0], 'filled'); hold on;
scatter3(X_good(1,end),       X_good(2,end),       X_good(3,end), 50,[1 0 0], 'filled'); hold on;
plotEEData( X_good, [] , '')
Data{1} = X_good(:,1:2096)';    True_states{1} = [ones(1,722) 2*ones(1,1666-722) 3*ones(1,2096-1666)]';
Data{2} = X_good(:,2097:4200)'; True_states{2} = [ones(1,2721-2097) 2*ones(1,3710-2721) 3*ones(1,4200-3710)]';
Data{3} = X_good(:,4201:end)';  True_states{3} = [ones(1,4775-4201) 2*ones(1,5607-4775) 3*ones(1,5962-5608)]';
label_range = [1:3];
% Plot Segmentated 3D Trajectories
titlename = strcat(dataset_name,' Demonstrations (Segmented)');
if exist('h0','var') && isvalid(h0), delete(h0);end
h0 = plotLabeled3DTrajectories(Data, True_states, titlename, label_range);
axis tight
%% 4) Real 'Bumper-Wiping' 13-D dataset, 3 Unique Emission models, 2 time-series

%% 5) Real 'Fender-Wiping' 13-D dataset, 3 Unique Emission models, 1 time-series

%% 6) Real Controller 'Fender-Wiping' 13-D dataset, 3 Unique Emission models, 2 time-series

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     Data Analysis for physically-inspired discretization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute more features for Data Analysis
X_demos = []; Y_demos = []; Z_demos = [];
U_demos = []; V_demos = []; W_demos = [];
dot_x_demos  = [];dot_y_demos = []; dot_z_demos = [];
phases_demos = [];
X_demos_0 = []; Y_demos_0 = []; Z_demos_0 = [];
U_demos_0 = []; V_demos_0 = []; W_demos_0 = [];

% Go through all demos
for demo_id=1:3
    data    = Data{demo_id}';
    phases  = True_states{demo_id}(1:end-2)';
    
    % Compute velocities
    position    = data(1:3,1:end-1) ;  
    velocity    = [diff(position(1,:));diff(position(2,:));diff(position(3,:))];
    velocity    = sgolayfilt(velocity', 3, 151)';
    position    = data(1:3,2:end-1);

    position_0  = data(1:3,1:end-1);
    position_0  = position_0 - repmat(position_0(:,end),[1,length(position_0)]);  
    velocity_0  = [diff(position_0(1,:));diff(position_0(2,:));diff(position_0(3,:))];
    velocity_0  = sgolayfilt(velocity_0', 3, 151)';
    position_0  = position_0(1:3,2:end);

    % Gather force measurements
    forces     = data(8:10,1:end-2);
    
    % Sample
    sample = 3;
    
    % Plot individual directions
    plot_dir = 0;
    
    % Plot resultant velocity vector
    X = position(1,1:sample:end)'; Y = position(2,1:sample:end)'; Z = position(3,1:sample:end)';
    U = velocity(1,1:sample:end)'; V = velocity(2,1:sample:end)'; W = velocity(3,1:sample:end)';
    h1 = figure('Color',[1 1 1]);
    quiver3(X,Y,Z,U,V,W,'color',[0,0,1],'linewidth',.5); hold on;
    X_0 = position_0(1,1:sample:end)'; Y_0 = position(2,1:sample:end)'; Z_0 = position_0(3,1:sample:end)';
    U_0 = velocity_0(1,1:sample:end)'; V_0 = velocity(2,1:sample:end)'; W_0 = velocity_0(3,1:sample:end)';    

    X_demos = [X_demos; X];    Y_demos = [Y_demos; Y];    Z_demos = [Z_demos; Z];
    U_demos = [U_demos; U];    V_demos = [V_demos; V];    W_demos = [W_demos; W];
    phases_demos = [phases_demos phases(1,1:sample:end)];
    X_demos_0 = [X_demos_0; X_0];    Y_demos_0 = [Y_demos_0; Y_0];    Z_demos_0 = [Z_demos_0; Z_0];
    U_demos_0 = [U_demos_0; U_0];    V_demos_0 = [V_demos_0; V_0];    W_demos_0 = [W_demos_0; W_0];

    % Normalize velocity directions
    for i=1:length(U)
        vel = [U(i) V(i) W(i)]/norm([U(i) V(i) W(i)]);
        U(i) = vel(1);
        V(i) = vel(2);
        W(i) = vel(3);
    end
    
    % % Plot normalized velocity directions
    if plot_dir
        quiver3(X,Y,Z,U,zeros(size(U)),zeros(size(U)),'color',[0,1,1],'linewidth',.5); hold on;
        quiver3(X,Y,Z,zeros(size(U)),V,zeros(size(U)),'color',[0,0.5,1],'linewidth',.5); hold on;
        quiver3(X,Y,Z,zeros(size(U)),zeros(size(U)),W,'color',[0,1,1],'linewidth',.5); hold on;
    end
    
    % Plot resultant forces
    Fx = forces(1,1:sample:end)'; Fy = forces(2,1:sample:end)'; Fz = forces(3,1:sample:end)';
%     quiver3(X,Y,Z,Fx,Fy,Fz,'color',[1,0.75,0],'linewidth',.5); hold on;
    
    approx_frict_x = zeros(size(Fx));
    approx_frict_y = zeros(size(Fx));
    approx_frict_z = zeros(size(Fx));
    dot_x = zeros(size(Fx));
    dot_y = zeros(size(Fy));
    dot_z = zeros(size(Fz));
    dot_full = zeros(size(Fz));
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
        dot_x(i) = dot([U(i) 0 0] , [Fx(i) 0 0]);
        dot_y(i) = dot([0 V(i) 0] , [0 Fy(i) 0]);
        dot_z(i) = dot([0 0 W(i)] , [0 0 Fz(i)]);
        
        % Dot-product of resultant directions
        dot_full(i) = dot(force,velocity(:,i)/norm(velocity(:,i)));
    end
    
    % % Plot normalized force directions
%     if plot_dir
%         quiver3(X,Y,Z,Fx,zeros(size(Fx)),zeros(size(Fx)),'color',[1,0.25,0],'linewidth',.25); hold on;
        quiver3(X,Y,Z,zeros(size(Fx)),Fy,zeros(size(Fx)),'color',[1,0.25,0],'linewidth',.25); hold on;
        quiver3(X,Y,Z,zeros(size(Fz)),zeros(size(Fz)),Fz,'color',[1,0.25,0],'linewidth',.25);
%     end
    xlabel('x','Interpreter', 'LaTex')
    ylabel('y','Interpreter', 'LaTex')
    zlabel('z','Interpreter', 'LaTex')
%     title('Phases','Interpreter', 'LaTex', 'FontSize',20)
    grid on;
    
    % Plot Approx Friction Coefficient
%     if exist('h2','var') && isvalid(h2), delete(h2);end
    h2 = figure('Color',[1 1 1]);
    subplot(4,1,1)
    stairs(phases(1:sample:end), 'LineWidth',2);
    title('Phases','Interpreter', 'LaTex', 'FontSize',20)
    grid on;
    
    subplot(4,1,2)
    plot(approx_frict_x, 'LineWidth',2); hold on;
    plot(approx_frict_y, 'LineWidth',2); hold on;
    plot(approx_frict_z, 'LineWidth',2);
    ylim([0 2])
    legend({'$f_n = f_x$','$f_n = f_y$','$f_n = f_z$'},'Interpreter','LaTex')
    plot(ones(length(approx_frict_x)), 'LineWidth',2, 'Color', [0 0 0]); hold on;
    title('Approximate Friction $\tilde{\mu} = (f_{t_1}^2+f_{t_1}^2)^{(-1/2)}/f_n$','Interpreter', 'LaTex', 'FontSize',20)
    grid on;
    
    subplot(4,1,3)
    plot(dot_x, 'LineWidth',2); hold on;
    plot(dot_y, 'LineWidth',2); hold on;
    plot(dot_z, 'LineWidth',2); hold on;
    % plot(dot_full, 'LineWidth',2,'Color', [0 0 0]);
    legend({'$f_{x} \cdot v_{x}$','$f_{y} \cdot v_{y}$','$f_{z} \cdot v_{z}$','$f \cdot v$'},'Interpreter', 'LaTex')
    title('Force-Velocity Dot Products','Interpreter', 'LaTex', 'FontSize',20)
    grid on;
    
    subplot(4,1,4)
    plot(forces', 'LineWidth',2);
    legend({'$f_x$','$f_y$','$f_z$'},'Interpreter','LaTex')
    grid on;
end

%% Visualize impedance features as 3D
% 2D Toy Data
transition = 559;
contact    = 1383;
final      = 6350;

% Peeling Data
transitions = 33;
contacts    = 80;
leaves_contact = 164;

% Sanding Data
% transition = 218;
% contact    = 277;
% leaves_contact = 449;


figure('Color',[1 1 1])
phases_ = phases(1:sample:end);
phase_ids = unique(phases);
colors = rand(length(unique(phases)),3);

for i=1:length(unique(phases))
scatter3(X(phases_==phase_ids(i),1),Y(phases_==phase_ids(i),1),Z(phases_==phase_ids(i),1), 10,colors(i,:), 'filled'); hold on;
end

scatter3(X(1,1),         Y(1,1),          Z(1,1), 50,[0 1 0], 'filled'); hold on;
scatter3(X(end,1),       Y(end, 1),       Z(end,1), 50,[1 0 0], 'filled'); hold on;
scatter3(X(transition,1),Y(transition,1), Z(transition,1), 50,[0 0 1], 'filled'); hold on;
scatter3(X(contact,1),   Y(contact,1),    Z(contact,1), 50,[0 0 0], 'filled'); hold on;
scatter3(X(leaves_contact,1),   Y(leaves_contact,1),    Z(leaves_contact,1), 50,[0 1 1], 'filled'); hold on;
legend('Phase-1','Phase-2','Phase-3', 'Start', 'End','Transition','Contact','Leaves Contact')

grid on;
xlabel({'$f_{x} \cdot v_{x}$'},'Interpreter', 'LaTex')
ylabel({'$f_{y} \cdot v_{y}$'},'Interpreter', 'LaTex')
zlabel({'$f_{z} \cdot v_{z}$'},'Interpreter', 'LaTex')
title('Original Space','Interpreter', 'LaTex')

figure('Color',[1 1 1]);
for i=1:length(unique(phases))
scatter3(dot_x(phases_==phase_ids(i),1),dot_y(phases_==phase_ids(i),1),dot_z(phases_==phase_ids(i),1), 10,colors(i,:), 'filled'); hold on;
end

scatter3(dot_x(1,1),dot_y(1,1),dot_z(1,1), 50,[0 1 0], 'filled'); hold on;
scatter3(dot_x(end,1),dot_y(end,1),dot_z(end,1), 50,[1 0 0], 'filled'); hold on;
scatter3(dot_x(transition,1),dot_y(transition,1),dot_z(transition,1), 50,[0 0 1], 'filled'); hold on;
scatter3(dot_x(contact,1),dot_y(contact,1),dot_z(contact,1), 50,[0 0 0], 'filled'); hold on;
scatter3(dot_x(leaves_contact,1),  dot_y(leaves_contact,1),    dot_z(leaves_contact,1), 50,[0 1 1], 'filled'); hold on;
legend('Phase-1','Phase-2','Phase-3', 'Start', 'End','Transition','Contact','Leaves Contact')

% legend('Phase-1','Phase-2', 'Start', 'End','Transition','Contact')
grid on;
xlabel({'$f_{x} \cdot v_{x}$'},'Interpreter', 'LaTex')
ylabel({'$f_{y} \cdot v_{y}$'},'Interpreter', 'LaTex')
zlabel({'$f_{z} \cdot v_{z}$'},'Interpreter', 'LaTex')
title('Impedance Feature Space','Interpreter', 'LaTex')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%            3)  Apply Kernel PCA on Dataset                 %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3a) Compute kernel PCA of Dataset and Check Eigenvalues

X_ = [dot_x, dot_y, dot_z];
% X_ = [X, Y, Z];
%% My Datasets
X_ = [X, Z];
% X_ = [dot_x, dot_z];
labels = phases_;
plot_options            = [];
plot_options.is_eig     = false;
plot_options.labels     = labels;
plot_options.title      = 'Transitioning Dataset';
plot_options.points_size = 50;

if exist('h1','var') && isvalid(h1), delete(h1);end
h1 = ml_plot_data(X_, plot_options);
axis normal

%% Compute kPCA with ML_toolbox
options = [];
options.method_name       = 'KPCA';  % Choosing kernel-PCA method
options.nbDimensions      = 8;       % Number of Eigenvectors to keep.
options.kernel            = 'poly'; % Type of Kernel: {'poly', 'gauss'}
options.kpar              = [0 2];   % Variance for the RBF Kernel
                                     % For 'poly' kpar = [offset degree]
options.norm_K            = true;    % Normalize the Gram Matrix                                 
[kpca_X, mappingkPCA]     = ml_projection(X_,options);

% Extract Eigenvectors and Eigenvalues
V     = real(mappingkPCA.V);
K     = mappingkPCA.K;
L     = real(mappingkPCA.L);

% Plot EigenValues to try to find the optimal "p"
if exist('h3a','var') && isvalid(h3a), delete(h3a);end
h3a = ml_plot_eigenvalues(diag(L));

%% 3b) Choose p, Compute Mapping Function and Visualize Embedded Points 
% Chosen Number of Eigenvectors to keep
p = 4;

% Compute square root of eigenvalues matrix L
sqrtL = real(diag(sqrt(L)));

% Compute inverse of square root of eigenvalues matrix L
invsqrtL = diag(1 ./ diag(sqrtL));

% Compute the new embedded points
% y = 1/lambda * sum(alpha)'s * Kernel (non-linear projection)
% y = sqrtL(1:p,1:p) * V(:,1:p)' = invsqrtL(1:p,1:p) * V(:,1:p)' * K;
y = sqrtL(1:p,1:p) * V(:,1:p)';

% Plot result of Kernel PCA
if exist('h3','var') && isvalid(h3), delete(h3);end
plot_options              = [];
plot_options.is_eig       = false;
plot_options.labels       = phases_;
plot_options.points_size  = 10;
plot_options.plot_labels  = {'$y_1$','$y_2$','$y_3$'};
plot_options.title        = 'Projected data with kernel PCA';
if exist('h3b','var') && isvalid(h3b), delete(h3b);end
h3b = ml_plot_data(y',plot_options); hold on;
scatter3(y(1,1),y(2,1),y(3,1), 100,[0 1 0], 'filled'); hold on;
scatter3(y(1,end),y(2,end),y(3,end),100,[1 0 0], 'filled'); hold on;
scatter3(y(1,transition),y(2,transition),y(3,transition), 100,[0 0 1], 'filled'); hold on;
scatter3(y(1,contact),y(2,contact),y(3,contact), 100,[0 0 0], 'filled'); hold on;

%% 3c) Plot Isolines of EigenVectors
iso_plot_options                    = [];
iso_plot_options.xtrain_dim         = [1 2];   % Dimensions of the orignal data to consider when computing the gramm matrix (since we are doing 2D plots, original data might be of higher dimension)
iso_plot_options.eigen_idx          = [1:4];   % Eigenvectors to use.
iso_plot_options.b_plot_data        = true;    % Plot the training data on top of the isolines 
iso_plot_options.labels             = phases_;  % Plotted data will be colored according to class label
iso_plot_options.b_plot_colorbar    = true;   % Plot the colorbar.
iso_plot_options.b_plot_surf        = true;   % Plot the isolines as (3d) surface 

% Construct Kernel Data
kernel_data                         = [];
kernel_data.alphas                  = V;
kernel_data.kernel                  = mappingkPCA.kernel;
kernel_data.kpar                    = [mappingkPCA.param1,mappingkPCA.param2];
kernel_data.xtrain                  = X_;
kernel_data.eigen_values            = L;

% if exist('h_isoline','var') && isvalid(h_isoline), delete(h_isoline);end
[h_isoline,h_eig] = ml_plot_isolines(iso_plot_options,kernel_data);