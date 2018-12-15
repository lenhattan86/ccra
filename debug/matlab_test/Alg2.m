
% Job profile -[ID, arrival_time, demand, total_demand, deadlines]
% avail_res(t) is the total available resource at time [t-1,t).
% At starting time of every timeslot, events occurs in the following way:
% 1' New job arrivals
% 2' Scheduler doing algorithm
% 3' Jobs being processed
function [res_mat, job_finished, res_avail] = Alg2(job_profile, avail_res, end_time)

[job_num,~] = size(job_profile);
temp = job_profile;
temp2 = [temp temp(:,5)-temp(:,4)./temp(:,3)]; %6th column is the starting time deadline, job has to be scheduled before
res_mat = zeros(job_num,end_time);
job_finished  = zeros(job_num,2);
sorted_job_profile = sortrows(temp2,6);  % sort based on deadline
for i = 1: end_time  % here time 1 is interval [0,1)
    scan_finished = 0;
    while ~isempty(sorted_job_profile)  && scan_finished == 0 
        condition_dd = sorted_job_profile(:,6) < i-1 ; % jobs that have no hope to meet the deadline
        sorted_job_profile(condition_dd,:) = [];  % kill jobs
        [job_num,~] = size(sorted_job_profile);
    for j = 1:job_num
        if sorted_job_profile(j,2) <= (i-1) % job j has arrived 
                % find a starting time before starting time deadline to place job j
                % we pick starting time that minimize the peak of used resource
                % feasible starting time [i-1,sorted_job_profile(j,6)]
                start_j = i-1; %initialize
                best_val = -Inf;  %initialize
                duration_j = sorted_job_profile(j,4)/sorted_job_profile(j,3);
                for time_j = (i-1):sorted_job_profile(j,6)  % scan available time
                    temp_leftover = avail_res(time_j+1: time_j+1+ duration_j) - sorted_job_profile(j,3);
                    if max(temp_leftover) > best_val
                        start_j = time_j;
                        best_val = max(temp_leftover);
                    end
                end
                if best_val >=0  % feasible
                    used_j  = zeros(1,end_time);
                    used_j(start_j+1:start_j+1+duration_j) = sorted_job_profile(j,3);
                    avail_res = avail_res - used_j;
                    job_finished(sorted_job_profile(j,1),1) = 1;
                    job_finished(sorted_job_profile(j,1),2) = start_j+duration_j;                
                end
%                 sorted_job_profile(j,:) = [];
%                 job_num = job_num -1;
%                 j = j-1;
                    sorted_job_profile(j,2) = end_time+100; % stupid way to make sure this job won't be scheduled again
        end
    end
    scan_finished = 1;
    end
end
res_avail = avail_res;
end