function h = my_LyapFun2D( nFig, lyapunov, mapping, limits)
%PLOTLYAPFUN Summary of this function goes here
%   Detailed explanation goes here

if iscell(nFig)
    figure(nFig{1}); hold all;
    %set(gcf(), 'CurrentHandle', nFig{2})
    axes(nFig{2});
else
    figure(nFig); hold all;
end
axisOld = axis();
if nargin <= 2 || isempty(limits)
    limits = axis();
end

nx = 400; ny = 400;
axlim = limits;
ax_x=linspace(axlim(1),axlim(2),nx); %computing the mesh points along each axis
ax_y=linspace(axlim(3),axlim(4),ny); %computing the mesh points along each axis
[x_tmp, y_tmp]=meshgrid(ax_x,ax_y); %meshing the input domain
x=[x_tmp(:), y_tmp(:)]';

[ys2] = feval(lyapunov,feval(mapping,x));
z_tmp = reshape(ys2,nx,ny);

% Plot the Lyapunov Function Contours
level = 100; n = ceil(level/2);
cmap1 = [linspace(1, 1, n); linspace(0, 1, n); linspace(0, 1, n)]';
cmap2 = [linspace(1, 0, n); linspace(1, 0, n); linspace(1, 1, n)]';
cmap =  [cmap1; cmap2(2:end, :)];

h = contourf(x_tmp,y_tmp,reshape(ys2,nx,ny),20,'LineWidth', 0.001);
colormap(vivid(cmap, [.7, .7]));
colorbar



end
