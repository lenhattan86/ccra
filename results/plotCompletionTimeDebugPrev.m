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
% folder = '/home/tanle/projects/BPFImpl/debug/cpu16/bopf_npreempt/workGenLogs/';
% folder = '/home/tanle/projects/BPFImpl/debug/cpu16/bopf/workGenLogs/';
folder = '/home/tanle/projects/BPFImpl/debug/cpu16/edf/workGenLogs/';
% folder = '/home/tanle/SWIM/scriptsTest/workGenLogs/'; 
csvFile = 'yarn_completion_time.csv';
file = [folder csvFile];
[jobIds,submitDatetime,startDatetime,runningTime,totalTime,endTimeStamp,startExpTime] = import_compl_time_deadline(file);
deadlines = [75, 70, 56, 51, 66] + 10;
lateness = zeros(1, length(deadlines));
iJob = 0;
for i = 1:length(jobIds)
    if (jobIds(i)>=100000)
        iJob=iJob+1;
        jobId = mod(jobIds(i),100000)+1;
        endTimes(iJob) = datetime(endTimeStamp{i}(12:19),'InputFormat','HH:mm:ss');
        startExpTimes(iJob) = datetime(startExpTime{i}(12:19),'InputFormat','HH:mm:ss');        
        deadlineTimes(iJob) = startExpTimes(iJob) + seconds(deadlines(iJob));     
        lateness(jobId)      = seconds(endTimes(iJob) - deadlineTimes(iJob));
    end
end


%%
bar(lateness); 
xlabel('job id');
ylabel('lateness');
% ylim([-50 50]);

