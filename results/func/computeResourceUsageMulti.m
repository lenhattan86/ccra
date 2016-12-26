function [ avgRes1, avgRes2, flag] = computeResourceUsageMulti( files, queues, beginTimeIdx,  endTimeIdx)
  
  flag = true;
  numFiles = length(files);
  numQueues = length(queues);
  avgRes1 = zeros(numFiles,numQueues);
  avgRes2 = zeros(numFiles,numQueues);
  num_time_steps = endTimeIdx - beginTimeIdx + 1;
  
  for iFile =1:numFiles
    logFile = files{iFile};
    [datetimes, queueNames, res1, res2] = importRealResUsageLog(logFile);
    
    usedRes1  = zeros(length(queues), num_time_steps);
    usedRes2  = zeros(length(queues), num_time_steps);
    queueIdxs = zeros(length(queues),num_time_steps);
    for i=1:length(queues)
      temp = find(strcmp(queueNames, ['root.' queues{i}]));      
      queueIdxs(i, 1:num_time_steps)= temp(beginTimeIdx:endTimeIdx);
      usedRes1(i,  1:num_time_steps) = res1(temp(beginTimeIdx:endTimeIdx));
      usedRes2(i,  1:num_time_steps) = res2(temp(beginTimeIdx:endTimeIdx));
    end
    avgRes1(iFile,:) = mean(usedRes1');
    avgRes2(iFile,:) = mean(usedRes2');
  end
end

