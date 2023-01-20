clear; clc;

SID = input('Subject ID: ','s');
runNum = input('Run number: ');
[exp, D] = FOSS(SID, runNum, '/home/mohsenzadehlab/Ali/fMRI_localizer');