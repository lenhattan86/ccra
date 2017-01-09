function [ burstyAvgTime burstyComplTimes batchAvgTime batchComplTimes burstyMinMax batchMinMax] = obtain_compl_time( files, jobIdThreshold, type, numIgnoredBurstyJobs)

%     global batchJobRange

   num_files = length(files);
   burstyAvgTime = zeros(1,num_files);
   batchAvgTime = zeros(1,num_files);
   burstyMinMax = zeros(2,num_files);
   batchMinMax = zeros(2,num_files);
   burstyComplTimes=cell(1, num_files);
   batchComplTimes=cell(1, num_files);
   for i=1:num_files
      filename = [files{i}];
      burstyAvgTime(i) = 0;
      batchAvgTime(i)= 0;
      if exist(filename, 'file')
          if (type==1)
            if length(strfind(filename,'new'))>0
              [jobIds,startDatetime,startDatetime_2,runningTime,runningTime_2,endTimeStamp] = import_compl_time_01_new(filename);
            else
              [jobIds,startDatetime,startTimeStamp,runningTime,endTimeStamp] = import_compl_time_01(filename);
            end
          else
            [jobIds,submitDatetime,startDatetime,runningTime,totalTime,endTimeStamp] = import_compl_time_02(filename);
          end
          
         burstyComplTimes{i} =  runningTime(jobIds<jobIdThreshold)'; 
         batchComplTimes{i} = runningTime(jobIds>=jobIdThreshold)';
         
         if length(burstyComplTimes{i})>0
            burstyComplTimes{i} = burstyComplTimes{i}(1:length(burstyComplTimes{i})-numIgnoredBurstyJobs);
            burstyAvgTime(i) = mean(burstyComplTimes{i});
            burstyMinMax(1,i) = min(burstyComplTimes{i});        
            burstyMinMax(2,i) = max(burstyComplTimes{i});
         end
         if length(batchComplTimes{i})>0
            batchAvgTime(i) = mean(batchComplTimes{i}); 
            batchMinMax(1,i) = min(batchComplTimes{i});        
            batchMinMax(2,i) = max(batchComplTimes{i});
         end
      end
   end    
end

