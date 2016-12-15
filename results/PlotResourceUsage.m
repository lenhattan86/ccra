addpath('func');
common_settings;

output_sufix = 'short/'; STEP_TIME = 1.0; 

% fig_path = ['../../EuroSys17/fig/'];

num_batch_queues = 8;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;
START_TIME = 20; END_TIME = 1500+START_TIME;
is_printed = true;
numOfNodes = 40;
MAX_CPU = numOfNodes*32;
MAX_MEM = numOfNodes*32;
GB = 1024;
extra='';

queues = cell(1,num_queues);
for i=1:num_interactive_queue
    queues{i} = ['bursty' int2str(i-1)];
end
for j=1:num_batch_queues
    queues{num_interactive_queue+j} = ['batch' int2str(j-1)];
end
method = '';

% server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; method = 'SpeedFair';
% server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; method = 'SpeedFair_8x';
% server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; method = 'DRF';
% server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; method = 'DRF_8x';
% server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; method = 'Strict';
server='ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us'; method = 'Strict_8x';


%%
subfolder = ['b' int2str(num_batch_queues) 'i1_' method]; extra='';
if num_batch_queues==0
    method='';
    subfolder = ['b' int2str(num_batch_queues) 'i1'];
end
% subfolder = 'runb2i1'; extra='';
% method = 'SpeedFair'; subfolder = 'runb3i1_1201_bursty'; extra='';
% method = 'SpeedFair'; subfolder = 'runb3i1_1203_preemption_speedfair_200'; extra='_preemption';
% method = 'SpeedFair'; subfolder = 'runb3i1_1204_nonpreemption_speedfair_200'; extra='';
% method = 'SpeedFair'; subfolder = 'runb3i1_1203_preemption_speedfair'; extra='_preemption';
% method = 'SpeedFair'; subfolder = 'runb3i1_1203_preemption_speedfair_5x'; extra='_5x';

% method = '??'; subfolder = 'runb3i1'; extra='';
% method = 'Strict'; subfolder = 'runb3i1_1201_strict'; extra=''
% method = 'SpeedFair'; subfolder = 'runb3i1_1201_speedfair'; extra='';
%method = 'drf'; subfolder = 'runb3i1_1201_drf'; extra='';

% method = 'SpeedFair'; subfolder = 'runb3i1_1203_preemption'; extra='_preemption';

result_folder=['/home/tanle/projects/ccra/results/' server '/' subfolder '/users/tanle/SWIM/scriptsTest/workGenLogs/'];

% result_folder=['/home/tanle//projects/ccra/SWIM/scriptsTest/workGenLogs/']; method=''; MAX_CPU = 16; MAX_MEM = 16; END_TIME=500;

workload='BB';

%%
% result_folder = '../0_run_simple/'; workload='simple';
%result_folder = '../0_run_BB/'; workload='BB';
% result_folder = '../0_run_BB2/'; workload='BB2';
% result_folder = '../0_run_TPC-H/'; workload='TPC-H'; % weird
% result_folder = '../0_run_TPC-DS/'; workload='TPC-DS'; % okay 
% STEP_TIME = 1.0; output_sufix = '';
% fig_path = ['figs/' output_sufix]; 
% is_printed = true;




%%
output_folder = [result_folder 'output/'];

figIdx = 0;

% fig_path = 'figs\';
%%
% global batchJobRange
% batchJobRange = [1:10]

queues_len = length(queues);
plots  = [false, false];
improvements = zeros(queues_len, 4);
if plots(1) 
    INTERACTIVE_QUEUE = 'bursty';
   
   [ drf_avg_compl_time ] = obtain_compl_time( output_folder, drf_compl_files, INTERACTIVE_QUEUE);
   [ speedfair_avg_compl_time ] = obtain_compl_time( output_folder, speedfair_compl_files, INTERACTIVE_QUEUE);
   [ drfw_avg_compl_time ] = obtain_compl_time( output_folder, drfw_compl_files, INTERACTIVE_QUEUE);
   [ strict_priority_avg_compl_time ] = obtain_compl_time( output_folder, strict_priority_compl_files, INTERACTIVE_QUEUE);

   interactive_time = [drf_avg_compl_time ;  drfw_avg_compl_time; strict_priority_avg_compl_time; speedfair_avg_compl_time];
   improvements(:,1) = (interactive_time(1,:)-interactive_time(1,:))./interactive_time(1,:);
   improvements(:,2) = (interactive_time(2,:)-interactive_time(1,:))./interactive_time(1,:);
   improvements(:,3) = (interactive_time(3,:)-interactive_time(1,:))./interactive_time(1,:);
   improvements(:,4) = (interactive_time(4,:)-interactive_time(1,:))./interactive_time(1,:);
   improvements = improvements*100;
   
   figure;
   scrsz = get(groot,'ScreenSize');   
   bar(interactive_time', 'group');
   %title('Average completion time of interactive jobs','fontsize',fontLegend);
   xLabel='number of batch queues';
    yLabel='time (seconds)';
    legendStr={'DRF', 'DRF weight', 'strict priority', 'SpeedFair'};

    xLabels=queues;
    legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
    figSize = [0.0 0 5.0 3.0];
    set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
    xlabel(xLabel,'FontSize',fontAxis);
    ylabel(yLabel,'FontSize',fontAxis);
    set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);
   
   if is_printed
       figIdx=figIdx +1;
      fileNames{figIdx} = 'interactive_compl_time';
      epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
   end
