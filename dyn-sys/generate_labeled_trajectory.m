function [data_labels, trans_points] = generate_labeled_trajectory(Data, transitions, start)

% Get transition points and labeled data
ds_labels = ones(1,length(transitions)+1);
switch start
    case 'converging'
    scale_label = 1;
    case 'tracking'
    scale_label = -1;
end
trans_points = [];   % Desired transition points
for t=1:length(transitions)
    trans_points = [trans_points Data(1:2,1)*transitions(t)] ;  % Set desired transition point to mid-point
    ds_labels(t) = scale_label*ds_labels(t);
    scale_label = -scale_label;
end    
ds_labels(end) = -ds_labels(end-1)

data_labels = zeros(1,length(Data));
trans_points = [Data(1:2,1) trans_points Data(1:2,end)];
for i =1:length(Data(1:2,:))
    curr_point = Data(1:2,i);   
    for t = 2:length(trans_points)
        start_trans = trans_points(:,t-1);
        end_trans   = trans_points(:,t);        
        if  (norm(curr_point) >= norm(end_trans)) && (norm(curr_point) <= norm(start_trans))
            data_labels(1,i) = ds_labels(t-1);
        end        
    end
end

end