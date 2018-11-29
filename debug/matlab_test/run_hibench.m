clear; close all;

%% load data
folder = '/ssd/projects/HiBench-7.0/results/cloudlab';
largecc40 = import_hibench_report([folder '/' 'large_cc_40.csv']);

numOfJobs=length(largecc40.JobName);
clusterSize = 16*40;
period = 300; overhead = 15;
avgJobLength = mean(largecc40.Durations);

durations = round(largecc40.Durations);
demands = round(largecc40.YARN_NUM_EXECUTORS.*largecc40.YARN_NUM_EXECUTORS);

% inter_arrival =  poissrnd(50,1,numOfJobs);
inter_arrival = [53    64    64    44    41    47    40    56    53    55    32    54    63    44    54    54    54    50    54    59    53    55  57    42    50    51    71    49    55    54    56    51    55    45    47    46    50    57    51    58    58    44];

%% gen jobs
% end_time = 30000;
end_time = period*8;
avail_res = clusterSize*ones(1,end_time);

for i = 1:period*2:end_time
    avail_res(i:i+307-1) = clusterSize/2;
end

job_profile = zeros(numOfJobs,5);
for i = 1:numOfJobs
%     job_profile(i,1) = largecc40.JobName(i);
    job_profile(i,1) = i;
    job_profile(i,3) = round(demands(i));
    job_profile(i,4) = durations(i)*demands(i);
end

% inter arrival
for i = 2:numOfJobs
    job_profile(i,2) = job_profile(i-1,2) + inter_arrival(i);
end

% deadline
for i = 1:numOfJobs
    job_profile(i,5) =  ceil(job_profile(i,2) + 1.3*(job_profile(i,4)/job_profile(i,3))) ;    
end

save('hibench.mat');    
%% 
[res_mat, job_finished, res_avail] = Alg1(job_profile, avail_res, end_time);
sum(job_finished(:,1))
% figure;
% bar(res_mat);

[res_mat_edf, job_finished_edf, res_avail_edf] = EDF(job_profile, avail_res, end_time);
sum(job_finished_edf(:,1))
% figure;
% bar(res_mat_edf);
% save('data.mat');