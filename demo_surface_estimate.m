%% 1) 2D Simulated Dataset from Sina's CODS Toolbox


%% 2) Real 'Dough-Rolling' 12D dataset, 3 Unique Emission models, 12 time-series
% Demonstration of a Dough Rolling Task consisting of 
% 15 (13-d) time-series X = {x_1,..,x_T} with variable length T. 
clc; clear all; close all;
data_path = './test-data/'; display = 1; type = 'aligned'; % 'aligned'/'rotated'
dataset_name = 'Rolling'; full = 0; % 

% Define if using first derivative of pos/orient
[Data, True_states] = load_rolling_demos( data_path, type, display, full);

%% Position to Velocities
% Convert positions to velocities
if ~isempty(varargin)
    if varargin{2}==1
        for i=1:length(Data)
            clear X3d            
            X3d(1:3,:) = Data{i}(1:3,:);
            X3d_dot = [zeros(3,1) diff(X3d')'];
            % Smoothed out with savitksy golay filter
            X3d_dot = 100*sgolayfilt(X3d_dot', 3, 151)';
            Data{i}(1:3,:) = X3d_dot;
        end
    end
end      

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

%% Extract most likely sequence
Trans_M = eye(3);
seq_1 = True_states{1};
figure('Color',[1 1 1]);
stairs(1:length(seq_1),seq_1, 'LineWidth',3);
grid on;
xlabel('Time steps');ylabel('state')
xlim([1 length(seq_1)])

% Unique labels
string_seq1 = [];
string_seq1 = [string_seq1 seq_1(1)]; j = 1;
for i=2:length(seq_1)
    if string_seq1(j) ~= seq_1(i)
        string_seq1 = [string_seq1 seq_1(i)];
        j = j +1 ;
    end
end

% Compute 'Binary' Correlation Matrix
M = zeros(length(string_seq1),length(string_seq1));
for i=1:length(string_seq1)
    for j=1:length(string_seq1)
        if string_seq1(i) == string_seq1(j)
            M(i,j) = 1;
        end
    end
end
figure('Color',[1 1 1])
imagesc(M);
colormap bone

%% Plot Segmentated 3D Trajectories
titlename = strcat(dataset_name,' Demonstrations (Ground Truth)');
if exist('h7','var') && isvalid(h7), delete(h7);end
h7 = plotLabeled3DTrajectories(Data, True_states, titlename, unique(data.zTrueAll));
axis tight

