addpath('func');
common_settings;

plots = [true false false];

output_sufix = 'short/'; STEP_TIME = 1.0; 

% fig_path = ['../../EuroSys17/fig/'];

num_batch_queues = 8;
num_interactive_queue = 1;
num_queues = num_batch_queues + num_interactive_queue;
jobIdThreshold=100000;

numIgnoredBurstyJobs = 1; % ignore the last jobs

%%
% WORKLOAD='BB';
WORKLOAD='TPC-DS';
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
                ['ctl.yarn-drf.yarnrm-pg0.utah.cloudlab.us/' 'b1i1_DRF/' file];
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
  type =2;
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
  type =2;
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
figSize = [0.0 0 5.0 3.0];

CDF_ids = [2, 3, 4, 5];
extra = '';
% extra = '';
%%

[ drf_busrty_avg_time burstyComplTimes drf_batch_avg_time batchComplTimes] = obtain_compl_time( drf_compl_files, jobIdThreshold, type,numIgnoredBurstyJobs);
% [ drfw_avg_compl_time burstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( drfw_compl_files, jobIdThreshold, type);
[ speedfair_busrty_avg_time burstyComplTimes speedfair_batch_avg_time batchComplTimes] = obtain_compl_time( speedfair_compl_files, jobIdThreshold, type,numIgnoredBurstyJobs);

[ strict_busrty_avg_time burstyComplTimes strict_batch_avg_time batchComplTimes] = obtain_compl_time( strict_compl_files, jobIdThreshold, type,numIgnoredBurstyJobs);

%[ other_avg_time burstyComplTimes strict_preempt_batch_avg_time batchComplTimes] = obtain_compl_time( others, jobIdThreshold, type);

%%  bursty jobs
if (plots(1))
   busrty_time = [drf_busrty_avg_time ;  strict_busrty_avg_time; speedfair_busrty_avg_time] / 1000;
   figure;
   scrsz = get(groot,'ScreenSize');   
   barChart = bar(busrty_time', 'group','EdgeColor','none');
   
   latencyReductionFactors_2 = drf_busrty_avg_time./strict_busrty_avg_time
   latencyReductionFactors = drf_busrty_avg_time./speedfair_busrty_avg_time
   
   
   colorCellsExperiment = {colorDRF; colorStrict; colorProposed};
   
   for i=1:length(barChart)
       %barChart(i).LineWidth = barLineWidth;
%        barChart(i).EdgeColor = colorCellsExperiment{i};
       barChart(i).FaceColor = colorCellsExperiment{i};
   end
   
   %title('Average completion time of interactive jobs','fontsize',fontLegend);
   xLabel='number of batch queues';
    yLabel='completion time (seconds)';
    legendStr={strDRF, strStrict, strProposed};

    xLabels=batchQueues;
    legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
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
%     for i=1:length(CDF_ids)
  for i=3:4
        CDF_idx=CDF_ids(i);        
       [ burstyAvgTime drfBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( drf_compl_files(CDF_idx), jobIdThreshold, type,numIgnoredBurstyJobs);
       [ burstyAvgTime speedfairBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( speedfair_compl_files(CDF_idx), jobIdThreshold, type,numIgnoredBurstyJobs);
       [ burstyAvgTime strictBurstyComplTimes batchAvgTime batchComplTimes] = obtain_compl_time( strict_compl_files(CDF_idx), jobIdThreshold, type,numIgnoredBurstyJobs);
       maxVal = 10;
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
%         maxVal = 700;
       %title('Average completion time of interactive jobs','fontsize',fontLegend);
       xLabel='completion time (seconds)';
       yLabel='cdf';
       xlim([0 maxVal]);

        legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
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

%% batch jobs
if (plots(3))
%     batch_time = [drf_batch_avg_time ;  strict_batch_avg_time; speedfair_batch_avg_time] / 1000;
    batch_time = [drf_batch_avg_time ;  strict_batch_avg_time; speedfair_batch_avg_time] / 1000;
   figure;
   scrsz = get(groot,'ScreenSize');   
   barChart = bar(batch_time', 'group','EdgeColor','none');
   %title('Average completion time of interactive jobs','fontsize',fontLegend);
   
  for i=1:length(barChart)
   %barChart(i).LineWidth = barLineWidth;
%        barChart(i).EdgeColor = colorCellsExperiment{i};
    barChart(i).FaceColor = colorCellsExperiment{i};
  end
   
   xLabel='number of batch queues';
    yLabel='completion time (seconds)';
    legendStr={strDRF, strStrict, strProposed};

    xLabels=batchQueues;
    legend(legendStr,'Location','northoutside','FontSize',fontLegend,'Orientation','horizontal');    
    set (gcf, 'Units', 'Inches', 'Position', figSize, 'PaperUnits', 'inches', 'PaperPosition', figSize);
    xlabel(xLabel,'FontSize',fontAxis);
    xlim([1.5 length(batchQueues)+0.5 ]);
    ylabel(yLabel,'FontSize',fontAxis);
    set(gca,'XTickLabel',xLabels,'FontSize',fontAxis);
   
   if is_printed
       figIdx=figIdx +1;
      fileNames{figIdx} = ['batch_perf_protect_' WORKLOAD];
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