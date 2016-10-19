clear; close all; clc;

data = importCloudlab('yarn_large.csv');

fileToWrite ='config.txt';
% fileToWrite ='~/Dropbox/temp/config.txt';

fileID = fopen(fileToWrite,'w');
fprintf(fileID,'StrictHostKeyChecking no \n\n');
fclose(fileID);

fileID = fopen(fileToWrite,'a');


fmt_01 = 'host %s \n';
fmt_02 = '  Hostname %s \n';
fmt_03 = '  Port 22 \n';
fmt_04 = '  User tanle \n';
fmt_05 = '  IdentityFile ~/Dropbox/Papers/System/Flink/cloudlab/cloudlab.pem \n';
fmt_06 = '   \n';

fmt = [fmt_01 fmt_02 fmt_03 fmt_04 fmt_05 fmt_06];
 

sId = 1;
for i=1:length(data)
    hostname = data{i,4};
    if length(data{i,1})<10
        fprintf(fileID,fmt, data{i,1}, hostname(17:length(hostname)));
    else        
        disp(data{i,1})
    end
end

fclose(fileID);
