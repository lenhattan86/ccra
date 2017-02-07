function [ avgComplTime complTimes] = obtain_compl_time_queue( files, JOB_IDS)

%     global batchJobRange

   num_files = length(files);
   avgComplTime = zeros(1,num_files);
   complTimes=cell(1, num_files);   
   for i=1:num_files
      filename = [files{i}];
      avgComplTime(i) = 0;
      if exist(filename, 'file')
          [jobIds,submitDatetime,startDatetime,runningTime,totalTime,endTimeStamp] = import_compl_time_02(filename);
          [temp indices] = intersect(jobIds,JOB_IDS);
         complTimes{i} =  runningTime(indices)';          
         
         if length(complTimes{i})>0            
            avgComplTime(i) = mean(complTimes{i});            
         end         
      end
   end    
end

