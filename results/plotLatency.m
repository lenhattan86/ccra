%% initialization
clear all; clc; close all;
%% load and process data

%folder='cpubound-log-79-1queue';
folder='cpubound-log-79-cap-default';
filePrefix = 'cpubound';

D = dir([folder, '/*.csv']);
numberOfOverlaps = 7;
numberOfExps = 3;
numTSPerExp = 3;
processingLapses = zeros(1,numberOfOverlaps);
lapses= zeros(1,numberOfOverlaps);

for iOverlaps=1:1:numberOfOverlaps
    lapseFile = 0;
    timeSetup = zeros(iOverlaps, numberOfExps);
    timeProcess = zeros(iOverlaps, numberOfExps);
    for iApp=1:iOverlaps
        datetimes = importDatatime([folder '/' filePrefix num2str(iOverlaps) '_' num2str(iApp) '.csv']);
        
        for iExp =1:numberOfExps
            tempIdx = (iExp-1)*numTSPerExp;
            startTimeStr = datetimes{tempIdx+1}(1:19);  
            startTime = datetime(startTimeStr,'InputFormat','yy-MM-dd HH:mm:ss');
            
            startAppTimeStr = datetimes{tempIdx+2}(1:19); 
            startAppTime = datetime(startAppTimeStr,'InputFormat','yy-MM-dd HH:mm:ss');
            
            stopTimeStr = datetimes{tempIdx+3}(1:19);  
            stopTime = datetime(stopTimeStr,'InputFormat','yy-MM-dd HH:mm:ss');
                        
            timeSetup(iApp, iExp) = 86400*datenum(startAppTime - startTime);            
            timeProcess(iApp, iExp) = 86400*datenum(stopTime - startAppTime);
            if timeSetup(iApp, iExp) < 0
                timeSetup(iApp, iExp) = timeSetup(iApp, iExp) + 60*60;
                timeProcess(iApp, iExp) = timeProcess(iApp, iExp) - 60*60;
            end
%             timeGap=round(86400*mod(tt,1)); % in seconds.
            
%             lapseFile = lapseFile + timeSetup(iApp, iExp) + timeProcess(iApp, iExp);
            lapseFile = lapseFile + timeProcess(iApp, iExp);
        end
    end
    lapseFile = lapseFile/(numberOfExps*iOverlaps);
    processingLapses(iOverlaps) = lapseFile;
    lapses(iOverlaps) = lapseFile + sum(sum(timeSetup))/(numberOfExps*iOverlaps);
    
    if iOverlaps==4 && true
        iExp = 0;
        if iExp ==0
            for iExp=1:numberOfExps
                figure;
                bar([timeProcess(:,iExp), timeSetup(:,iExp) ],0.2,'stacked');
                xlabel('apps');
                ylabel('latency (secs)');
                legend('processing','setup');
            end
        else
            figure;
            bar([timeProcess(:,iExp), timeSetup(:,iExp) ],0.2,'stacked');
            xlabel('apps');
            ylabel('latency (secs)');
            legend('processing','setup'); 
        end
    end   
end

%% Plot first latency figures
figure;
numberOfOverlapsYaxis = 1:numberOfOverlaps;
plot(numberOfOverlapsYaxis,lapses,'-o','linewidth',2);
hold on;
plot(numberOfOverlapsYaxis,processingLapses,'-*','linewidth',2);
legend('total','processing');
xlabel('number overlapping apps');
ylabel('latency (secs)');
ylim([0 max(lapses)]);