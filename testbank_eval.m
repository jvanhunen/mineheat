%% This program allows for the computation of water and heat flow through a mine network
%%     Copyright (C) 2022  Durham University
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%%
function testbank_eval(itestbank, H, Q, Tn, Tp, igeom)
    % Function to write or read testbank results.
    % Version 20210713 Jeroen van Hunen
    verbose = 0;
    
    filename = ['testbank/testbank_' num2str(igeom) '.mat'];
    if itestbank == -1
        savefile = filename;
        disp (['Saving testbank results to ' filename])
        Hstore = H; 
        Qstore = Q;
        Tnstore = Tn;
        Tpstore = Tp;
        save(savefile,'Hstore', 'Qstore', 'Tnstore', 'Tpstore')
    elseif itestbank == 1
        loadfile = filename;
        fprintf('   --> Tested geometry %d:', igeom)
        load(loadfile,'Hstore', 'Qstore', 'Tnstore', 'Tpstore')
        Hdiff =  H - Hstore;
        Qdiff =  Q - Qstore;
        Tndiff = Tn - Tnstore;
        Tpdiff = Tp - Tpstore;
        if (max(abs(Hdiff)) > 0 | max(abs(Qdiff)) > 0 | max(abs(Tndiff)) > 0 | max(abs(Tpdiff)) > 0)
            disp ([' failed: Differences in H, Q, Tn, and Tp:'])
            disp (['          max diff in H:' num2str(max(abs(Hdiff))) ])
            disp (['          max diff in Q:' num2str(max(abs(Qdiff))) ])
            disp (['          max diff in Tn:' num2str(max(abs(Tndiff))) ])
            disp (['          max diff in Tp:' num2str(max(max(abs(Tpdiff)))) ])
            if verbose
                Hdiff
                Qdiff
                Tndiff
                Tpdiff
            end
        else
            disp (' passed')
        end
    end
end