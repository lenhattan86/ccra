addpath('func');
common_settings;
figIdx = 0;

STEP_TIME = 1.0; 

is_printed = false;
numOfNodes = 1;
MAX_CPU = numOfNodes*16;
MAX_MEM = numOfNodes*16;
GB = 1024;
extra='';

num_batch_queues = 1;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;


plots = [true false]; %DRF, DRF-W, Strict, SpeedFair

colorBars = cell(num_queues,1);
for i=1:num_queues
  colorBars{i} = colorb8i1{i};
end

%%
if plots(1) 
  START_TIME = 1; END_TIME = 200+START_TIME;    
  
  queues = cell(1,num_queues);
  lengendQueuesStr = cell(1,num_queues);
  for i=1:num_interactive_queue
      queues{i} = ['bursty' int2str(i-1)];
      lengendQueuesStr{i} = [strSQ '-' int2str(i-1)];
  end
  for j=1:num_batch_queues
      queues{num_interactive_queue+j} = ['batch' int2str(j-1)];
      lengendQueuesStr{num_interactive_queue+j} = [strTQ '-' int2str(j-1)];
  end
  method = '';  
  
  memFactor = 1;  

  result_folder=['/home/tanle/SWIM/scriptsTest/workGenLogs/'];  
  % result_folder = '/home/tanle/projects/BPFImpl/debug/cpu16/bopf_npreempt/workGenLogs/';
% result_folder = '/home/tanle/projects/BPFImpl/debug/cpu16/bopf/workGenLogs/';


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

  
   %logFile = [ logfolder 'SpeedFair-output' extraStr '.csv'];
   logFile = [ result_folder 'yarnUsedResources.csv'];
   [datetimes, queueNames, res1, res2, flag] = importRealResUsageLog(logFile); res2=res2./GB;
   if (flag)      
      usedCPUs= zeros(length(queues),num_time_steps);
      usedMEM= zeros(length(queues),num_time_steps);
      queueIdxs = zeros(length(queues),num_time_steps);
      for i=1:length(queues)
        temp = find(strcmp(queueNames, ['root.' queues{i}]));
        len = min(length(temp),max_time_step); 
        endIdx= len-start_time_step+1;
        queueIdxs(i,1:endIdx)=temp(start_time_step:len);
        usedCPUs(i,1:endIdx) = res1(temp(start_time_step:len));
        usedMEM(i,1:endIdx) = res2(temp(start_time_step:len))*memFactor;
      end
      
      figure;
      subplot(2,1,1); 
      hBar = bar(timeInSeconds,usedCPUs',barwidth,'stacked','EdgeColor','none');
%       set(hBar, {'FaceColor'}, colorBars); 
      ylabel('CPUs');xlabel('seconds');
      ylim([0 MAX_CPU]);
      xlim([0 max(timeInSeconds)]);
      legend(lengendQueuesStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
      title([method '- CPUs'],'fontsize',fontLegend);
      
      subplot(2,1,2); 
      hBar =bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
%       set(hBar,{'FaceColor'}, colorBars); 
      ylabel('GB');xlabel('seconds');
      ylim([0 MAX_MEM]);
      xlim([0 max(timeInSeconds)]);
      legend(lengendQueuesStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
      title([method '- Memory'],'fontsize',fontLegend);
      localFigSize = [0.0 0 10.0 7.0];
      set (gcf, 'Units', 'Inches', 'Position', localFigSize, 'PaperUnits', 'inches', 'PaperPosition', localFigSize);     
      if is_printed   
          figIdx=figIdx +1;
        fileNames{figIdx} = ['b' int2str(num_batch_queues) '_res_usage_' subFolder '_' workload extra];        
        epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
      end
   end
end