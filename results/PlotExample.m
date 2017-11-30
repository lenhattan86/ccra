addpath('func');
common_settings;
figIdx = 0;

STEP_TIME = 1.0; 

% fig_path = ['../../EuroSys17/fig/'];

is_printed = true;
numOfNodes = 40;
MAX_CPU = numOfNodes*32;
MAX_MEM = numOfNodes*64;
GB = 1024;
TB = 1024*1024;
extra='';

num_batch_queues = 1;
num_interactive_queue = 2;
num_queues = num_batch_queues + num_interactive_queue;

workload='BB';

enableSeparateLegend = true;

plots = [true true]; %DRF, DRF-W, Strict, SpeedFair

%%
if plots(1) 
  START_TIME = 1; END_TIME = 2600+START_TIME;  
  lengendStr = {'LQ A', 'LQ B',  'TQ D'};
  
  queues = cell(1,num_queues);
  for i=1:num_interactive_queue
      queues{i} = ['bursty' int2str(i-1)];      
  end
  for j=1:num_batch_queues
      queues{num_interactive_queue+j} = ['batch' int2str(j-1)];
  end
  method = '';  
  
  is_switch_res = false; % switch CPU to MEM.
  
  jobNum = 4;
  queueUpPeriod = 200;
  period = 600; 
%   method = 'BPF';  
   method = 'DRF';  
%  method = 'SP';  
%   method = 'Simple';  
  
  LQ1Demands = [1, 1/4];  
  
  LQ2Demands = [1, 3/4];
 
  start_time_step = START_TIME/STEP_TIME;
  max_time_step = END_TIME/STEP_TIME;
  startIdx = start_time_step*num_queues+1;
  endIdx = max_time_step*num_queues;
  num_time_steps = max_time_step-start_time_step+1;
  linewidth= 2;
  barwidth = 1.0;
  timeInSeconds = (START_TIME:STEP_TIME:END_TIME) - START_TIME;

  extraStr = ['_' int2str(num_interactive_queue) '_' int2str(num_batch_queues)];
  
  flag = true;
  
  temp = (start_time_step:max_time_step);
  if strcmp(method,'BPF')          
     usedMEM = zeros(length(queues),length(temp));     
     % batch job
     % LQ 1     
     stage1Period = LQ1Demands(2)*period;
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period+startTime) = MAX_MEM/GB;
     end   
     
     % LQ 2     
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(2, startTime:period+startTime) = MAX_MEM/GB/2;
     end   
     
     % TQ 0
     usedMEM(3, :) = MAX_MEM/GB;
     
   elseif strcmp(method,'DRF')
     usedMEM = zeros(length(queues),length(temp));
     
     % LQ 1     
     stage1Period = LQ1Demands(2)*period*3;
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period+startTime) = MAX_MEM/GB/3;
     end   
     
     % LQ 2     
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(2, startTime:stage1Period+startTime) = MAX_MEM/GB/3;       
       usedMEM(2, stage1Period+startTime+1:period+startTime) = MAX_MEM/GB/2;
     end   
     
     % TQ 0
     usedMEM(3, :) = MAX_MEM/GB;
     
   elseif strcmp(method,'SP')       
     usedMEM = zeros(length(queues),length(temp));     
     % LQ 1     
     stage1Period = LQ1Demands(2)*period;
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period+startTime) = MAX_MEM/GB/2;
     end   
     
     % LQ 2     
     stage2Period = LQ2Demands(2)*period;
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(2, startTime:stage1Period+startTime) = MAX_MEM/GB/2;  
       usedMEM(2, stage1Period+startTime+1:period+startTime) = MAX_MEM/GB;
     end   
     
     % TQ 0
     usedMEM(3, :) = MAX_MEM/GB;
   elseif strcmp(method,'BVT')       
     usedMEM = zeros(length(queues),length(temp));     
     % LQ 1     
     stage1Period = LQ1Demands(2)*period;
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(1, startTime:stage1Period+startTime) = MAX_MEM/GB/2;
     end   
     
     % LQ 2     
     stage2Period = LQ2Demands(2)*period;
     for j = 1:jobNum
       startTime = start_time_step + period*(j-1)+queueUpPeriod;
       usedMEM(2, startTime:stage1Period+startTime) = MAX_MEM/GB/2;  
       usedMEM(2, stage1Period+startTime+1:period+startTime) = MAX_MEM/GB;
     end   
     
     % TQ 0
     usedMEM(3, :) = MAX_MEM/GB;
   else
   end
   
   if (flag)  
      figure
%       subplot(2,1,2); 
      axes('linewidth',axisWidth,'box','on');      
      hold on;
      hBar = bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
      set(hBar,{'FaceColor'},colorb1i2); 
      
      ylabel('TB');xlabel('seconds');
      ylim([0 MAX_MEM/GB]);
      xlim([0 max(timeInSeconds)]);
      if ~enableSeparateLegend
        legend(lengendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');
      end
      set(gca,'FontSize',fontSize)     
      
      set (gcf, 'Units', 'Inches', 'Position', figSizeOneColHaflRow, 'PaperUnits', 'inches', 'PaperPosition', figSizeOneColHaflRow);     
      if is_printed   
        figIdx=figIdx +1;
        fileNames{figIdx} = ['b' int2str(num_interactive_queue) '_example_' method '_' workload extra];        
        epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
      end      
      
      %% create dummy graph with legends
      if enableSeparateLegend
        figure
        hBar = bar(timeInSeconds,usedMEM',barwidth,'stacked','EdgeColor','none');
        set(hBar,{'FaceColor'},colorb1i2);
        legend(lengendStr,'Location','southoutside','FontSize',fontLegend,'Orientation','horizontal');
        set(gca,'FontSize',fontSize);
        axis([20000,20001,20000,20001]) %move dummy points out of view
        axis off %hide axis  
        set(gca,'YColor','none');      
        set (gcf, 'Units', 'Inches', 'Position', legendSize, 'PaperUnits', 'inches', 'PaperPosition', legendSize);    
        
        if is_printed   
            figIdx=figIdx +1;
          fileNames{figIdx} = ['b' int2str(num_interactive_queue) '_example_legend'];        
          epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
          print ('-depsc', epsFile);
        end
      end
   end
end
%%
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