clear; 
addpath('func');
common_settings;

% plots = [true true true];
plots = [false false true];

output_sufix = 'short/'; STEP_TIME = 1.0; 

fig_path = ['../../BPF/fig/'];

num_batch_queues = 8;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;
jobIdThreshold=100000;

numIgnoredBurstyJobs = 1; % ignore the last jobs

%%
WORKLOAD='BB';
% WORKLOAD='TPC-DS';
% WORKLOAD='TPC-H';

%%
subfolder = 'users/tanle/SWIM/scriptsTest/workGenLogs/'; 
csvFile = 'completion_time.csv'; 
% csvFile = 'yarn_completion_time.csv'; type =2;
file = [subfolder csvFile];
if strcmp(WORKLOAD,'BB')
  type =1;
drf_compl_files = {
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b0i1/' file];
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRF_new/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_DRF/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_DRF/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF/' file]
              };

drfw_compl_files = {
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b0i1' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRFW' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_DRFW/' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_DRFW/' file];
        ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW/' file]
      };  

speedfair_compl_files = {['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b0i1/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_SpeedFair/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_SpeedFair/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_SpeedFair/' file];
                        ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair/' file]
                    };

strict_compl_files = {
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b0i1/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_Strict/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_Strict/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_Strict/' file];
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict/' file]
          }; 
          
others = { ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb0i1_Strict_tez/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb1i1_Strict_tez/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb2i1_Strict_tez/' file]; % yarn-drf
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb4i1_Strict_tez/' file];
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb8i1_Strict_tez/' file]
          }; 
elseif strcmp(WORKLOAD,'TPC-DS')
  type =1;
  drf_compl_files = {
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_DS/' file];
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRF_TPC_DS/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_DRF_TPC_DS/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_DRF_TPC_DS/' file];
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF_TPC_DS/' file]
              };

  drfw_compl_files = {
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_DS' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRFW_TPC_DS' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_DRFW_TPC_DS/' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_DRFW_TPC_DS/' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW_TPC_DS/' file]
        };  

  speedfair_compl_files = {['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_DS/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_SpeedFair_TPC_DS/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_SpeedFair_TPC_DS/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_SpeedFair_TPC_DS/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_TPC_DS/' file]
                      };

  strict_compl_files = {
              ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_DS/' file]; % yarn-drf
              ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_Strict_TPC_DS/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_Strict_TPC_DS/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_Strict_TPC_DS/' file];
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict_TPC_DS/' file]
            }; 

  others = { ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb0i1_Strict_tez_TPC_DS/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb1i1_Strict_tez_TPC_DS/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb2i1_Strict_tez_TPC_DS/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb4i1_Strict_tez_TPC_DS/' file];
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'runb8i1_Strict_tez_TPC_DS/' file]
            }; 
elseif strcmp(WORKLOAD,'TPC-H')
  type =1;
  drf_compl_files = {
                  ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_H/' file];
                  ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRF_TPC_H/' file];
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_DRF_TPC_H/' file];
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_DRF_TPC_H/' file];
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRF_TPC_H/' file]
                };

  drfw_compl_files = {
          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_H' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRFW_TPC_H' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_DRFW_TPC_H/' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_DRFW_TPC_H/' file];
          ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_DRFW_TPC_H/' file]
        };  

  speedfair_compl_files = {['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_H/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_SpeedFair_TPC_H/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_SpeedFair_TPC_H/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_SpeedFair_TPC_H/' file];
                          ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_SpeedFair_TPC_H/' file]
                      };

  strict_compl_files = {
              ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b0i1_TPC_H/' file]; % yarn-drf
              ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_Strict_TPC_H/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b2i1_Strict_TPC_H/' file]; % yarn-drf
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b4i1_Strict_TPC_H/' file];
            ['ctl.yarn-large.yarnrm-pg0.utah.cloudlab.us/' 'b8i1_Strict_TPC_H/' file]
            };
end
          
batchQueues = [0 1 2 4 8];
% figSize = figSizeOneCol;
% figSize = figSizeTwothirdCol;
colorCellsExperiment = {colorDRF; colorStrict; colorProposed};

