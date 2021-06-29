function [nn, no, np, A12, A10, xo, x, d] = geometry_grid(n,m,l1,l2,id)

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
A11inv = sparse(np,np);
xo  = zeros(no,2);
x   = zeros(nn,2);

if mod(n,2) == 0;
    id_max = n/2-1;    
else
    id_max = (n-1)/2;    
end
id=id_max;

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

% In and outflow - setup A10 matrix
if id == id_max
    if mod(n,2) ~= 0
        id = id - 0.5;
    end
    
    % Adding fixed head nodes to A10 and removing unknown head nodes from A12
    % Bottom left corner
    A10(1,1) = -1;
    A10((n-1)*m+1,1) = -1;
    % Bottom right corner
    %A10((n-2)*m+1,2)  = 1;
    %A10((n-1)*m+n,2)  = -1;
    % Top left corner
    %A10((n-1)*m+(m-2)*n+1,2) = 1;
    %A10(m,2)  = -1;
    % Top right corner
    A10((n-1)*m,2) = 1;
    A10((n-1)*m+(m-1)*n,2) = 1;

    % locations of known-nodes: 
    xo(1,:) = [       0        0];
    %xo(2,:) = [(n-1)*l1        0];
    %xo(2,:) = [       0 (m-1)*l2];
    xo(2,:) = [(n-1)*l1 (m-1)*l2];

    % Remove the same node(s) from the unknown head matrix (A12) and the unknown head
    % locations matrix (x). Note: start with highest ranked nodes and work down
    % in order not to change the order of the other nodes before removing them
    % Top right corner
    A12(:,n*m)= [];
    x(n*m,:)  = [];
    % Top left corner
    %A12(:,(m-1)*n+1) = [];
    %x((m-1)*n+1,:)   = [];
    % Bottom right corner
    %A12(:,n)  = [];
    %x(n,:)    = [];
    % Bottom left corner
    A12(:,1)  = [];
    x(1,:)    = [];

    % Output pipes for later reference
    p_output = zeros(2,1);
    %p_output(1,1) = m;
    %p_output(2,1) = (n-1)*m+(m-2)*n+1;
    p_output(1,1) = (n-1)*m;
    p_output(2,1) = (n-1)*m+(m-1)*n;
else
    % Set flows next to each other in middle so that system is symmetrical
    % with distance from origin 'id'
    % if 'n' is even id>=1, if 'n' is uneven start with id=0.5 and only add
    % full integers so that the next id=1.5 and the next id=2.5
    % id is defined in the for loop in ensemble_run, here it is made robust
    % for even and uneven 'n'
    if mod(n,2) ~= 0
        id = id - 0.5;
    end

    % Left bottom inflow
    A10((n-2)/2*m-(id+1)*m+1,1) = 1;
    A10((n-2)/2*m-id*m+1,1) = -1;
    A10((n-1)*m+n/2-id,1) = -1;
    % Right bottom inflow
    %A10((n-2)/2*m+id*m+1,2) = 1;
    %A10((n-2)/2*m+(id+1)*m+1,2) = -1;
    %A10((n-1)*m+n/2+id+1,2) = -1;
    % Left top outflow
    %A10(m*(n/2-(id+1)),2) = 1;
    %A10(m*(n/2-id),2) = -1;
    %A10((n-1)*m+(m-2)*n+n/2-id,2) = 1;
    % Right top outflow
    A10(m*(n/2+id),2) = 1;
    A10(m*(n/2+id+1),2) = -1;
    A10((n-1)*m+(m-2)*n+n/2+id+1,2) = 1;


    % Location of known-nodes:
    xo(1,:) = [(n/2-id-1)*l1        0];
    %xo(2,:) = [  (n/2+id)*l1        0];
    %xo(2,:) = [(n/2-id-1)*l1 (m-1)*l2];
    xo(2,:) = [  (n/2+id)*l1 (m-1)*l2];

    % Remove the same node(s) from the unknown head matrix (A12) and the unknown head
    % locations matrix (x). Note: start with highest ranked nodes and work down
    % in order not to change the order of the other nodes before removing them
    % Top right corner;
    A12(:,(m-1)*n+n/2+id+1) = [];
    x((m-1)*n+n/2+id+1,:) = [];
    % Top left corner;
    %A12(:,(m-1)*n+n/2-id) = [];
    %x((m-1)*n+n/2-id,:) = [];
    % Bottom right corner;
    %A12(:,n/2+id+1) = [];
    %x(n/2+id+1,:) = [];
    % Bottom left corner;
    A12(:,n/2-id) = [];
    x(n/2-id,:) = [];

    % Output pipes for later reference
    p_output = zeros(3,1);
    p_output(1,1) = m*(n/2-(id+1)); 
    p_output(2,1) = m*(n/2-id); 
    p_output(3,1) = (n-1)*m+(m-2)*n+n/2-id; 
end

% Change nn and no
nn  = nn-size(xo,1);      % nr of unknown head nodes
no  = no+size(xo,1);      % nr of fixed head nodes
np  = np;                 % nr of pipes

% pipe diameters:
d   = 4*ones(np,1);