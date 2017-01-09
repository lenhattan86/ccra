addpath('func');
common_settings;

output_sufix = 'short/'; STEP_TIME = 1.0; 

% fig_path = ['../../EuroSys17/fig/'];

num_batch_queues = 8;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;
jobIdThreshold=100000;

plots = [true false true];

WORKLOAD = 'BB';

%%
subfolder = 'users/tanle/SWIM/scriptsTest/workGenLogs/'; 
csvFile = 'completion_time.csv'; type =1;
% csvFile = 'yarn_completion_time.csv'; type =2;

file = [subfolder csvFile];
drf_compl_files = {
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF_1x/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF_2x/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF_4x_new/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF_8x/' file]
              };

drfw_compl_files = {
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW/' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW/' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW/' file]
      };  

% speedfair_compl_files = { ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_1x/' file];
%                         ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_2x/' file];
%                         ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_4x/' file];
%                         ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_8x/' file]
%                     };
                  
speedfair_compl_files = { ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_1x_new/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_2x_new/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_4x_new/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_8x_new/' file]
                    };

strict_compl_files = {
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict_1x/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict_2x/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict_4x/' file];
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict_8x_new/' file]
          }; 
          
others = { 
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb1i1_Strict_tez/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb2i1_Strict_tez/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb4i1_Strict_tez/' file];
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb8i1_Strict_tez/' file]
          }; 
          
scaleUpFactors = {'1x' '2x' '4x' '8x'};


CDF_ids = [2, 3, 4, 5];
extra = '';
% extra = '';
%%

[ drf_busrty_avg_time burstyComplTimes drf_batch_avg_time drf_batchComplTimes drf_burstyMinMax drf_batchMinMax] = obtain_compl_time( drf_compl_files, jobIdThreshold, type, 0);
% [ drfw_avg_compl_time burstyComplTimes batchAvgTime drfw_batchComplTimes] = obtain_compl_time( drfw_compl_files, jobIdThreshold, type);
[ speedfair_busrty_avg_time burstyComplTimes speedfair_batch_avg_time speedfair_batchComplTimes  speedfair_burstyMinMax speedfair_batchMinMax] = obtain_compl_time( speedfair_compl_files, jobIdThreshold, type, 0);

[ strict_busrty_avg_time burstyComplTimes strict_batch_avg_time strict_batchComplTimes  strict_burstyMinMax strict_batchMinMax] = obtain_compl_time( strict_compl_files, jobIdThreshold, type, 0);

%[ other_avg_time burstyComplTimes strict_preempt_batch_avg_time batchComplTimes] = obtain_compl_time( others, jobIdThreshold, type);

%%  LQ jobs
if (plots(1))
   colorCellsExperiment = {colorDRF; colorStrict; colorProposed};
   busrty_time = [drf_busrty_avg_time ;  strict_busrty_avg_time; speedfair_busrty_avg_time] / 1000;
   figure;
   scrsz = get(groot,'ScreenSize');   
   barChart = bar(busrty_time', 'group','EdgeColor','none');
   
   for i=1:length(barChart)
       %barChart(i).LineWidth = barLineWidth;
%        barChart(i).EdgeColor = colorCellsExperiment{i};
       barChart(i).FaceColor = colorCellsExperiment{i};
   end
   
   %title('Average completion time of interactive jobs','fontsize',fontLegend);
   xLabel='scale up factor of LQ jobs';
    yLabel='completion time (seconds)';
    legendStr={strDRF, strStrict, strProposed};

    xLabels=scaleUpFactors;
    legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
    set (gcf, 'Units', 'Inches', 'Position', figSizeOneCol, 'PaperUnits', 'inches', 'PaperPosition', figSizeOneCol);
    xlabel(xLabel,'FontSize',fontAxis);
    xlim([0.5 length(scaleUpFactors)+0.5 ]);
    ylabel(yLabel,'FontSize',fontAxis);
    set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);
   
   if is_printed
       figIdx=figIdx +1;
      fileNames{figIdx} = 'long_busty';
      epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
   end
end

