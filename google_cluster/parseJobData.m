clc; clear; close all;
SUBMIT_TYPE=0;
FINISH_TYPE=4;

%jobFolder = '/home/tanle/clusterdata-2011-2/example';
jobFolder = '/home/tanle/clusterdata-2011-2/job_events';

% get all job files
jobFiles = dir(fullfile(jobFolder, '*.csv'));

% list all job name

disp('get all jobs');
numProperties = 5;
allJobIds = [];
JobInfos = zeros(1,numProperties);
for i=1:length(jobFiles)
  
  progress = i*100/length(jobFiles);
  if mod((progress),1)==0
    str = [' progress: ', num2str(progress),' %.'];   
    disp(str);
  end
  
  [timestamp,missinfo,jobIds,eventType,Username,schedulingClass,jobName,logicalJobName] = importJobEventFile([ jobFolder '/' jobFiles(i).name ]);
  jobInfo = zeros(1,numProperties)-1;
  usernames = {};
  for iTS=1:length(timestamp)
    
    if eventType(iTS)==SUBMIT_TYPE      
      % add arrival time 
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
    
    % add completion time, finish
    if eventType(iTS)==FINISH_TYPE
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
        end
      end
    end
    %
  end
end

%csvwrite('jobInfo.csv',JobInfos);
save('usernames.mat', 'usernames');
save('jobInfo.mat');