function [Data True_states] = load_rolling_demos( data_path, type, display, full)

label_range = [1 2 3];
        
switch type
    case 'aligned'
        load(strcat(data_path,'Rolling/proc-data-labeled-aligned.mat'))
    case 'real'
        load(strcat(data_path,'Rolling/proc-data-labeled-real.mat'))
end
       

if full == 1 % Load the 15 time-series
    
    if display == 1
        ts = [1:5];
        figure('Color',[1 1 1])
        for i=1:length(ts)
            X = Data{ts(i)};
            true_states = True_states{ts(i)};
            
            % Plot time-series with true labels
            subplot(length(ts),1,i);
            data_labeled = [X ; true_states];
            plotLabeledData( data_labeled, [], strcat('Time-Series (', num2str(ts(i)),') with true labels'), [], label_range)
        end
        
        
        figure('Color',[1 1 1])
        ts = [6:10];
        for i=1:length(ts)
            X = Data{ts(i)};
            true_states = True_states{ts(i)};
            
            % Plot time-series with true labels
            subplot(length(ts),1,i);
            data_labeled = [X ; true_states];
            plotLabeledData( data_labeled, [], strcat('Time-Series (', num2str(ts(i)),') with true labels'), [], label_range)
        end
        
        figure('Color',[1 1 1])
        ts = [11:15];
        for i=1:length(ts)
            X = Data{ts(i)};
            true_states = True_states{ts(i)};
            
            % Plot time-series with true labels
            subplot(length(ts),1,i);
            data_labeled = [X ; true_states];
            plotLabeledData( data_labeled, [], strcat('Time-Series (', num2str(ts(i)),') with true labels'), [], label_range)
        end
    end
else % Load 5 time-series

    Data_ = Data; True_states_ = True_states;
    clear Data True_states
    iter = 1;
%     for i=1:2:12
    for i=2:2:10
        Data{iter} = Data_{i};
        True_states{iter} = True_states_{i};
        iter = iter + 1;
    end
    
    if display == 1
        ts = [1:length(Data)];
        figure('Color',[1 1 1])
        for i=1:length(ts)
            X = Data{ts(i)};
            true_states = True_states{ts(i)};
            
            % Plot time-series with true labels
            subplot(length(ts),1,i);
            data_labeled = [X ; true_states];
            plotLabeledData( data_labeled, [], strcat('Time-Series (', num2str(ts(i)),') with true labels'), [], label_range)
        end
    end
    
end


end


