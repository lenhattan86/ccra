clear; clc; close all;
%%
micro_second = 10^6;
period = 60;
arrivalTime = [0:period:3600];
numClass = 4;
allocatedResource = zeros(numClass, length(arrivalTime));
%% load task id, job start, job end time, job compl time, cpu, mem


%% add to allocatedResource
% for each job, compute add the resource demand to allocatedResource
