function [x_dot] = lin_compliant_ds(b,x,mix_type,xi_0, param)


% A_c converging Linear DS 
A_c = -[5 0;0 5];

% A_t tracking Linear DS 
y1 = 1;
y2 = -xi_0(1)/xi_0(2);
y = [y1;y2];
Q = [y./norm(y),xi_0./norm(xi_0)];
L = [-10 0 ; 0 -1];
A_t = Q*L*Q';

% output velocity
x_dot = zeros(size(x));
switch mix_type
    case 1
       alpha = param;
       x_dot = (alpha*A_c + (1-alpha)*A_t)*x;
    case 2
        log_x = - vecnorm(x - b);
        alpha = feval(param,log_x);        
        for i = 1:size(x,2)
            x_dot(:,i) = (alpha(i)*A_c + (1-alpha(i))*A_t)*x(:,i);
        end 
        
    case 3
        alpha = feval(param,x')';
        for i = 1:size(x,2)
            x_dot(:,i) = (alpha(i)*A_c + (1-alpha(i))*A_t)*x(:,i);
        end 
end


end