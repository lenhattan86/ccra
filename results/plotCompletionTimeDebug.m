clear; 
addpath('func');
common_settings;

plots = [true true true];

STEP_TIME = 1.0; 


num_batch_queues = 8;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;
jobIdThreshold=100000;


%%
% folder  = 'debug/motivation/drf/users/tanle/result/';
folder  = 'debug/motivation/bopf/users/tanle/result/';
csvFile = 'yarn_completion_time.csv';
file = [folder csvFile];
[jobIds,submitDatetime,startDatetime,runningTime,totalTime,endTimeStamp,startExpTime] = import_compl_time_deadline(file);
jobInfo = readJobInfo([folder '../../../../' 'job_info.csv']);
deadlines = jobInfo.deadline;

lateness = zeros(1, length(deadlines));
iJob = 0;
for i = 1:length(jobIds)
    if (jobIds(i)>=100000 && jobIds(i)<200000)
        iJob=iJob+1;
        jobId = mod(jobIds(i),100000)+1;
%         lateness(jobId)      = totalTime(i)/1000 - (deadlines(jobId)) ;
        lateness(jobId)      = totalTime(i)/1000 - (deadlines(jobId)) ;
    end
end

figure;
bar(lateness); 
xlabel('job id');
ylabel('lateness (seconds)');
% ylim([-50 50]);

%%
runningTimeGap = zeros(2, length(deadlines));
iJob = 0;
for i = 1:length(jobIds)
    if (jobIds(i)>=100000 && jobIds(i)<200000)
        iJob=iJob+1;
        jobId = mod(jobIds(i),100000)+1;
%         lateness(jobId)      = totalTime(i)/1000 - (deadlines(jobId)) ;
        runningTimeGap(1,jobId)      = runningTime(i)/1000 ;
        runningTimeGap(2,jobId)      = jobInfo.processingtime(jobId);
    end
end
figure;
bar(runningTimeGap');
ylabel('processing time');
xlabel('job');
legend({'in experiment','profiled'});

%% plot tail performance of IQ
tail = zeros(1, length(deadlines));
iJob=0;
for i = 1:length(jobIds)
    if (jobIds(i)>=200000 )
        iJob=iJob+1;        
        tail(iJob) = totalTime(i)/1000;
    end
end
figure;
h = histogram(tail,20);
ylabel('histogram');
xlabel('completion time (seconds)');
xlim([0 800]);
ylim([0 30]);


%% 
avg = zeros(1, sum(jobIds<100000));
iJob=0;
for i = 1:length(jobIds)
    if (jobIds(i)<100000 )
        iJob=iJob+1;
        avg(iJob) = totalTime(i)/1000;
    end    
end
mean(avg)

