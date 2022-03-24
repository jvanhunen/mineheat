# This program allows for the computation of water and heat flow through a mine network
#     Copyright (C) 2022  Durham University
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

# importing os module 
import os 
import glob
  
# Ultra batch download produces filenames ifor original Matlab files 
# with the format "number - firstname lastname.m"
# This function renames the files to firstname_lastname.m
for filename in glob.glob("*.m"): 
    os.diff(filename, '../../../Michael_MacKenzie/code/code_20220107/code_master/'+filename) 
