function [h] = plot_mixing_fct_2d(limits, mix_handle, target)
nx = 400; ny = 400;
axlim = limits;
ax_x=linspace(axlim(1),axlim(2),nx); %computing the mesh points along each axis
ax_y=linspace(axlim(3),axlim(4),ny); %computing the mesh points along each axis
[x_tmp, y_tmp]=meshgrid(ax_x,ax_y); %meshing the input domain
x=[x_tmp(:), y_tmp(:)]';

[ys2] = feval(mix_handle,-vecnorm(x-target));
z_tmp = reshape(ys2,nx,ny);
h = pcolor(x_tmp,y_tmp,reshape(ys2,nx,ny));

set(h,'linestyle','none');
load whiteCopperColorMap;
colormap(flipud(cm));
colorbar;
caxis([min(min(z_tmp)), max(max(z_tmp))]);
end