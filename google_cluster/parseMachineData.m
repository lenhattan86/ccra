clc; clear; close all;

ADD=0;
REMOVE=1;
CHANGE=2;

period = 5*60;
% period = 60;
numOfDays = 29;
timeDim = (0:period:numOfDays*24*3600+period);


capacity = zeros(2,length(timeDim)-1);

machineFolder = 'clusterdata-2011-2/machine_events'
machineFile = 'part-00000-of-00001.csv.gz';

gunzip([machineFolder '/' machineFile], machineFolder);
csvFile = [ machineFolder '/' machineFile(1:length(machineFile)-3)];
[timeStamp,machineIds,eventType,platformId,cpu,ram] = importMachineFile(csvFile);
% delete(csvFile);

uniqueMachines = unique(machineIds);
cluster = zeros(length(uniqueMachines), 2);

timeStamp = timeStamp/10^6;
for iTime = 1: length(timeDim)-1
  % find the timestamp greater than curren time and larger than the next
  % time slot
  iTs = (timeStamp >= timeDim(iTime)) .* (timeStamp < timeDim(iTime+1));
  temp = find(iTs==1);
  newEvents = eventType(temp);
  newMachines = machineIds(temp);
  newCpus = cpu(temp);
  newMems = ram(temp);
  for iEvent =1:length(newEvents)
    event = newEvents(iEvent);
    newMachine = newMachines(iEvent);
    iMachine = find(uniqueMachines==newMachine);
    if event==ADD || event==CHANGE
      cluster(iMachine,1) = newCpus(iEvent);
      cluster(iMachine,2) = newMems(iEvent);
    elseif event==REMOVE
      cluster(iMachine,1) = 0;
      cluster(iMachine,2) = newMems(iEvent);
    end
  end  
  % compute capacity
  capacity(1,iTime) = sum(cluster(:,1));
  capacity(2,iTime) = sum(cluster(:,2));
end
%% 

%plot  capacity 
plot(timeDim(1:length(timeDim)-1)/3600, capacity(1,:));
xlabel('time (hours)');
ylabel('cpu capacity');
ylim([0 7000]);
xlim([0 max(timeDim)/3600]);

figure;
plot(timeDim(1:length(timeDim)-1)/3600, capacity(2,:));
xlabel('time (hours)');
ylabel('memory capacity');
ylim([0 7000]);
xlim([0 max(timeDim)/3600]);
