clear; close all; clc;

load('hibench.mat');

% folder_to_write = '/users/tanle/job_info.csv';
folder_to_write = 'job_info.csv';

fmt_01 = '%s,%s,%s,%s,%s \n';
fmt = [fmt_01];

fileID = fopen(folder_to_write,'w');    

fprintf(fileID, fmt, 'jobId', 'totalDemand', 'demand', 'processingtime', 'deadline');
        
for i=1:length(job_profile(:,1))    
    fprintf(fileID, fmt, num2str(job_profile(i,1) - 1 + 100000), ...
            num2str(job_profile(i,4)) , num2str(job_profile(i,3)), num2str(job_profile(i,4)/job_profile(i,3)), ...
            num2str(job_profile(i,5) - job_profile(i,2)) );
end
fclose(fileID);    
