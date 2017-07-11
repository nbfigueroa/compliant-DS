function [Data_seq True_states_seq] = load_rolling_demos( data_path, type, demos, labels)

% Load Data
switch type
    case 'aligned'
        load(strcat(data_path,'Rolling/proc-data-labeled-aligned.mat'))        
    case 'real'
        load(strcat(data_path,'Rolling/proc-data-labeled-real.mat'))
end
       
% Load label sequences
switch labels
    case 'human'
        load(strcat(data_path,'Rolling/Sequence_labels.mat'))
        
    case 'icsc-hmm'
end
% Extract rolling sequences from selected demonstrations
Data_  = Data; True_states_ = True_states;
clear Data True_states

Total_sequences = 0; j = 1;
for i=1:length(demos)
    Data{i} = Data_{i};
    True_states{i} = True_states_{i};
    Total_sequences = Total_sequences + size(Seq{demos(i)},1);
    X = Data{i}; segs = Seq{demos(i)};
    true_states = True_states{i};
    for k = 1:size(Seq{demos(i)},1)  
        ids = segs(k,1):segs(k,2);
        X_ = X(:,ids);        
        
        % Rotate around Z to get correct force directions
        for ii=1:length(X_)
            f = X_(8:10,ii);
            X_(8:10,ii) = rotz(-pi/2)*f;
%             X_(8,ii) = 0;
        end

        Data_seq{j} = X_';
        True_states_seq{j} = true_states(1,ids)';
        j = j + 1;
    end
end


end


