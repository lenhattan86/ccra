addpath('func');
common_settings;
figIdx = 0;

STEP_TIME = 1.0; 

fig_path = ['../../BPF/fig/'];

%%
%   server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'multi_LQs_DRF'; method = 'DRF';
%  server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'multi_LQs_BPF'; method = 'BPF';
%  server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'multi_LQs_Strict'; method = 'SP';
%  server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'multi_LQs_NBPF'; method = 'N-BPF';

%%
%  server='ctl.yarn-large.yarnrm-pg0.clemson.cloudlab.us'; subFolder = 'multi_LQs_BPF'; method = 'BPF';
%% % 4x number tasks but 1/4x resource demand
%    server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_BPF_BB_unofficial'; method = 'BPF';
%    server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_NBPF_BB_unofficial'; method = 'N-BPF';
%     server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_Strict_BB_unofficial'; method = 'SP';
%         server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_DRF_BB_unofficial'; method = 'DRF';
%% final version
%    server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_BPF_BB'; method = 'BPF';
%    server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_NBPF_BB'; method = 'N-BPF';
%     server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_Strict_BB'; method = 'SP';
  server='ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us'; subFolder = 'b1i3_DRF_BB'; method = 'DRF';
%%
%  server='~/SWIM'; subFolder = 'multi_LQs_DRF'; method = 'DRF';
result_folder=['/home/tanle/projects/BPFImpl/results/' server '/' subFolder '/users/tanle/SWIM/scriptsTest/workGenLogs/'];

is_printed = true;
numOfNodes = 40;
if numOfNodes==1
    MAX_CPU = numOfNodes*13;
    MAX_MEM = MAX_CPU*2;
    result_folder = '/home/tanle/SWIM/scriptsTest/workGenLogs/';
end

MAX_CPU = numOfNodes*32;
MAX_MEM = numOfNodes*64;
GB = 1024;
TB = 1024*1024;
extra='';

num_batch_queues = 1;
num_interactive_queue = 3;
num_queues = num_batch_queues + num_interactive_queue;

workload='BB';

enableSeparateLegend = true;

plots = [true true]; %DRF, DRF-W, Strict, SpeedFair

figureSize = [1 1 4/5 4/5].* figSizeOneCol;
legendSize = [1 1 4/5 1] .* legendSize;

%%
if plots(1) 
  START_TIME = 1; END_TIME = 1000+START_TIME;  
  lengendStr = {'LQ-0','LQ-1','LQ-2', 'TQ-0'};
  
  queues = cell(1,num_queues);
  for i=1:num_interactive_queue
      queues{i} = ['bursty' int2str(i-1)];      
  end
  for j=1:num_batch_queues
      queues{num_interactive_queue+j} = ['batch' int2str(j-1)];
  end  
  
  is_switch_res = false; % switch CPU to MEM.

  start_time_step = START_TIME/STEP_TIME;
  max_time_step = END_TIME/STEP_TIME;
  startIdx = start_time_step*num_queues+1;
  endIdx = max_time_step*num_queues;
  num_time_steps = max_time_step-start_time_step+1;
  linewidth= 2;
  barwidth = 1.0;
  timeInSeconds = (START_TIME:STEP_TIME:END_TIME) - START_TIME;
  
  extraStr = [ 'res_usage_b' int2str(num_batch_queues) 'i' int2str(num_interactive_queue)];
  
   if strcmp(method,'Optimum')
     flag = true;
     temp = (start_time_step:max_time_step);
     usedMEM = zeros(length(queues),length(temp));
     % batch jobs
     usedMEM(2,:) = MAX_MEM/GB;
     % stage 1 for first 2 jobs - bursty 
     jobNum1 = 2;
     for j = 1:jobNum1
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period+startTime) = MAX_MEM/GB;
     end
     
     % stage 2 for 2 last jobs
     jobNum = 2;
%      stage1Period2 = period/2;
     stage1Period2 = 300;
     % stage 1 for first 2 jobs - bursty 
     jobNum2 = 2+jobNum1;
     for j = 3:jobNum2
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period2+startTime) = MAX_MEM/GB;
     end
     for j = 1:2
       startTime = start_time_step + period*(j+1)+queueUpPeriod;
       stage2Res = period*MAX_MEM/2-stage1Period2*MAX_MEM;
       usedMEM(1, startTime+stage1Period2:period+startTime) = stage2Res/GB/(period-stage1Period2);
     end     
   else
    logFile = [ result_folder 'yarnUsedResources.csv'];
    [datetimes, queueNames, res1, res2, flag] = importRealResUsageLog(logFile); res2=res2./TB;
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
        if(is_switch_res)
          usedMEM(i,1:endIdx) = res1(temp(start_time_step:len))/1280*2.5;
        end
      end
   end
   
   if (flag)  
      figure;
      subplot(2,1,1); 
      hBar = bar(timeInSeconds,usedCPUs',barwidth,'stacked','EdgeColor','none');
      set(hBar,{'FaceColor'},colorb1i3);
      ylabel('CPUs');xlabel('seconds');
      ylim([0 MAX_CPU]);
      xlim([0 max(timeInSeconds)]);      
%       title([method '- CPUs'],'fontsize',fontLegend);      
      
      subplot(2,1,2);       
      hBar = bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');      
      set(hBar,{'FaceColor'},colorb1i3);       
      ylabel('TB');xlabel('seconds');
      ylim([0 MAX_MEM/GB]);
      xlim([0 max(timeInSeconds)]);      
      
      set(gca,'FontSize',fontSize)     
      
      set (gcf, 'Units', 'Inches', 'Position', figureSize, 'PaperUnits', 'inches', 'PaperPosition', figureSize);     
      if is_printed   
        figIdx=figIdx +1;
        fileNames{figIdx} = [extraStr '_' method '_' workload extra];        
        epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
      end
      
      
      %% create dummy graph with legends
      if enableSeparateLegend
        figure
        hBar = bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
        set(hBar,{'FaceColor'},colorb1i3);
        legend(lengendStr,'Location','southoutside','FontSize',fontLegend,'Orientation','horizontal');
        set(gca,'FontSize',fontSize);
        axis([20000,20001,20000,20001]) %move dummy points out of view
        axis off %hide axis  
        set(gca,'YColor','none');      
        set (gcf, 'Units', 'Inches', 'Position', legendSize, 'PaperUnits', 'inches', 'PaperPosition', legendSize);    
        
        if is_printed   
            figIdx=figIdx +1;
          fileNames{figIdx} = [extraStr '_legend'];        
          epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
          print ('-depsc', epsFile);
        end
      end
   end
end

fileNames
%%
return;
%%

for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName  '.pdf']    
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end