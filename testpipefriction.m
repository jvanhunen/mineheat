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
% testpipefriction
clear
d=2;
eps=0.01;
Re1 = linspace(100,2000,20)
Re2 = linspace(2100,4000,20)
Re3 = linspace(4100,10000,60)
i=1;
for Re_i = Re1
   f1(i) = pipe_friction_factor(Re_i, d, eps)
   i=i+1
end
i=1;
for Re_i = Re2
   f2(i) = pipe_friction_factor(Re_i, d, eps)
   i=i+1
end
i=1;
for Re_i = Re3
   f3(i) = pipe_friction_factor(Re_i, d, eps)
   i=i+1
end
figure(100), clf
plot(Re1,f1,Re2,f2,Re3,f3,'Linewidth',5)
xlabel('Re')
ylabel('f')
axis([100 10000 0 0.12])