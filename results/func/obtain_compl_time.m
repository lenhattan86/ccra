function [ burstyAvgTime burstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( files, jobIdThreshold, type)

%     global batchJobRange

   num_files = length(files);
   burstyAvgTime = zeros(1,num_files);
   batchAvgTime = zeros(1,num_files);
   burstyComplTimes=cell(1, num_files);
   batchComplTimes=cell(1, num_files);
   for i=1:num_files
      filename = [files{i}];
      burstyAvgTime(i) = 0;
      batchAvgTime(i)= 0;
      if exist(filename, 'file')
          if (type==1)
            [jobIds,startDatetime,startTimeStamp,runningTime,endTimeStamp] = import_compl_time_01(filename);
          else
            [jobIds,submitDatetime,startDatetime,runningTime,totalTime,endTimeStamp] = import_compl_time_02(filename);
          end
          
         burstyComplTimes{i} =  runningTime(jobIds<jobIdThreshold)'; 
         batchComplTimes{i} = runningTime(jobIds>=jobIdThreshold)';
         
         if length(burstyComplTimes{i})>0
            burstyAvgTime(i) = mean(burstyComplTimes{i});
         end
         if length(batchComplTimes{i})>0
            batchAvgTime(i) = mean(batchComplTimes{i});        
         end
      end
   end    
end

