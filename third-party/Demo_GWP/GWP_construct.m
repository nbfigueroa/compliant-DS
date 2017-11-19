function [T]=GWP_construct(u,L,v)

[I,D]=size(L);
N_u=length(u{1,1});
tam_grid=sqrt(N_u);

T=zeros(D,D,tam_grid,tam_grid);
con=1;
for i=1:tam_grid
    for j=1:tam_grid
        matriz=zeros(D);
        for k=1:v
            u_gorro=[u{k,1}(con);u{k,2}(con);u{k,3}(con)];
            matriz=matriz+(L*(u_gorro*u_gorro')*L');
        end
    con=con+1;
    T(:,:,i,j)=matriz;
    end
end
