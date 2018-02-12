%% reset 
clear; close all; clc;
%% load data

JOB_FILE = 'jobInfo.mat';
JOB_USAGE = 'jobResUsageWReschedule.mat';
mkdir('figs');

cpuCapacity = 6600;
memCapcity = 5900;
cpuMemRate = cpuCapacity/memCapcity;

load(JOB_FILE);
jobIds = JobInfos(:,1);
scheduleClass =JobInfos(:,4);
complTimes = JobInfos(:,3) - JobInfos(:,5); % microsecond
% temp = [jobIds JobInfos(:,5) JobInfos(:,3) scheduleClass];
temp = [jobIds JobInfos(:,2) JobInfos(:,3) scheduleClass JobInfos(:,5)];
jobComplInfos = temp(find(complTimes > 0),:);
jobComplInfos = jobComplInfos(find(jobComplInfos(:,2) >= 0),:);
%
load(JOB_USAGE); 
jobUsage = JobInfos;
% 
for i=1:4
  class = find(jobComplInfos(:,4) == (i-1));
  jobs = jobComplInfos(class,1);
  
  temp1 = ismember(jobUsage(:,1),jobs); 
  usageTemp = jobUsage(temp1,:);
  temp2 = ismember(jobComplInfos(:,1), usageTemp(:,1)); 
  mJobUsage{i} = [usageTemp jobComplInfos(temp2,2:5)];
end

Folder = '/home/tanle/projects/BPFSim/input/';
outputFile = [Folder 'job_google.txt'];
queueFile = [Folder 'queue_google.txt'];
% queueFile = ['queue_google.txt'];
LONG_JOB_IGNORE = 1000;
% ARRIVAL_TIME_IGNORE = 5*3600*24;
% ARRIVAL_TIME_IGNORE = 0;
% ARRIVAL_TIME_IGNORE = 25*3600;
ARRIVAL_TIME_IGNORE = 2.4*24*3600;

 %%
jobIdJump = 10000;
numOfJobs=2*[1000 1000 1000 1000];
numTasks = 100;
fileID = fopen(outputFile,'w');
iJobJump = 0;
for i=4:-1:1
  iCount = 0;
  if i==2
    iJobJump=0;
  end
  for iJob=1:length(mJobUsage{i}(:,1))
    %# 0
    if(i <=2)
      strQueue = 'batch0';
      jobIdx = iCount + iJobJump + jobIdJump;
    else
      strQueue = 'bursty0';
      jobIdx = iCount + iJobJump;
    end
    
    strJob = sprintf('# %d\n', jobIdx);    
    %1 0 100 bursty0
    complTime = mJobUsage{i}(iJob,6) - mJobUsage{i}(iJob,8);
    complTime = complTime/10^6;
    arrivalTime = mJobUsage{i}(iJob,5)/10^6;
%     if(i<=2)
%       arrivalTime = arrivalTime/50;
%     end    
    if (arrivalTime < ARRIVAL_TIME_IGNORE)
%     if (arrivalTime < ARRIVAL_TIME_IGNORE)
      continue;
    end
%     if (complTime > LONG_JOB_IGNORE)
%         complTime = LONG_JOB_IGNORE;      
%     end
    numTasks = complTime;
    arrivalTime = arrivalTime - ARRIVAL_TIME_IGNORE;
    
    strJob = [strJob sprintf('1 %d %0.0f %s\n', jobIdx, arrivalTime, strQueue)];
    %task 1.0 0.21 0.33 100
    maxValue = max(mJobUsage{i}(iJob,2), mJobUsage{i}(iJob,3));
    scale = 1;
    if(maxValue > (cpuCapacity/10))
      scale = maxValue/(cpuCapacity/100);
    elseif(maxValue < (cpuCapacity/3000))
      scale = maxValue/(cpuCapacity/100);
    end
    taskPeriod = 1.0;
    
%     if(scale>1)
      if complTime > 10000
        taskPeriod = 100.0;
      elseif complTime > 1000
        taskPeriod = 10.0;
      elseif complTime > 100
        taskPeriod = 5.0;      
      elseif complTime > 50
        taskPeriod = 2.0;
      elseif complTime > 10
        taskPeriod = 1.0;  
      end
%     end
%     taskPeriod = 1.0;
    strJob = [strJob sprintf('task %0.1f %0.3f %0.3f %0.0f\n', taskPeriod, mJobUsage{i}(iJob,2)/scale, cpuMemRate*mJobUsage{i}(iJob,3)/scale, ceil(numTasks*scale/taskPeriod))];
    %0
    strJob = [strJob '0\n'];
    %strJob = [num2str(mJobUsage{i}(iJob,3)) ' ' num2str(mJobUsage{i}(iJob,4)) '\n'];    


    iCount = iCount + 1;
    fprintf(fileID, strJob);
    
    if iCount >= numOfJobs(i)
      iJobJump = iJobJump + numOfJobs(i);
      break;
    end
  end
end

fclose(fileID);
 %%
fileID = fopen(queueFile,'w');
for i=3:-1:2
%   # 0
%   bursty0 1 10.0 
%   1500
  queue = ['# ' num2str(3-i) '\n'];
  type=0;
  if(i==2)
    strQueue = 'batch0';
    weight = 1;
  elseif(i==3)
    strQueue = 'bursty0';
    weight = 0;
    type=1;
  else
    strQueue = 'bursty1';
  end
  queue = [queue strQueue ' ' num2str(type) ' 1.0 \n'];
  queue = [queue num2str(weight) ' \n'];
  fprintf(fileID, queue);
end
fclose(fileID);