clear; clc; close all;
%%
micro_second = 10^6;
period = 60*60;
numDays = 30;
arrivalTime = [0:period:numDays*24*3600+period];
numClass = 4;

%% load the job id, job start, job end time, job compl time, cpu, mem
JOB_FILE = 'jobInfo.mat';
JOB_USAGE = 'jobResUsageWReschedule.mat';

load(JOB_FILE);
jobIds = JobInfos(:,1);
scheduleClass =JobInfos(:,4);
complTimes = JobInfos(:,3) - JobInfos(:,5); % microsecond
temp = [jobIds JobInfos(:,5) JobInfos(:,3) JobInfos(:,3)-JobInfos(:,5) scheduleClass];

jobComplInfos = temp(find(temp(:,4) > 0),:);
jobComplInfos = jobComplInfos(find(jobComplInfos(:,2) >= 0),:); % remove the jobs that are scheduled before capturing the trace

load(JOB_USAGE);
jobUsage = JobInfos;

jobs = jobComplInfos(:,1);
temp1 = ismember(jobUsage(:,1),jobs); 
usageTemp = jobUsage(temp1,:);
temp2 = ismember(jobComplInfos(:,1), usageTemp(:,1)); 
mJobUsage = [usageTemp jobComplInfos(temp2,2:5)];

%%
jobSize = zeros(1, length(arrivalTime)-1);
for iTime = 1:length(arrivalTime)-1
  iTs = (mJobUsage(:,5)/micro_second >= arrivalTime(iTime)) .* (mJobUsage(:,5)/micro_second < arrivalTime(iTime+1));
  ids = find(iTs==1);
%   jobSize(iTime) = sum(mJobUsage(ids,2).*mJobUsage(ids,7))/(micro_second*3600);
  jobSize(iTime) = sum(mJobUsage(ids,2));
end

%% plot figures
plot(arrivalTime(1:length(arrivalTime)-1)/(3600), jobSize);
% xlim([0 max(arrivalTime)]);
xlabel('hours');
ylabel('total job size (cpu) ');