CDF_ids = [2, 3, 4, 5];
extra = '';
% extra = '';
%%

[ drf_busrty_avg_time burstyComplTimes drf_batch_avg_time batchComplTimes drf_burstyMinMax drf_batchMinMax] = obtain_compl_time( drf_compl_files, jobIdThreshold, type, numIgnoredBurstyJobs);
% [ drfw_avg_compl_time burstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( drfw_compl_files, jobIdThreshold, type);
[ speedfair_busrty_avg_time burstyComplTimes speedfair_batch_avg_time batchComplTimes speedfair_burstyMinMax speedfair_batchMinMax] = obtain_compl_time( speedfair_compl_files, jobIdThreshold, type, numIgnoredBurstyJobs);

[ strict_busrty_avg_time burstyComplTimes strict_batch_avg_time batchComplTimes strict_burstyMinMax strict_batchMinMax] = obtain_compl_time( strict_compl_files, jobIdThreshold, type, numIgnoredBurstyJobs);

%[ other_avg_time burstyComplTimes strict_preempt_batch_avg_time batchComplTimes] = obtain_compl_time( others, jobIdThreshold, type);

%%  bursty jobs
if (plots(1))
  figSize = figSizeFourFifthCol;
   busrty_time = [drf_busrty_avg_time ;  strict_busrty_avg_time; speedfair_busrty_avg_time] / 1000;
   figure;
   scrsz = get(groot,'ScreenSize');  
   maxVal = max(max(busrty_time)); maxVal = ceil(maxVal/50)*50;
   barChart = bar(busrty_time', groupBarSize, 'group');
   ylim([0 maxVal]);
   
   latencyReductionFactors_2 = drf_busrty_avg_time./strict_busrty_avg_time
   latencyReductionFactors = drf_busrty_avg_time./speedfair_busrty_avg_time
   
   
   
   
   for i=1:length(barChart)
       %barChart(i).LineWidth = barLineWidth;
%        barChart(i).EdgeColor = colorCellsExperiment{i};
       barChart(i).FaceColor = colorCellsExperiment{i};
   end
   
   %title('Average completion time of interactive jobs','fontsize',fontLegend);
   xLabel='number of TQs';
    yLabel=strAvgComplTime;
    legendStr={strDRF, strStrict, strProposed};

    xLabels=batchQueues;
    legend(legendStr,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');    
    set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
    xlabel(xLabel,'FontSize',fontAxis);
    xlim([0.5 length(batchQueues)+0.5 ]);
    ylabel(yLabel,'FontSize',fontAxis);
    set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);
   
   if is_printed
       figIdx=figIdx +1;
      fileNames{figIdx} = ['busty_perf_grt_' WORKLOAD];
      epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
   end
end

%% cdf of bursty jobs
if (plots(2))
  figSize = figSizeHalfCol;
%     for i=1:length(CDF_ids)
  for i=3:4
        CDF_idx=CDF_ids(i);        
       [ burstyAvgTime drfBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( drf_compl_files(CDF_idx), jobIdThreshold, type,numIgnoredBurstyJobs);
       [ burstyAvgTime speedfairBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( speedfair_compl_files(CDF_idx), jobIdThreshold, type,numIgnoredBurstyJobs);
       [ burstyAvgTime strictBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( strict_compl_files(CDF_idx), jobIdThreshold, type,numIgnoredBurstyJobs);
       maxVal = 400;
       figure;
       scrsz = get(groot,'ScreenSize');      
       if(length(drfBurstyComplTimes{1})>0)
            xData = drfBurstyComplTimes{1}/1000;
            [f,x]=ecdf(xData);   plot(x,f,lineDRF,'LineWidth',LineWidth,'Color', colorDRF); hold on;
            legendStr{1}=strDRF;
            maxVal = max(maxVal,max(xData)); 
       end   
       if(length(strictBurstyComplTimes{1})>0)
           xData = strictBurstyComplTimes{1}/1000;
            [f,x]=ecdf(xData);   plot(x,f,lineStrict,'LineWidth',LineWidth,'Color', colorStrict); hold on;
            legendStr{2}=strStrict;
            maxVal = max(maxVal,max(xData));
       end
       if(length(speedfairBurstyComplTimes{1})>0)
           xData = speedfairBurstyComplTimes{1}/1000;
            [f,x]=ecdf(xData);   plot(x,f,lineProposed,'LineWidth',LineWidth,'Color', colorProposed); hold on;
            legendStr{3}=strProposed;
            maxVal = max(maxVal,max(xData));
       end
        maxVal = 650;
       %title('Average completion time of interactive jobs','fontsize',fontLegend);
       xLabel=strAvgComplTime;
       yLabel='cdf';
       xlim([0 maxVal]);

        legend(legendStr,'Location','best','FontSize',fontLegend,'Orientation','vertical');    
        set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
        xlabel(xLabel,'FontSize',fontAxis);
        ylabel(yLabel,'FontSize',fontAxis);
    %     set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);

       if is_printed
          figIdx=figIdx +1;
          fileNames{figIdx} = ['busty_perf_grt_cdf' int2str(batchQueues(CDF_idx)) '_' WORKLOAD];
          epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
            print ('-depsc', epsFile);
       end
    end
end

%% bursty jobs with error bars
if (plots(3))
  figSize = figSizeFourFifthCol;
     busrty_time = [drf_busrty_avg_time ;  strict_busrty_avg_time; speedfair_busrty_avg_time] / 1000;
  burty_time = [drf_busrty_avg_time ;  strict_busrty_avg_time; speedfair_busrty_avg_time]' / 1000;
  bursty_min= [drf_burstyMinMax(1,:) ;  strict_burstyMinMax(1,:); speedfair_burstyMinMax(1,:)]' / 1000;
  bursty_max= [drf_burstyMinMax(2,:) ;  strict_burstyMinMax(2,:); speedfair_burstyMinMax(2,:)]' / 1000;
  
  barData = burty_time;
  figure;
  scrsz = get(groot,'ScreenSize');   
  barChart = bar(barData,groupBarSize, 'group');   

  %title('Average completion time of interactive jobs','fontsize',fontLegend);

  for i=1:length(barChart)
  %barChart(i).LineWidth = barLineWidth;
  %        barChart(i).EdgeColor = colorCellsExperiment{i};
    barChart(i).FaceColor = colorCellsExperiment{i};
  end

  barLowerErr = barData-bursty_min;
  barUpperErr= bursty_max-barData;
  hold on; 
  numgroups = size(barData, 1); 
  numbars = size(barData, 2); 
  groupwidth = min(0.8, numbars/(numbars+1.5));
  for i = 1:numbars  
        x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
        minMaxBarChart = errorbar(x, barData(:,i), barLowerErr(:,i), barUpperErr(:,i), colorBarMinMax, 'linestyle', 'none','linewidth',lineWidthBarMinMax);
  end

   ylim([0 max(drf_burstyMinMax(2,:)/1000)]);
   
%    title('Average completion time of interactive jobs','fontsize',fontLegend);
    xLabel='number of TQs';
     yLabel=strAvgComplTime;
     legendStr={strDRF, strStrict, strProposed};
 
     xLabels=batchQueues;
     legend(legendStr,'Location','northwest','FontSize',fontLegend,'Orientation','horizontal');    
     set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
     xlabel(xLabel,'FontSize',fontAxis);
     xlim([0.5 length(batchQueues)+0.5 ]);
     ylabel(yLabel,'FontSize',fontAxis);
     set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);

  if is_printed
       figIdx=figIdx +1;
      fileNames{figIdx} = ['busty_perf_grt_err_' WORKLOAD];
      epsFile = [ LOCAL_FIG fileNames{figIdx} '.eps'];
        print ('-depsc', epsFile);
   end
end

%%
fileNames
return
%%

for i=1:length(fileNames)
    fileName = fileNames{i};
    epsFile = [ LOCAL_FIG fileName '.eps'];
    pdfFile = [ fig_path fileName extra '.pdf']    
    cmd = sprintf(PS_CMD_FORMAT, epsFile, pdfFile);
    status = system(cmd);
end
