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
function [K poro] = material_properties(case_mp, nn, no, np, x, xo, pipe_nodes, xtotal, q_in, q_out)
    switch case_mp
        % A test case for all open pipes.
        case 1
            K = 0; % this will not be used for open pipes anyway
            poro = 1; % completely open pipes
            poro = zeros(np,1) + poro;

        % A test case which applies a uniform hydraulic conductivity to the
        % entire set of pipes. porosity is also set to an arbitrary value.
        case 2
            K = 3.e-2;
            K = zeros(np,1) + K;
            
            poro = 0.1;
            poro = zeros(np,1) + poro;

        % A test mixed case where perlin noise is used to apply porosity to
        % the model. K remains constant.
        case 3
            open_th = 0.5;%78; % threshold above with the pipes are considered open

            K = 3.e-2;
            K = zeros(np,1) + K;

            % creating perlin noise map
            n = 100; % resolution x
            m = 100; % resolution y
            im = zeros(n, m); % generate empty map
            noise_map = utilities.perlin_noise(im); % fill map with noise
            noise_map = utilities.normalize(noise_map, max(noise_map(:)), min(noise_map(:))); % scale to [0 1] interval
            
            % assigning the porosity values
            noise_map(noise_map >= open_th) = 1; % 1 is 100% porosity
            poro = zeros(np,1);
            norm = zeros(np,2);
            for ip = 1: np
                % average of coord of input and output pipe node
                X = mean([xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,2),1)]);
                y = mean([xtotal(pipe_nodes(ip,1),2), xtotal(pipe_nodes(ip,2),2)]);

                minx = min(xtotal(:,1));
                maxx = max(xtotal(:,1));
                miny = min(xtotal(:,2));
                maxy = max(xtotal(:,2));

                norm(ip, 1) = round(utilities.normalize([X], maxx, minx) * n, 0);
                norm(ip, 2) = round(utilities.normalize([y], maxy, miny) * m, 0);
                
                % handles the case where geometry is one dimensional
                norm(ip, 1) = max(1, norm(ip, 1));
                norm(ip, 2) = max(1, norm(ip, 2));

                poro(ip, 1) = noise_map(norm(ip, 1), norm(ip, 2));
            end
        
        % A test mixed case where perlin noise is used to apply porosity to
        % the model. K remains constant. Open near wells
        case 4
            open_th = 0.5;%78; % threshold above with the pipes are considered open
            well_exclusion_th = 200; % radius around which the material will be set to open

            K = 3.e-2;
            K = zeros(np,1) + K;

            % creating perlin noise map
            n = 100; % resolution x
            m = 100; % resolution y
            im = zeros(n, m); % generate empty map
            noise_map = utilities.perlin_noise(im); % fill map with noise
            noise_map = utilities.normalize(noise_map, max(noise_map(:)), min(noise_map(:))); % scale to [0 1] interval
            
            % assigning the porosity values
            noise_map(noise_map >= open_th) = 1; % 1 is 100% porosity
            poro = zeros(np,1);
            norm = zeros(np,2);
            for ip = 1: np
                % average of coord of input and output pipe node
                X = mean([xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,2),1)]);
                y = mean([xtotal(pipe_nodes(ip,1),2), xtotal(pipe_nodes(ip,2),2)]);

                % checks if the pipe is too close to the injection or
                % abstraction point
                exit = 0;
                for i = 1:length(q_in)
                    if q_in{i} > 0                        
                        if utilities.distance([X,y], x(q_in{i},:)) < well_exclusion_th
                            poro(ip, 1) = 1;
                            exit = 1;
                        end
                    end
                end

                for i = 1:length(q_out)
                    if q_out{i} > 0
                        if utilities.distance([X,y], x(q_out{i},:)) < well_exclusion_th
                            poro(ip, 1) = 1;
                            exit = 1;
                        end
                    end
                end
                           
                if exit == 1
                    continue % move on to the next pipe
                end

                minx = min(xtotal(:,1));
                maxx = max(xtotal(:,1));
                miny = min(xtotal(:,2));
                maxy = max(xtotal(:,2));

                norm(ip, 1) = round(utilities.normalize([X], maxx, minx) * n, 0);
                norm(ip, 2) = round(utilities.normalize([y], maxy, miny) * m, 0);
                
                % handles the case where geometry is one dimensional
                norm(ip, 1) = max(1, norm(ip, 1));
                norm(ip, 2) = max(1, norm(ip, 2));

                poro(ip, 1) = noise_map(norm(ip, 1), norm(ip, 2));
            end

        % A test mixed case where perlin noise is used to apply porosity to
        % the model. K remains constant. Porous near wells
        case 5
            open_th = 0.5; % threshold above which the pipes are considered open
            well_exclusion_th = 200; % radius around which the material will be set to open

            K = 3.e-2;
            K = zeros(np,1) + K;

            % creating perlin noise map
            n = 100; % resolution x
            m = 100; % resolution y
            im = zeros(n, m); % generate empty map
            noise_map = utilities.perlin_noise(im); % fill map with noise
            noise_map = utilities.normalize(noise_map, max(noise_map(:)), min(noise_map(:))); % scale to [0 1] interval
            
            % assigning the porosity values
            noise_map(noise_map >= open_th) = 1; % 1 is 100% porosity
            poro = zeros(np,1);
            norm = zeros(np,2);
            for ip = 1: np
                % average of coord of input and output pipe node
                X = mean([xtotal(pipe_nodes(ip,1),1), xtotal(pipe_nodes(ip,2),1)]);
                y = mean([xtotal(pipe_nodes(ip,1),2), xtotal(pipe_nodes(ip,2),2)]);

                % checks if the pipe is too close to the injection or
                % abstraction point
                exit = 0;
                for i = 1:length(q_in)
                    if q_in{i} > 0                        
                        if utilities.distance([X,y], x(q_in{i},:)) < well_exclusion_th
                            poro(ip, 1) = rand() * open_th;
                            exit = 1;
                        end
                    end
                end

                for i = 1:length(q_out)
                    if q_out{i} > 0
                        if utilities.distance([X,y], x(q_out{i},:)) < well_exclusion_th
                            poro(ip, 1) = rand() * open_th;
                            exit = 1;
                        end
                    end
                end
                           
                if exit == 0
                    minx = min(xtotal(:,1));
                    maxx = max(xtotal(:,1));
                    miny = min(xtotal(:,2));
                    maxy = max(xtotal(:,2));
    
                    norm(ip, 1) = round(utilities.normalize([X], maxx, minx) * n, 0);
                    norm(ip, 2) = round(utilities.normalize([y], maxy, miny) * m, 0);
                    
                    % handles the case where geometry is one dimensional
                    norm(ip, 1) = max(1, norm(ip, 1));
                    norm(ip, 2) = max(1, norm(ip, 2));
    
                    poro(ip, 1) = noise_map(norm(ip, 1), norm(ip, 2));
                end
            end
    end
end