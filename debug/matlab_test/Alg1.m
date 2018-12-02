
% job profile -[ID, arrival_time, demand, total_demand, deadlines]
% available resource  - avail_res(t) is the total available resource at
% time (t-1) to t.
function [res_mat, job_finished, res_avail] = Alg1(job_profile, avail_res, end_time)

[job_num,~] = size(job_profile);
temp = job_profile;
temp2 = [temp temp(:,5)-temp(:,4)./temp(:,3)];
res_mat = zeros(job_num,end_time);
job_finished  = zeros(job_num,2);
sorted_job_profile = sortrows(temp2,6);  % sort based on deadlines
for i = 1: end_time
    sorted_job_profile = sortrows(sorted_job_profile,6); % sort based on deadlines
    for j = 1:job_num
        if sorted_job_profile(j,2) <= (i-1) ...
                && sorted_job_profile(j,3) <= avail_res(i) ... % todo: we missed this.
                && sorted_job_profile(j,4)>0 ...
                && sorted_job_profile(j,4)/sorted_job_profile(j,3)+ i-1 <= sorted_job_profile(j,5)
            % schedule job j
            sorted_job_profile(j,4) = sorted_job_profile(j,4) - sorted_job_profile(j,3); % todo: we missed this.
            avail_res(i) = avail_res(i)- sorted_job_profile(j,3);
            res_mat(sorted_job_profile(j,1),i) = sorted_job_profile(j,3);
            if sorted_job_profile(j,4) == 0 && i <= sorted_job_profile(j,5)
                job_finished(sorted_job_profile(j,1),1) = 1;
                job_finished(sorted_job_profile(j,1),2) = i;
            end
        end
    end
end
res_avail = avail_res;
end