%% cdf of LQ jobs
if (plots(2))
    for i=1:length(CDF_ids)
        CDF_idx=CDF_ids(i);        
       [ burstyAvgTime drfBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( drf_compl_files(CDF_idx), jobIdThreshold, type,0);
       [ burstyAvgTime speedfairBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( speedfair_compl_files(CDF_idx), jobIdThreshold, type,0);
       [ burstyAvgTime strictBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( strict_compl_files(CDF_idx), jobIdThreshold, type,0);
       maxVal = 10;
       figure;
       scrsz = get(groot,'ScreenSize');      
       if(length(drfBurstyComplTimes)>0)
            xData = drfBurstyComplTimes/1000;
            [f,x]=ecdf(xData);   plot(x,f,'LineWidth',LineWidth); hold on;
            legendStr{1}=strDRF;
            maxVal = max(maxVal,max(xData)); 
       end   
       if(length(strictBurstyComplTimes)>0)
           xData = strictBurstyComplTimes/1000;
            [f,x]=ecdf(xData);   plot(x,f,'LineWidth',LineWidth); hold on;
            legendStr{2}=strStrict;
            maxVal = max(maxVal,max(xData));
       end
       if(length(speedfairBurstyComplTimes)>0)
           xData = speedfairBurstyComplTimes/1000;
            [f,x]=ecdf(xData);   plot(x,f,'LineWidth',LineWidth); hold on;
            legendStr{3}=strProposed;
            maxVal = max(maxVal,max(xData));
       end
%         maxVal = 700;
       %title('Average completion time of interactive jobs','fontsize',fontLegend);
       xLabel='completion time (seconds)';
       yLabel='cdf';
       xlim([0 maxVal]);

        legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
        set (gcf, 'Units', 'Inches', 'Position', figSizeOneCol, 'PaperUnits', 'inches', 'PaperPosition', figSize);
        xlabel(xLabel,'FontSize',fontAxis);
        ylabel(yLabel,'FontSize',fontAxis);
    %     set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);

       if is_printed
          figIdx=figIdx +1;
          fileNames{figIdx} = ['busty_perf_grt_cdf' int2str(scaleUpFactors(CDF_idx))];
          epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
            print ('-depsc', epsFile);
       end
    end
end

%% batch jobs
if (plots(3))
  %     batch_time = [drf_batch_avg_time ;  strict_batch_avg_time; speedfair_batch_avg_time] / 1000;
  batch_time = [drf_batch_avg_time ;  strict_batch_avg_time; speedfair_batch_avg_time]' / 1000;
  batch_min= [drf_batchMinMax(1,:) ;  strict_batchMinMax(1,:); speedfair_batchMinMax(1,:)]' / 1000;
  batch_max= [drf_batchMinMax(2,:) ;  strict_batchMinMax(2,:); speedfair_batchMinMax(2,:)]' / 1000;
  
  barData = batch_time;
  figure;
  scrsz = get(groot,'ScreenSize');   
  barChart = bar(barData, 'group','EdgeColor','none');   

  %title('Average completion time of interactive jobs','fontsize',fontLegend);

  for i=1:length(barChart)
  %barChart(i).LineWidth = barLineWidth;
  %        barChart(i).EdgeColor = colorCellsExperiment{i};
  barChart(i).FaceColor = colorCellsExperiment{i};
  end

  barLowerErr = barData-batch_min;
  barUpperErr= batch_max-barData;
  hold on; 
  numgroups = size(barData, 1); 
  numbars = size(barData, 2); 
  groupwidth = min(0.8, numbars/(numbars+1.5));
  for i = 1:numbars  
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        minMaxBarChart = errorbar(x, barData(:,i), barLowerErr(:,i), barUpperErr(:,i), colorBarMinMax, 'linestyle', 'none','linewidth',lineWidthBarMinMax);
  end

  xLabel='scale up factor of LQ jobs';
  yLabel='completion time (seconds)';
  legendStr={strDRF, strStrict, strProposed};

  xLabels=scaleUpFactors;
  legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
  set (gcf, 'Units', 'Inches', 'Position', figSizeOneCol, 'PaperUnits', 'inches', 'PaperPosition', figSizeOneCol);
  xlabel(xLabel,'FontSize',fontAxis);
  xlim([0.5 length(scaleUpFactors)+0.5 ]);
  ylabel(yLabel,'FontSize',fontAxis);
  set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);

  if is_printed
     figIdx=figIdx +1;
    fileNames{figIdx} = 'batch_perf_protect';
    epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
      print ('-depsc', epsFile);
  end
end


%%

%%
fileNames
return
%%

for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName '_' WORKLOAD extra '.pdf']    
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end