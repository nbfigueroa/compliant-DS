function [err]=frob_error(M,Dat)

con=1;
[x,y,I,tam_grid]=size(M);
for i=1:tam_grid
    for j=1:tam_grid
    err(con)=sqrt(trace((M(:,:,i,j)-Dat(:,:,i,j))*(M(:,:,i,j)-Dat(:,:,i,j))')); 
    con=con+1;
    end
end