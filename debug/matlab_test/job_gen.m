end_time = 1000;
avail_res = clusterSize*ones(1,end_time);

for i = 1:period*2:end_time
    avail_res(i:i+period-1) = clusterSize/2;
end

job_profile = zeros(numOfJobs,5);
for i = 1:numOfJobs
    job_profile(i,1) = i;
    job_profile(i,3) = randi(clusterSize/2-1)+1;
    job_profile(i,4) = job_profile(i,3)* (randi(avgJobLength) + overhead);
end

inter_arrival =  poissrnd(3,1,numOfJobs);

for i = 2:numOfJobs
    job_profile(i,2) = job_profile(i-1,2) + inter_arrival(i);
end

for i = 1:numOfJobs
    job_profile(i,5) =  ceil(job_profile(i,2) + (1+rand)*(job_profile(i,4)/job_profile(i,3) + overhead) ) ;
    %%job_profile(i,5) =  ceil(job_profile(i,2) + (job_profile(i,4)/job_profile(i,3)));
end





