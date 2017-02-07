addpath('matlab_func');
common_settings;

workload='BB';
% workload='TPCDS';
% workload='TPCH';

fig_path = ['../../BPF/fig/'];

%%

% result_folder = ['result/20170127_multi/' workload '/']; 
result_folder = 'ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/'; 


%%
xlabels = {'LQ-0', 'LQ-1','LQ-2','TQ-0'}; 
queues = {'bursty0','bursty1','bursty2','batch0'};
% xlabels = {'LQ-0', 'LQ-1','LQ-2'};
% queues = {'bursty0','bursty1','bursty2'};
colorCellsExperiment = {colorDRF; colorStrict;  colorhard; colorProposed};

JOB_NUM = 500;
LQ0_range = 0:(JOB_NUM-1);
LQ1_range = (JOB_NUM):(JOB_NUM*2-1);
LQ2_range = (JOB_NUM*2):(JOB_NUM*3-1);
TQ0_range = 100000:200000;

if true  
  files = {'ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/b1i3_DRF_BB/users/tanle/SWIM/scriptsTest/workGenLogs/completion_time.csv';
      'ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/b1i3_Strict_BB/users/tanle/SWIM/scriptsTest/workGenLogs/completion_time.csv';
      'ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/b1i3_NBPF_BB/users/tanle/SWIM/scriptsTest/workGenLogs/completion_time.csv';
      'ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/b1i3_BPF_BB/users/tanle/SWIM/scriptsTest/workGenLogs/completion_time.csv'  };             
  methods = {'DRF','SP', 'N-BPF','BPF'};  
end


num_batch_queues = 1;
num_interactive_queue = 3;
num_queues = num_batch_queues + num_interactive_queue;
START_TIME = 0; END_TIME = 800;
is_printed = true;
cluster_size = 1000;

barColors = colorb1i3;

%%

figIdx = 0;
type = 2;

% fig_path = 'figs\';
%%
% global batchJobRange
% batchJobRange = [1:10]
maxY = 2100;
queues_len = length(queues);
plots  = [true, false];
improvements = zeros(queues_len, 4);
if plots(1) 
   
   [ LQ0_avg_time complTimes] = obtain_compl_time_queue( files, LQ0_range);
   [ LQ1_avg_time complTimes] = obtain_compl_time_queue( files, LQ1_range);
   [ LQ2_avg_time complTimes] = obtain_compl_time_queue( files, LQ2_range);
   [ TQ0_avg_time complTimes] = obtain_compl_time_queue( files, TQ0_range);
   
   avg_compl_times = [LQ0_avg_time; LQ1_avg_time; LQ2_avg_time; TQ0_avg_time]/1000;
   
   figure;
   scrsz = get(groot,'ScreenSize');   
   barChart = bar(avg_compl_times, 'group');
   
   maxVal = max(max(avg_compl_times));
   
   for i=1:length(barChart)
       barChart(i).FaceColor = colorCellsExperiment{i};
   end
   %title('Average completion time of interactive jobs','fontsize',fontLegend);
%    xLabel='number of batch queues';
    yLabel=strAvgComplTime;
    legendStr=methods;

    ylabel(yLabel,'FontSize',fontAxis);
    set(gca,'XTickLabel',xlabels,'FontSize',fontAxis);
    
    
    ylim([0 max(maxY,maxVal*1.05)]);
    xlim([0.5 4.5]);
    
    legend(legendStr,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');
    set (gcf, 'Units', 'Inches', 'Position', figSizeOneCol, 'PaperUnits', 'inches', 'PaperPosition', figSizeOneCol);
%     xlabel(xLabel,'FontSize',fontAxis);

   
   if is_printed
       figIdx=figIdx +1;
      fileNames{figIdx} = 'avg_multi_queues_impl';
      epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
   end
   
end

return;
%%

for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName '.pdf'];    
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end