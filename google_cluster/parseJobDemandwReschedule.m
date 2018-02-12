clc; clear; close all;

TaskFolder = 'clusterdata-2011-2/task_events';

% get all job files
jobFiles = dir(fullfile(TaskFolder, '*.gz'));
% list all job name

numProperties = 5;
allJobIds = [];
tasks = zeros(0, numProperties);

nFiles = length(jobFiles);
for i=1:nFiles
  gunzip([TaskFolder '/' jobFiles(i).name], TaskFolder);
  csvFile = [ TaskFolder '/' jobFiles(i).name(1:length(jobFiles(i).name)-3)];
  [timestamp,missinginfo,jobIds,taskIdInAJob,machineIds,eventType,usernames,schedulingClass,priorities,cpu,ram,disk,constraint]  ...
    = importTaskEvents(csvFile);
  
  temp = [jobIds taskIdInAJob cpu ram disk];
  temp = temp(find(eventType==1),:);    
  tasks = [tasks; temp];  
  delete(csvFile);
  
  progress = i*100/nFiles;
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end    
end
% global group:
[groupjobIds,~,c] = unique(tasks(:,1));
cpuUsage = accumarray(c,tasks(:,3));
memUsage = accumarray(c,tasks(:,4));
diskUsage = accumarray(c,tasks(:,5));
%priority = 
JobInfos = [groupjobIds cpuUsage memUsage diskUsage];
%
save('jobResUsageWReschedule.mat');