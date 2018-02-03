clc; clear; close all;
common_settings;
SUBMIT_TYPE=0;
FINISH_TYPE=4;

% JOB_FILE = 'jobInfo_full.csv';
% JOB_USAGE = 'jobResusage.csv';
JOB_FILE = 'jobInfo.mat';
JOB_USAGE = 'jobResUsage.mat';


 %[jobIds,submitTime,finishTime,scheduleClass,VarName5] = importParsedJobInfo(JOB_FILE); 
 load(JOB_FILE);
 jobIds = JobInfos(:,1);
 submitTime = JobInfos(:,2);
 finishTime = JobInfos(:,3);
 scheduleClass = JobInfos(:,4);
 
 complTimes = finishTime - submitTime; % microsecond
 
 temp = [jobIds complTimes/10^6 scheduleClass];
 % get rid of the jobs that are not finished.

 jobInfos = temp( find(complTimes >= 0),:);
 %jobInfos = temp;
 
%% 

is_printed = true;

fig_path = ['figs/'];
plots = [ true true true true];

figSize = figSizeFourFifthCol;

%%
if(plots(1))  
  figure
  MAX_DUR = max(jobInfos(:,2));
  [f,x]=ecdf(jobInfos(:,2));
  plot(x,f, 'LineWidth',LineWidth);
  hold on;

  legendStr = 'Google';
  legend(legendStr,'Location','southeast','FontSize',fontLegend,'Orientation','vertical');

  xLabel='job completion time (secs)';
  yLabel='cdf';

  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize',fontAxis);
  ylabel(yLabel,'FontSize',fontAxis);
  xlim([0 MAX_DUR/100]);
  set(gca,'FontSize',fontAxis);

  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'google_cdf';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
  
  %%
  figure
  hist(submitTime/(10^6), 100);

  xLabel='arrival time (secs)';
  yLabel='Number of jobs';

  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize', fontAxis);
  ylabel(yLabel,'FontSize', fontAxis);
  set(gca,'FontSize', fontAxis);

  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'arrival_time_his';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
end

%%
if(plots(2))  
  figure
  numClasses = 4;
  jobsPerClasses = zeros(1,numClasses);
  for (i=1:numClasses)
    jobsPerClasses(i) = length(find(jobInfos(:,3) == (i-1)));
  end
  
  bar(jobsPerClasses);
  
  xLabel='class (1: non-production <-> 4:  latency)';
  yLabel='Number of jobs';
  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize',fontAxis);
  ylabel(yLabel,'FontSize',fontAxis);
  set(gca,'FontSize',fontAxis);
  
  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'jobs_per_class';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
end

%%

%[jobIds,cpu,ram,disk] = importResUsage(JOB_USAGE);
load(JOB_USAGE);
jobIds=JobInfos(:,1);
cpu=JobInfos(:,2);
ram=JobInfos(:,3);
disk=JobInfos(:,4);

if(plots(3))  
  figure
  MAX_CPU = max(cpu);
  [f,x]=ecdf(cpu);
  plot(x,f, 'LineWidth',LineWidth);
  hold on;

  legendStr = 'Google';
  legend(legendStr,'Location','southeast','FontSize',fontLegend,'Orientation','vertical');
  xLabel='normalize cpu (1 = cpu of a node)';
  yLabel='cdf';
  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize',fontAxis);
  ylabel(yLabel,'FontSize',fontAxis);
  xlim([0 200]);
  set(gca,'FontSize',fontAxis);

  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'google_cpu';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
  %
  
  figure
  MAX_ram = max(ram);
  [f,x]=ecdf(ram);
  plot(x,f, 'LineWidth',LineWidth);
  hold on;

  legendStr = 'Google';
  legend(legendStr,'Location','southeast','FontSize',fontLegend,'Orientation','vertical');
  xLabel='normalize memory (1=ram of a node)';
  yLabel='cdf';
  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize',fontAxis);
  ylabel(yLabel,'FontSize',fontAxis);
  xlim([0 200]);
  set(gca,'FontSize',fontAxis);

  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'google_mem';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
  
end

%% convert to pdf
return;
for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName '.pdf']   
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end
