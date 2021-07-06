function [nn, no, np, A12, A10, xo, x, d] = geometry103(n,m,l1,l2,id)

% with: 
%   - = pip
%   o = unknown head node
%   * = fixed head node
% 
% size of problem:
% n, m, l1 & l2 are imported from ensemble run
% n      % grid width (number of nodes wide)
% m      % grid height (number of nodes high)
% l1     % length of horizontal pipes
% l2     % length of vertical pipes

nn  = n*m;     % nr of unknown head nodes
no  = 0;       % nr of fixed head nodes
np  = (n-1)*m + (m-1)*n;     % nr of pipes

% Parameters to be solved in this function:
A12 = sparse(np,nn);
A10 = sparse(np,no);
xo  = zeros(no,2);
x   = zeros(nn,2);

% locations of boundary unknown-nodes:
for in = 1:n*m
    x(in,:) = [((in-1)-floor((in-1)/n)*n)*l1 floor((in-1)/n)*l2];
    if in==1 % corner1 - check
        A12(1,in) = -1;
        A12((n-1)*m+1,in) = -1;
    elseif in==n % corner2 - check
        A12((n-2)*m+1,in) = 1;
        A12((n-1)*m+n,in) = -1;
    elseif in==(m-1)*n+1 % corner3 - check
        A12((n-1)*m+(m-2)*n+1,in) = 1;
        A12(m,in) = -1;
    elseif in==n*m % corner4 - check
        A12((n-1)*m,in) = 1;
        A12((n-1)*m+(m-1)*n,in) = 1;
    elseif in>=2 && in<=n-1 % bottom boundary of grid - check
        A12((in-2)*m+1,in) = 1;
        A12((n-1)*m+in,in) = -1;
        A12((in-1)*m+1,in) = -1;
    elseif (in/n)>1 && (in/n)<m-1 && mod(in-1,n)==0 % left boundary of grid - check
        A12(in-1+(n-1)*(m-1),in) = 1;
        A12((in-1)/n+1,in) = -1;
        A12(in-1+n+(n-1)*(m-1),in) = -1;
    elseif (in/n)>1 && (in/n)<=m-1 && mod(in,n)==0% right boundary of grid - check
        A12(in-n+(n-1)*m,in) = 1; 
        A12(in/n+(n-2)*m,in) = 1;
        A12(in+(n-1)*m,in) = -1;
    elseif in>(m-1)*n+1 && in<m*n % top boundary of grid - 
        A12((in-(m-1)*n-1)*m,in) = 1;
        A12((n-1)*m+in-n,in) = 1;
        A12((in-(m-1)*n)*m,in) = -1;
    else % the middle of grid -  
        A12((n-1)*m+in-n,in) = 1;
        A12((in-floor(in/n)*n-2)*m+floor(in/n)+1,in) = 1;
        A12((in-floor(in/n)*n-2)*m+floor(in/n)+m+1,in) = -1;
        A12((n-1)*m+in,in) = -1;
    end
end

% Top right corner
A10((n-1)*m,1) = 1;
A10((n-1)*m+(m-1)*n,1) = 1;

% locations of known-nodes: 
xo(1,:) = [(n-1)*l1 (m-1)*l2];
no=1;
nn=nn-1;
A12(:,n*m)= [];
x(n*m,:)  = [];
% x
% xo
% A12
% A10
% size(A12)

% pipe diameters:
d   = 2*ones(np,1);