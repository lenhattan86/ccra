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
  usernames = {};
  maxJobId = 0;
  for iTS=1:length(timestamp)    
    % add the job to the list
    if eventType(iTS)==SUBMIT_TYPE      
      % add scheduled time & arrival time
      taskInfo(1) = jobIds(iTS); % job id      
      taskInfo(2) = taskIdInAJob(iTS); % task id
      
      taskInfo(3) = timestamp(iTS); % submission time.      
      taskInfo(4) = schedulingClass(iTS); % scheduling class
      taskInfo(5) = priorities(iTS); % priority
      
      taskInfo(6) = cpu(iTS); % cpu
      taskInfo(7) = ram(iTS); % ram
      taskInfo(8) = ram(iTS); % disk
      
      taskInfos = vertcat(taskInfos, taskInfo);    
    end
    
    if eventType(iTS)==SCHEDULE_TYPE
      % add scheduled time 
      jobId = jobIds(iTS); 
      taskId = taskIdInAJob(iTS);
      jIds = find(taskInfos(:,1)==jobId);
      taskInfos(jIds, 9) = timestamp(iTS);
    end

    % add completion time, finish
    if eventType(iTS)==EVICT || eventType(iTS)==FINISH_TYPE ...
        || eventType(iTS)==FAIL || eventType(iTS)==KILL || eventType(iTS)== LOST
        
      jobId = jobIds(iTS); 
      taskId = taskIdInAJob(iTS);
      jIds = find(taskInfos(:,1)==jobId);
      taskInfos(jIds, 10) = timestamp(iTS);
    end
    %
  end
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