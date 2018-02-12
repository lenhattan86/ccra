clc; clear; close all;

TaskFolder = 'clusterdata-2011-2/task_events';

% get all job files
jobFiles = dir(fullfile(TaskFolder, '*.gz'));
% list all job name

numProperties = 4;
allJobIds = [];
JobInfos = zeros(0, numProperties);

nFiles = 10; %length(jobFiles);
for i=1:nFiles
  progress = i*100/nFiles;
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end  
  
  gunzip([TaskFolder '/' jobFiles(i).name], TaskFolder);
  csvFile = [ TaskFolder '/' jobFiles(i).name(1:length(jobFiles(i).name)-3)];
  [timestamp,missinginfo,jobIds,taskIdInAJob,machineIds,eventType,usernames,schedulingClass,priorities,cpu,ram,disk,constraint]  ...
    = importTaskEvents(csvFile);
  
  % local group:
  [groupjobIds,~,c] = unique(jobIds);
  cpuUsage = accumarray(c,cpu);
  memUsage = accumarray(c,ram);
  diskUsage = accumarray(c,disk);
  temp = [groupjobIds cpuUsage memUsage diskUsage];
  
  JobInfos = [JobInfos;temp];
  delete(csvFile);
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
save('jobResUsageTest.mat');