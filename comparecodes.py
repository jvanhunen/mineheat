# importing os module 
import os 
import glob
  
# Ultra batch download produces filenames ifor original Matlab files 
# with the format "number - firstname lastname.m"
# This function renames the files to firstname_lastname.m
for filename in glob.glob("*.m"): 
    os.diff(filename, '../../../Michael_MacKenzie/code/code_20220107/code_master/'+filename) 
