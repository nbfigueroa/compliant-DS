% This program generates a three-arm spiral. 
% 
% By Yixiang Huang, School of Mechanical Engineering, 
%                   Shanghai Jiao Tong University
% Email: huang.yixiang@sjtu.edu.cn with comments & questions
% Last modified on Feb.28,2015
%

clear

num_arm=1200; % The number of data point on each arm
num_cen=num_arm/10;  % Skip some points near the center
arm=num_arm-num_cen+1; 
arm2=2*arm;
intv=pi/num_arm;
x=[num_cen*intv:intv:pi]; clear intv      
y1=[x.*sin(x); x.*cos(x)]; y1=y1'; clear x   
ang=6*pi/5;
mang=[sin(ang) cos(ang); -cos(ang) sin(ang)]; clear ang
y2=y1*mang;
y3=y2*mang;
clear mang

k=0.6; % noise scale 
n=rand(size(y1))*k;
y1=y1+n;
n=rand(size(y2))*k;
y2=y2+n;
n=rand(size(y3))*k; clear k
y3=y3+n;  clear n

y=[y1;y2;y3];
tmp=y(:,1).*y(:,2);
dat=[y tmp]; 
clear tmp y1 y2 y3 y

% build the lab vector
pool=[arm arm arm]; % three equal arms
lab=[];
for i=1:length(pool)
    tmp=repmat(i,pool(i),1); 
    lab=[lab; tmp];
end
clear i tmp num_arm num_cen pool
 
% plot3(dat(1:arm,1),dat(1:arm,2),dat(1:arm,3),'b.');hold on
% plot3(dat(arm+1:arm2,1),dat(arm+1:arm2,2),dat(arm+1:arm2,3),'g+');
% plot3(dat(arm2+1:end,1),dat(arm2+1:end,2),dat(arm2+1:end,3),'r^');hold off;
% grid on

