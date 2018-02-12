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


%jobFolder = '/home/tanle/clusterdata-2011-2/example';
jobFolder = 'clusterdata-2011-2/job_events';

% get all job files
jobFiles = dir(fullfile(jobFolder, '*.gz'));

% list all job name

disp('get all jobs');
numProperties = 6;
allJobIds = [];
JobInfos = zeros(1,numProperties);
nFiles = length(jobFiles);
for i=1:nFiles
  progress = i*100/nFiles;
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end
  
  gunzip([jobFolder '/' jobFiles(i).name], jobFolder);
  csvFile = [ jobFolder '/' jobFiles(i).name(1:length(jobFiles(i).name)-3)];
  
  [timestamp,missinfo,jobIds,eventType,Username,schedulingClass,jobName,logicalJobName] = ...
    importJobEventFile(csvFile);
  jobInfo = zeros(1,numProperties)-1;
  usernames = {};
  
  if true
    temp = [jobIds eventType];
    temp2 = temp(find(temp(:,2)==1),:);
    len = length(temp2) - length(unique(temp2,'rows'));
    if  len > 0
      fprintf('reschedule jobs %d',len);
    end
  end

  for iTS=1:length(timestamp)    
    % add the job to the list
    if eventType(iTS)==SUBMIT_TYPE      
      % add scheduled time & arrival time
      allJobIds = [allJobIds jobIds(iTS)];
      jobInfo(1) = jobIds(iTS); % job id      
      jobInfo(2) = timestamp(iTS); % submission time.      
      jobInfo(4) = schedulingClass(iTS); % scheduling class
      
      jId = find(JobInfos(:,1)==jobInfo(1));      
      if(length(jId) == 0)        
        JobInfos = vertcat(JobInfos,jobInfo);    
        usernames{length(usernames)+1} = Username{iTS};  
      end
    end
    
    if eventType(iTS)==SCHEDULE_TYPE
      % add scheduled time 
      jobId = jobIds(iTS);            
      jId = find(JobInfos(:,1)==jobId);      
      
      if(length(jId) > 1)
        JobInfos(jId,:)
        jId
        error('dupliated id');                
      end
      
      if(jId > 0)
        if(timestamp(iTS)>JobInfos(jId,3))
          JobInfos(jId,5) = timestamp(iTS);
        end
      end
    end

    % add completion time, finish
    if eventType(iTS)==EVICT || eventType(iTS)==FINISH_TYPE ...
        || eventType(iTS)==FAIL || eventType(iTS)==KILL || eventType(iTS)== LOST
        
      jobId = jobIds(iTS);
      jobInfo(3) = timestamp(iTS);      
      jId = find(JobInfos(:,1)==jobId);  
      
      if(length(jId) > 1)
        JobInfos(jId,:)
        jId
        error('dupliated id');                
      end
      
      if(jId > 0)
        if(timestamp(iTS)>JobInfos(jId,3))
          JobInfos(jId,3) = timestamp(iTS);
          JobInfos(jId,6) = eventType(iTS);
        end
      end
    end
    %
  end
  delete(csvFile);
end

save('jobInfoNew.mat');
disp('finish parseJobData');