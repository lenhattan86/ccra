clear; close all; clc;

load('data15.mat');

folder_to_write = '/home/tanle/hadoop/conf/';

%fileToWrite ='~/Dropbox/temp/config.txt';
fmt_01 = '1 1 200 bursty0\n';
fmt_02 = 'Map1 %s %s %s 0.05 0.0 0.22 0.0 %s\n';
fmt_03 = '0';

scaleUp = 2;

fmt = [fmt_01 fmt_02 fmt_03];
overHead = overhead;

clusterSize = 8;
clusterSize = clusterSize*scaleUp;
overHead = overHead + 2;

job_profile(:,3:4)= job_profile(:,3:4)*scaleUp;
%% write SQ jobs
nSQJobs = 10;
jobLength = period;

for i=1:nSQJobs
    fileToWrite =[folder_to_write num2str(i-1) '.profile'];
    fileID = fopen(fileToWrite,'w');
    fprintf(fileID, fmt, num2str(jobLength - overHead),num2str(0.01), num2str(1/clusterSize), num2str(clusterSize/2 - 1));
    fclose(fileID);
end

%% write TQ jobs
 
for i=1:length(job_profile(:,1))
    fileToWrite =[folder_to_write num2str(100000 + job_profile(i,1)-1) '.profile'];
    fileID = fopen(fileToWrite,'w');    
    fprintf(fileID, fmt, num2str(job_profile(i,4)/job_profile(i,3)- overHead ) , num2str(0.01), num2str(1/clusterSize),  num2str(job_profile(i,3)-1) );
    
    fclose(fileID);    
end