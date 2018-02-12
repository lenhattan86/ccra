clear; clc; close all;
%%
micro_second = 10^6;
period = 60;
numDays = 30;
arrivalTime = [0:period:numDays*24*3600]/(3600*24);
numClass = 4;
allocatedCPU = zeros(numClass, length(arrivalTime));
allocatedMEM = zeros(numClass, length(arrivalTime));
%% load the job id, job start, job end time, job compl time, cpu, mem
JOB_FILE = 'jobInfo.mat';
% JOB_USAGE = 'jobResUsageWReschedule100.mat';
JOB_USAGE = 'jobResUsageWReschedule.mat';

load(JOB_FILE);
jobIds = JobInfos(:,1);
scheduleClass =JobInfos(:,4);
complTimes = JobInfos(:,3) - JobInfos(:,5); % microsecond
% temp = [jobIds JobInfos(:,5) JobInfos(:,3) scheduleClass];
temp = [jobIds JobInfos(:,2) JobInfos(:,3) scheduleClass];
jobComplInfos = temp(find(complTimes > 0),:);
jobComplInfos = jobComplInfos(find(jobComplInfos(:,2) > 0),:); % remove the jobs that are scheduled before capturing the trace

load(JOB_USAGE);
jobUsage = JobInfos;
% 
for i=1:numClass
  class = find(jobComplInfos(:,4) == (i-1));
  jobs = jobComplInfos(class,1);
  
  temp1 = ismember(jobUsage(:,1),jobs); 
  usageTemp = jobUsage(temp1,:);
  temp2 = ismember(jobComplInfos(:,1), usageTemp(:,1)); 
  mJobUsage{i} = [usageTemp jobComplInfos(temp2,2:4)];
end

%% add to allocatedResource
% for each job, compute add the resource demand to allocatedResource
cpuIdx = 2;
memIdx = 3;
for i=1:numClass
  for iJob = 1:length(mJobUsage{i})
    
    scheduleTime = mJobUsage{i}(iJob, 5)/micro_second;    
    endTime = mJobUsage{i}(iJob, 6)/micro_second;    
    complTime = endTime - scheduleTime;
    
    nPeriods = ceil(complTime/period);
    timeIndex = ceil(scheduleTime/period)+1; 
    eIdx = min(length(arrivalTime), timeIndex+nPeriods);
    
    allocatedCPU(i,timeIndex:eIdx) = allocatedCPU(i,timeIndex:eIdx) + mJobUsage{i}(iJob, cpuIdx);
    allocatedMEM(i,timeIndex:eIdx) = allocatedMEM(i,timeIndex:eIdx) + mJobUsage{i}(iJob, memIdx);
  end
end

%% plot figures
bar(arrivalTime, allocatedCPU', 1, 'stacked','EdgeColor','none');
xlim([0 max(arrivalTime)]);
% xlim([0 1]);
% ylim([0 7500]);
xlabel('days');
ylabel('cpu demand');
classes = {'class 0', 'class 1', 'class 2', 'class 3'};
legend(classes);