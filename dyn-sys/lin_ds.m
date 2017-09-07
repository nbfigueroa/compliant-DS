function [x_dot] = lin_ds(b,x,type)
switch type
    case 1
    % Linear DS converging to a target
    A = -[10 0;0 10];
    
    case 2
    % Linear DS diverging from a target
    A = [10 0;0 10];
    
    case 3
    % Linear DS on x
    A = [10 0;0 0];
    
    case 4
    % Linear DS on y
    A = [0 0;0 -10];
    
    case 5
    % Linear DS diagonal
    A = [10 0;0 -10];
    
    case 6
    % Linear DS diagonal target 1
    A = [0 -1;1 -2];
    
    case 7
    % Linear DS diagonal target 2
    A = [0 1;-1 -2];    
    
    case 8
    % Linear DS diagonal target 2
    A = [0 -1; 1 -2];    
    
    case 9
    % Linear DS diagonal target 2
    A = [0 1; -1 -2];    
    
end
if isempty(b)
    x_dot = A*x;
else
    x_dot = A*x + repmat(b,[1 length(x)]);
end
end