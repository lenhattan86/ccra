clc; clear; close all;

TaskFolder = '/home/tanle/clusterdata-2011-2/task_events';
JOB_FILE = 'jobInfo_full.csv';

% get all job files
jobFiles = dir(fullfile(TaskFolder, '*.csv'));
% list all job name

numProperties = 4;
allJobIds = [];
JobInfos = zeros(0, numProperties);

for i=1:length(jobFiles)
  progress = i*100/length(jobFiles);
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end  
  [timestamp,missinginfo,jobIds,taskIdInAJob,machineIds,eventType,usernames,schedulingClass,priorities,cpu,ram,disk,constraint] = importTaskEvents([ TaskFolder '/' jobFiles(i).name ]);
  
  % local group:
  [groupjobIds,~,c] = unique(jobIds);
  cpuUsage = accumarray(c,cpu);
  memUsage = accumarray(c,ram);
  diskUsage = accumarray(c,disk);
  temp = [groupjobIds cpuUsage memUsage diskUsage];
  
  JobInfos = [JobInfos;temp];
end
% global group:
[groupjobIds,~,c] = unique(JobInfos(:,1));
cpuUsage = accumarray(c,JobInfos(:,2));
memUsage = accumarray(c,JobInfos(:,3));
diskUsage = accumarray(c,JobInfos(:,4));
%priority = 
JobInfos = [groupjobIds cpuUsage memUsage diskUsage];
%
%csvwrite('jobResusage.csv',JobInfos);
save('jobResUsage.mat');