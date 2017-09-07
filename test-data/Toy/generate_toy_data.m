load('Toy_Data.mat')
openfig('Toy_simulation.fig')

for i=1:length(X_modulated)
    Data{i} = [X_modulated{i}(1,1:10:end); zeros(size(X_modulated{i}(1,1:10:end))); X_modulated{i}(2,1:10:end); zeros(4,length(X_modulated{i}(1,1:10:end))); ...        
        -0.85*F_modulated{i}(2,1:10:end); 0.25*F_modulated{i}(2,1:10:end);  F_modulated{i}(2,1:10:end)]';    
    True_states{i} = 2*ones(1,length(Data{i}))';
    for k=1:length(Data{i})
        if Data{i}(k,10) == 0 
            True_states{i}(k,1) = 1;    
            Data{i}(k,8:10) = -0.5*Data{i}(k,1:3);
        end
    end    
end