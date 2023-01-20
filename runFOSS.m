clear; clc;

addpath('./FOSS');

SID = input('Subject ID: ','s');
runNum = input('Run number: ');
[exp, D] = FOSS(SID, runNum);