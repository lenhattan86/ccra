clear; close all; clc;
addpath('func');

[timestamps,queueNames,usedCPUs,usedMemory] = importUsedResources('/home/tanle//projects/ccra/spark-test-cases/log2/yarnUsedResources.csv');

usedMemory = usedMemory/1024;

%interactiveIdx=2;
%batchIdx=1;
numQueues=6;

startTime=1;
%stopTime =floor(length(timestamps)/3)-1;
stopTime =120;

timeStep=1;
timeIdx=startTime:timeStep:stopTime;

linewidth= 2;
% fig_path = 'figs/';
fig_path = '/home/tanle/projects/NSDI17/fig/';
prefix = 'dynamic-priority-';
is_printed = false;
xmax = stopTime;

%interactiveIdxs = find(not(cellfun('isempty', strfind(queueNames, 'root.interactive')))) ;
interactiveIdxs = find(strcmp(queueNames, 'root.interactive'));
batchIdxs = find(strcmp(queueNames, 'root.batch')) ;

interactiveCPUs = usedCPUs(interactiveIdxs);
batchCPUs = usedCPUs(batchIdxs);
interactiveRAMs = usedMemory(interactiveIdxs);
batchRAMs = usedMemory(batchIdxs);

%% plot CPU
len = length(interactiveCPUs);
%ymax = max(sum(reshape(usedCPUs(1:len*numQueues),3,len)));
ymax = 128;
figure(1);
plot(timeIdx,batchCPUs(startTime:timeStep:stopTime), 'LineWidth', linewidth);
hold on;
plot(timeIdx,interactiveCPUs(startTime:timeStep:stopTime), 'LineWidth', linewidth);
ylabel('CPU (vcores)');
xlabel('time (seconds)');
xlim([0 xmax]);
ylim([0 ymax]);
legend('batch','interactive');
% set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path prefix 'vcore_usage.eps']);
end
%% plot RAM

%ymax = max(sum(reshape(usedMemory(1:len*numQueues),3,len)));  
ymax = 256;
figure(2);
plot(timeIdx,batchRAMs(startTime:timeStep:stopTime), 'LineWidth', linewidth);
hold on;
plot(timeIdx,interactiveRAMs(startTime:timeStep:stopTime), 'LineWidth', linewidth);
ylabel('RAM (GB)');
xlabel('time (seconds)');
xlim([0 xmax]);
ylim([0 ymax]);
legend('batch','interactive');

if is_printed
    print ('-depsc', [fig_path prefix 'ram_usage.eps']);
end

if is_printed
    close all;
end