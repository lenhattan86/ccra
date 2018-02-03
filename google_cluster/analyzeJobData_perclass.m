clc; clear; close all;
common_settings;
JOB_FILE = 'jobInfo.mat';
JOB_USAGE = 'jobResUsage.mat';

load(JOB_FILE);
%JobInfos
allJobInfo = JobInfos;
jobIds = JobInfos(:,1);
scheduleClass =JobInfos(:,4);
complTimes = JobInfos(:,3) - JobInfos(:,2); % microsecond
 
 
 temp = [jobIds complTimes/10^6 scheduleClass];
 % get rid of the jobs that are not finished.
jobComplInfos = temp(find(complTimes > 0),:);
 %%
 load(JOB_USAGE); 
 jobUsage = JobInfos;
 
%% 
is_printed = true;

fig_path = ['figs/'];
plots = [ true true true true];

figSize = figSizeFourFifthCol;
%%
% get cpu & mem usage of each scheduling class

for i=1:4
  class = find(allJobInfo(:,4) == (i-1));
  jobs = allJobInfo(class,1);
  temp = ismember(jobUsage(:,1),jobs); 
  jobsUsageArray{i} = jobUsage(temp,:);
  class = find(jobComplInfos(:,3) == (i-1));
  jobInfoArray{i} = jobComplInfos(class,:);
end

%%
if(plots(1))  
  figure
  for i=1:4
    cpu = jobsUsageArray{i}(:,2);
    [f,x]=ecdf(cpu);
    plot(x,f, 'LineWidth',LineWidth);
    hold on;
  end

  legendStr = {'class 0', 'class 1', 'class 2', 'class 3'};
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
     fileNames{figIdx} = 'google_cpu_cdf';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
end

%%
if(plots(1))  
  figure
  for i=1:4
    mem = jobsUsageArray{i}(:,2);
    [f,x]=ecdf(mem);
    plot(x,f, 'LineWidth',LineWidth);
    hold on;
  end

  legendStr = {'class 0', 'class 1', 'class 2', 'class 3'};
  legend(legendStr,'Location','southeast','FontSize',fontLegend,'Orientation','vertical');
  xLabel='normalize mem (1 = mem of a node)';
  yLabel='cdf';
  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize',fontAxis);
  ylabel(yLabel,'FontSize',fontAxis);
  xlim([0 200]);
  set(gca,'FontSize',fontAxis);

  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'google_mem_cdf';
     epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
     print ('-depsc', epsFile);
  end
end

%%
if(plots(2))  
   figure
  for i=1:4
    %compl = (jobInfoArray{i}(:,3)-jobInfoArray{i}(:,2))/10^6;
    [f,x]=ecdf(jobInfoArray{i}(:,2));
    plot(x,f, 'LineWidth',LineWidth);
    hold on;
  end

  legendStr = {'class 0', 'class 1', 'class 2', 'class 3'};
  legend(legendStr,'Location','southeast','FontSize',fontLegend,'Orientation','vertical');
  xLabel='compl. (secs)';
  yLabel='cdf';
  set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
  xlabel(xLabel,'FontSize',fontAxis);
  ylabel(yLabel,'FontSize',fontAxis);
  xlim([0 2000]);
  set(gca,'FontSize',fontAxis);

  if is_printed
     figIdx=figIdx +1;
     fileNames{figIdx} = 'google_compl_cdf';
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
