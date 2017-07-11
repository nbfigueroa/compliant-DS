function [Data_seq True_states_seq] = load_peeling_demos( data_path, demos, labels)

% Load All Time-Series Data and Labels
load(strcat(data_path,'Peeling/proc-data-labeled.mat'))
load(strcat(data_path,'Peeling/proc-labels.mat'))
load(strcat(data_path,'Peeling/proc-data-noObj.mat'))
Data{4} = Data_noObj{1}; True_states{4} = True_states_noObj{1};
Data{5} = Data_noObj{2}; True_states{5} = True_states_noObj{2};


% Load label sequences
switch labels
    case 'human'
        load(strcat(data_path,'Peeling/Sequence_labels.mat'))
        
    case 'icsc-hmm'
end

% Extract peeling sequences from selected demonstrations
Data_  = Data; True_states_ = True_states;
clear Data True_states
Total_sequences = 0; j = 1;

for i=1:length(demos)
    Data{i} = Data_{i}(1:13,:)';
    True_states{i} = True_states_{i}';
    Total_sequences = Total_sequences + size(Seq{demos(i)},1);
    X = Data{i}; segs = Seq{demos(i)};    
    true_states = True_states{i};
    for k = 1:size(Seq{demos(i)},1)  
        ids = segs(k,1):segs(k,2);                
        X_ = X(ids,:);        
        
        % Rotate around X to get correct force directions
        for ii=1:length(X_)
            f = X_(ii,8:10)';            
            X_(ii,8:10) = [rotx(pi)*f]';
        end
        Data_seq{j} = X_;        
        True_states_seq{j} = true_states(ids);
        j = j + 1;
    end
end

end


