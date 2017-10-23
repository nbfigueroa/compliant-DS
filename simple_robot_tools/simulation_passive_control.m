function [hd, ht] = simulation_passive_control(fig, robot, base, reshaped_ds, target, q, dt)
handle(fig)
t = 0;
qd = [0,0];
hd = [];
ht = [];

global pertForce;
pertForce = [0;0];

% % Perturb in X direction      
% pertbFx_btn = uicontrol('style','pushbutton','String', 'Perturb F_x','Callback',@startPerturbation_Fx, ...
%   'position',[0 0 110 25], ...
%   'UserData', 1);
% 
% % Perturb in Y direction      
% pertbFy_btn = uicontrol('style','pushbutton','String', 'Perturb F_y','Callback',@startPerturbation_Fy, ...
%   'position',[125 0 110 25], ...
%   'UserData', 1);

% Variable for Plotting Damping Matrix
i = 1;
mod_step = 10;
color = [ 0.6 0.4 0.6 ];

while(1)
    % Set perturbations with the mouse
    set(gcf,'WindowButtonDownFcn',@startPerturbation);
    
    % compute state of end-effector
    x = robot.fkine(q);
    x = x(1:2,4); 
    xd = robot.jacob0(q)*qd';    
    xd = xd(1:2) ;  
    
    %reference_vel(t);
    xd_ref = reshaped_ds(x-target);
    
    % put lower bound on speed, just to speed up simulation
    th = 1.0;
    if(norm(xd_ref)<th)
        xd_ref = xd_ref/norm(xd_ref)*th;
    end
    xdd_ref = -(xd - xd_ref)/dt*0.5;
    
    % Compute Damping Matrix
    Q = findDampingBasis(xd_ref);
%     L = [8 0;0 2];     % inverse
%     L = [2 0;0 8];   % icra-lfd-tutorial
    L = [1 0;0 2];   % icra-lfd-tutorial
%     L = [5 0;0 25];  % klas's thesis
    D = Q*L*Q';
    
    % Plot Damping Matrix
    if (i == 1) || (mod(i,mod_step) == 0)
        D_scaled = Q*(0.01*L)*Q';
        hd = [hd, ml_plot_gmm_contour(gca,1,x,D_scaled,color,1)];
    end
    
    % Compute Cartesian Control    
    u_cart = - D*(xd-xd_ref);
    
    % feedforward term
    u_cart = u_cart + simple_robot_cart_inertia(robot,q)*xdd_ref;       
    
    % external perturbations with the mouse
    u_cart = u_cart + pertForce;
    
    % compute joint space control
    u_joint = robot.jacob0(q)'*[u_cart;zeros(4,1)];
    
    % apply control to the robot
    qdd = robot.accel(q,qd,u_joint')';
    
    % integrate one time step
    qd = qd+dt*qdd;
    q = q+qd*dt+qdd/2*dt^2;
    t = t+dt;
    if (norm(x - target)<0.1)
        break
    end
    robot.delay = dt;
    robot.animate(q);
  
    i = i + 1;
    ht = [ht, plot(x(1), x(2), 'm.', 'markersize',20)];

end


    %% Perturbations with the mouse
    function startPerturbation(~,~)
        motionData = [];
        set(gcf,'WindowButtonMotionFcn',@perturbationFromMouse);
        x_p = get(gca,'Currentpoint');
        x_p = x_p(1,1:2)';
        hand = plot(x_p(1),x_p(2),'r.','markersize',20);
        hand2 = plot(x_p(1),x_p(2),'r.','markersize',20);
        set(gcf,'WindowButtonUpFcn',@(h,e)stopPerturbation(h,e));

        function stopPerturbation(~,~)
            delete(hand)
            delete(hand2)
            set(gcf,'WindowButtonMotionFcn',[]);
            set(gcf,'WindowButtonUpFcn',[]);
            pertForce = [0;0];
        end


        function ret = perturbationFromMouse(~,~)
            x_p = get(gca,'Currentpoint');
            x_p = x_p(1,1:2)';
            motionData = [motionData, x_p];
            pertForce = 20*(motionData(:,end)-motionData(:,1));
            norm_pertForce = norm(pertForce)
            ret=1;
            delete(hand2)
            hand2 = plot([motionData(1,1),motionData(1,end)],[motionData(2,1),motionData(2,end)],'-r');
        end
    end
        

end
