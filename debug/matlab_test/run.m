clear; close all;
numOfJobs=50;
clusterSize = 800;
period = 600; overhead = 15;
avgJobLength = 600;
job_gen;

[res_mat, job_finished] = Alg1(job_profile, avail_res, end_time);
sum(job_finished(:,1))
% figure;
% bar(res_mat);

[res_mat_edf, job_finished_edf] = EDF(job_profile, avail_res, end_time);
sum(job_finished_edf(:,1))
% figure;
% bar(res_mat_edf);
% save('data.mat');