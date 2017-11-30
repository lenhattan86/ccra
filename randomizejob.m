% generate profiles
% CPU~ N(mu1,sigma1);
% GPU~ N(mu2,sigma2);
% rou: correlation
% n: number of arrivals(jobs)
function [job_profile,report1,report2] = randomizejob(mu1,sigma1,mu2,sigma2,rou,n,confidence)

report1 = [norminv(confidence,mu1,sigma1) norminv(confidence,mu2,sigma2)];  %iid

job_profile = mvnrnd([mu1,mu2],[1 rou;rou 1],3*n);

job_profile(job_profile(:,1)< mu1-3*sigma1,:) = [];
job_profile(job_profile(:,1)> mu1+3*sigma1,:) = [];

job_profile(:,job_profile(1,:)> mu2+3*sigma2) = [];
job_profile(:,job_profile(2,:)< mu2-3*sigma2) = [];
job_profile = job_profile(1:n,:);

for i=(mu1+sigma1):0.01:(mu1+4*sigma1)
    j = (mu2+sigma2)+(i-mu1-sigma1)/sigma1*sigma2; 
    report2_set = mvncdf([i j],[mu1,mu2],[1 rou;rou 1]);
    if report2_set >confidence
        report2 = [i j];
        break
    end
end
end

