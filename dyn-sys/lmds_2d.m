function [vel] = lmds_2d(original_dynamics, exp_funct, mod_type, query_pos)

% Compute original dynamics at query points
vel     = feval(original_dynamics, query_pos);
dim     = size(vel,1);
samples = size(vel,2);

% Compute Activation Values
h_x     = feval(exp_funct, query_pos');
switch mod_type   
    case 'rand'
        display('Modulating Dynamics through Random Matrices');
        % Compute Random Modulation matrix
        [A,~]   = qr(rand(dim,dim)); % random orthonormal matrices           
        % and modulate
        vel = locally_modulate_2d(vel, h_x', A);
        
    case 'rot'
        display('Modulating Dynamics through Local Rotation');
        % Compute Random Rotation Angle phi_c
        a = 0; b = 3.14159;
        phi_c = a+(b-a)*rand(1,1);
        % and modulate
        vel = locally_rotate_2d(vel, h_x', phi_c);
end

end