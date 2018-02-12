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
  %% check tasks
  if true
    temp = [jobIds taskIdInAJob eventType];
    temp2 = temp(find(temp(:,3)==1),:);
    len = length(temp2) - length(unique(temp2,'rows'));
    if  len > 0
      fprintf('schedule tasks twice %d / %d \n ',len, length(temp2));
    end
  end
  %%
  % group unique tasks
  [taskIds,a,c] = unique([jobIds taskIdInAJob], 'rows');
  cpuUsage = cpu(a);
  memUsage = ram(a);
  diskUsage = disk(a);
  temp = [taskIds cpuUsage memUsage diskUsage];
  tasks = [tasks; temp];
  
  delete(csvFile);
  
  progress = i*100/nFiles;
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end  
  
    % group unique tasks
  if mod((progress),10)==0
    [taskIds,a,c] = unique(tasks(:,1:2), 'rows');
    tasks = tasks(a,:);
  end
%   size(tasks)
end
% group unique tasks
[taskIds,a,c] = unique(tasks(:,1:2), 'rows');
tasks = tasks(a,:);
% global group:
[groupjobIds,~,c] = unique(tasks(:,1));
cpuUsage = accumarray(c,tasks(:,3));
memUsage = accumarray(c,tasks(:,4));
diskUsage = accumarray(c,tasks(:,5));
%priority = 
JobInfos = [groupjobIds cpuUsage memUsage diskUsage];
%
%csvwrite('jobResusage.csv',JobInfos);
save('jobResUsageTest.mat');