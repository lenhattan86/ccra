%% initialization
clear all; clc; close all;
%% load and process data

folder='cpubound-log';
filePrefix = 'cpubound';

D = dir([folder, '/*.csv']);
numberOfOverlaps = 4;
numberOfExps = 5;
lapses= zeros(1,numberOfOverlaps);

for iOverlaps=1:numberOfOverlaps
    lapseFile = 0;
    for iN=1:iOverlaps
        datetimes = importDatatime([folder '/' filePrefix num2str(iOverlaps) '_' num2str(iN) '.csv']);
        numTSPerExp = 3;
        for iExp =1:numberOfExps
            tempIdx = (iExp-1)*numTSPerExp
            startTimeStr = datetimes{tempIdx+1}(1:19);  
            startTime = datetime(startTimeStr,'InputFormat','yy-MM-dd HH:mm:ss');
            
            startAppTimeStr = datetimes{tempIdx+2}(1:19); 
            startAppTime = datetime(startAppTimeStr,'InputFormat','yy-MM-dd HH:mm:ss');
            
            stopTimeStr = datetimes{tempIdx+3}(1:19);  
            stopTime = datetime(stopTimeStr,'InputFormat','yy-MM-dd HH:mm:ss');
                        
            timeSetup = 86400*datenum(startAppTime - startTime);
            timeProcess = 86400*datenum(stopTime - startAppTime);
%             timeGap=round(86400*mod(tt,1)); % in seconds.
            
            lapseFile = lapseFile + timeSetup + timeProcess;
        end
    end
    lapseFile = lapseFile/(numberOfExps*iOverlaps);
    lapses(iOverlaps) = lapseFile;
%     if iN==5 && true
%         figure;
%         bar(lapseFile,0.2);
%         xlabel('apps');
%         ylabel('latency (secs)');
%     end
%   
end


%% Plot first latency figures
figure;
numberOfOverlapsYaxis = 1:numberOfOverlaps;
plot(numberOfOverlapsYaxis,lapses,'-o','linewidth',2);
xlabel('number overlapping apps');
ylabel('latency (secs)');
ylim([0 max(lapses)]);