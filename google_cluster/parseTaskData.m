clc; clear; close all;

SUBMIT_TYPE=0;
SCHEDULE_TYPE=1;
EVICT=2;
FAIL=3;
FINISH_TYPE=4;
KILL=5;
LOST=6;
UPDATE_PENDING=7;
UPDATE_RUNNING=8;


taskFolder = 'clusterdata-2011-2/task_events';

% get all job files
jobFiles = dir(fullfile(taskFolder, '*.gz'));

% list all job name

disp('get all tasks');
numProperties = 10;
taskInfos = zeros(0,numProperties);
nFiles = length(jobFiles);
for i=1:nFiles
  gunzip([taskFolder '/' jobFiles(i).name], taskFolder);
  csvFile = [ taskFolder '/' jobFiles(i).name(1:length(jobFiles(i).name)-3)];
  
  [timestamp,missinginfo,jobIds,taskIdInAJob,machineIds,eventType,usernames,schedulingClass,priorities,cpu,ram,disk,constraint]  ...
    = importTaskEvents(csvFile);
  
  taskInfo = zeros(1,numProperties)-1;
  maxJobId = 0;
%   for iTS=1:length(timestamp)    
    % add the job to the list
    newTaskIds = find(eventType==SUBMIT_TYPE);
    newTasks = [jobIds(newTaskIds) taskIdInAJob(newTaskIds) timestamp(newTaskIds) ...
      schedulingClass(newTaskIds) priorities(newTaskIds) ...
      cpu(newTaskIds) disk(newTaskIds) taskIdInAJob(newTaskIds) zeros(size(taskIdInAJob(newTaskIds))) zeros(size(taskIdInAJob(newTaskIds)))];
    taskInfos = vertcat(taskInfos, newTasks);
    
    scheduledTaskIds = find(eventType==SCHEDULE_TYPE);
    mJobIds = jobIds(scheduledTaskIds);
    mTaskIds = taskIdInAJob(scheduledTaskIds);
    scheduleTimes = timestamp(scheduledTaskIds);
%     if eventType(iTS)==SCHEDULE_TYPE
      % add scheduled time 
%     for iTemp=1:length(mJobIds)
%       jobId = mJobIds(iTemp); 
%       taskId = mTaskIds(iTemp);
      [jIds, c] = ismember(taskInfos(:,1),mJobIds);
      taskInfos(jIds, 9) = scheduleTimes;
%     end
     
%     end
    completeTaskIds = find(eventType==EVICT || eventType==FINISH_TYPE ...
        || eventType==FAIL || eventType==KILL || eventType== LOST);
    jIds = jobIds(completeTaskIds);
    tIds = taskIdInAJob(completeTaskIds);
    completeTimes = timestamp(completeTaskIds);
    for iTemp=1:length(mJobIds)
      jobId = mJobIds(iTemp); 
      taskId = mTaskIds(iTemp);
      jIds = find(taskInfos(:,1)==jobId);
      taskInfos(jIds, 10) = completeTimes(iTemp);
    end
    %
%   end
  delete(csvFile);
  progress = i*100/nFiles;
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end
  if mod((progress),1)==10
    [taskIds,a,c] = unique(taskInfos(:,1:2), 'rows');
    taskInfos = taskInfos(a,:);
  end
end

[taskIds,a,c] = unique(taskInfos(:,1:2), 'rows');
taskInfos = taskInfos(a,:);

save('taskInfo.mat');
disp('finish parseTaskData');