end
if plots(2) 
   %%
   BATCH_QUEUE = 'batch';
   [ drf_avg_compl_time ] = obtain_compl_time( output_folder, drf_compl_files, BATCH_QUEUE);
   [ speedfair_avg_compl_time ] = obtain_compl_time( output_folder, speedfair_compl_files, BATCH_QUEUE);
   [ drfw_avg_compl_time ] = obtain_compl_time( output_folder, drfw_compl_files, BATCH_QUEUE);
   [ strict_priority_avg_compl_time ] = obtain_compl_time( output_folder, strict_priority_compl_files, BATCH_QUEUE);

   batch_time = [drf_avg_compl_time ; drfw_avg_compl_time; strict_priority_avg_compl_time; speedfair_avg_compl_time];

   figure;
   
   bar(batch_time', 'group');
   xLabel='number of batch queues';
    yLabel='time (seconds)';
    legendStr={'DRF', 'DRF weight', 'strict priority', 'SpeedFair'};

    xLabels=queues;
    legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
    figSize = [0.0 0 5.0 3.0];
    set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
    xlabel(xLabel,'FontSize',fontAxis);
    ylabel(yLabel,'FontSize',fontAxis);
    set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);
   % ylim([0 6]);   
   if is_printed    
       figIdx=figIdx +1;
      fileNames{figIdx} = 'batch_compl_time';      
      epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
   end

end
%%
plots = [true]; %DRF, DRF-W, Strict, SpeedFair
logfolder = [result_folder];

start_time_step = START_TIME/STEP_TIME;
max_time_step = END_TIME/STEP_TIME;
startIdx = start_time_step*num_queues+1;
endIdx = max_time_step*num_queues;
num_time_steps = max_time_step-start_time_step+1;
linewidth= 2;
barwidth = 1.0;
timeInSeconds = (START_TIME:STEP_TIME:END_TIME) - START_TIME;


% extraStr = '';
extraStr = ['_' int2str(num_interactive_queue) '_' int2str(num_batch_queues)];
   
%%
if plots(1)   
   %logFile = [ logfolder 'SpeedFair-output' extraStr '.csv'];
   logFile = [ logfolder 'yarnUsedResources.csv'];
   [datetimes, queueNames, res1, res2, flag] = importRealResUsageLog(logFile); res2=res2./GB;
   if (flag)
      lengendStr = queues;
      usedCPUs= zeros(length(queues),num_time_steps);
      usedMEM= zeros(length(queues),num_time_steps);
      queueIdxs = zeros(length(queues),num_time_steps);
      for i=1:length(queues)
        temp = find(strcmp(queueNames, ['root.' queues{i}]));
        len = min(length(temp),max_time_step); 
        endIdx= len-start_time_step+1;
        queueIdxs(i,1:endIdx)=temp(start_time_step:len);
        usedCPUs(i,1:endIdx) = res1(temp(start_time_step:len));
        usedMEM(i,1:endIdx) = res2(temp(start_time_step:len));
      end
      
      figure;
      subplot(2,1,1); 
      bar(timeInSeconds,usedCPUs',barwidth,'stacked','EdgeColor','none');
      ylabel('CPUs');xlabel('seconds');
      ylim([0 MAX_CPU]);
      xlim([0 max(timeInSeconds)]);
      legend(lengendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
      title([method '- CPUs'],'fontsize',fontLegend);
      
      subplot(2,1,2); 
      bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
      ylabel('GB');xlabel('seconds');
      ylim([0 MAX_MEM]);
      xlim([0 max(timeInSeconds)]);
      legend(lengendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
      title([method '- Memory'],'fontsize',fontLegend);
      
      figSize = [0.0 0 10.0 7.0];
      set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);     
      if is_printed   
          figIdx=figIdx +1;
        fileNames{figIdx} = ['b' int2str(num_batch_queues) '_res_usage_' method '_' workload extra];        
        epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
      end
   end
end

% if is_printed
%    pause(30);
%    close all;
% end
fileNames
return;
%%

for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName  '.pdf']    
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end