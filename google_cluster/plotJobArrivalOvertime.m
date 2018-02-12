clear; clc; close all;
%%
micro_second = 10^6;
period = 60*60;
numDays = 29;
arrivalTime = [0:period:numDays*24*3600+period];
numJobs = zeros(1,length(arrivalTime)-1);
%% load the job id, job start, job end time, job compl time, cpu, mem
JOB_FILE = 'jobInfo.mat';

load(JOB_FILE);
%temp = [jobIds JobInfos(:,5)/micro_second JobInfos(:,3)/micro_second scheduleClass];
JobInfos = JobInfos(find(JobInfos(:,5)>0),:);
%%

for iTime = 1:length(arrivalTime)-1
  iTs = (JobInfos(:,5)/micro_second >= arrivalTime(iTime)) .* (JobInfos(:,5)/micro_second < arrivalTime(iTime+1));
  numJobs(iTime) = sum(iTs);
end

%%
plot(arrivalTime(1:length(arrivalTime)-1)/3600, numJobs)
xlabel('arrival time (hours)');
ylabel('num of jobs');

%%
temp = find(JobInfos(:,1)<0);