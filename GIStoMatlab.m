% JMC a class which is used to convert indices from GIS nodes to internal
% Matlab code. This is required to be able to be able to set any node as a
% fixed head node. And/or set the last node as a injection/abstraction
% node.
classdef GIStoMatlab

   methods (Static)
       function out = nestedFunctionCall(x, varargin)
            out = x(varargin{:});
       end

       function out = indicesNNNO(varargin)
         persistent Var;
         if length(varargin) == 0
             out = Var;
             return;
         end
         if varargin{1} == "init"
            Var = [1:varargin{2}+varargin{3}];
         elseif varargin{1} == "set"
             if varargin{2} > length(Var) || varargin{3} > length(Var)
                       error("Index passed as argument, exceeds the total amount of nodes nn+no. Hence cannot be swapped. Make sure both arguments are in nn+no range.")
             end   
            tempA = find(Var == varargin{3}); % location of the value to be fetched
            tempB = Var(varargin{2}); % value at the location to be replaced
            Var(varargin{2}) = varargin{3};
            Var(tempA) = tempB; % replacing the value at the fetch location with the value that was at the replaced location
         elseif varargin{1} == "get" && length(varargin) > 1
            out = GIStoMatlab.nestedFunctionCall(Var, varargin{2:end});
         else
            out = Var;
         end
       end

       function out = indicesNO(varargin)
         persistent Var;
         if length(varargin) == 0
             out = Var;
             return;
         end
         if varargin{1} == "init"
            Var = [1:varargin{2}];
         elseif varargin{1} == "set"
            if varargin{2} > length(Var) || varargin{3} > length(Var)
                       error("Index passed as argument, exceeds the total amount of nodes nn+no. Hence cannot be swapped. Make sure both arguments are in nn+no range.")
            end   
            tempA = find(Var == varargin{3}); % location of the value to be fetched
            tempB = Var(varargin{2}); % value at the location to be replaced
            Var(varargin{2}) = varargin{3};
            Var(tempA) = tempB; % replacing the value at the fetch location with the value that was at the replaced location
         elseif varargin{1} == "get" && length(varargin) > 1
            out = GIStoMatlab.nestedFunctionCall(Var, varargin{2:end});
         else
            out = Var;
         end
       end

       function out = indicesNN(varargin)
         persistent Var;
         if length(varargin) == 0
             out = Var;
             return;
         end
         if varargin{1} == "init"
            Var = [1:varargin{2}];
         elseif varargin{1} == "set"
             if varargin{2} > length(Var) || varargin{3} > length(Var)
                       error("Index passed as argument, exceeds the total amount of nodes nn+no. Hence cannot be swapped. Make sure both arguments are in nn+no range.")
             end    
            tempA = find(Var == varargin{3}); % location of the value to be fetched
            tempB = Var(varargin{2}); % value at the location to be replaced
            Var(varargin{2}) = varargin{3};
            Var(tempA) = tempB; % replacing the value at the fetch location with the value that was at the replaced location
         elseif varargin{1} == "get" && length(varargin) > 1
            out = GIStoMatlab.nestedFunctionCall(Var, varargin{2:end});
         else
            out = Var;
         end
       end

       function setUpIndicesMaps(nn,no)
         GIStoMatlab.indicesNNNO("init",nn,no);
         GIStoMatlab.indicesNO("init",no);
         GIStoMatlab.indicesNN("init",nn);
       end
   end

end