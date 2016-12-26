clear; close all; clc;

fontSize=12;

fontAxis = 12;
fontTitle = 12;
fontLegend = 12;
LineWidth = 2;
FontSize = 12;
is_printed = true;
axisWidth = 1.5;

legendSize = [0.0 0 5 0.3];
figSizeOneCol = [0.0 0 5 3];
figSizeOneColHaflRow = [1 1 1 0.5].* figSizeOneCol;
figSizeTwoCol = 2*figSizeOneCol;
figSizeOneThirdCol = 1/3*figSizeOneCol;
figSizeHalfCol = 1/2*figSizeOneCol;


barLineWidth=0;

figIdx=0;

LOCAL_FIG = 'figs/';

%PS_CMD_FORMAT='ps2pdf -dEmbedAllFonts#true -dSubsetFonts#true -dEPSCrop#true -dPDFSETTINGS#/prepress %s %s';
PS_CMD_FORMAT='ps2pdf -dEmbedAllFonts#true -dSubsetFonts#true -dEPSCrop#false -dPDFSETTINGS#/prepress %s %s';

fig_path = ['figs/'];


strDRF = 'DRF';
strDRFW = 'DRF-W';
strStrict = 'Strict';
strProposed = 'SpeedFair';

colorDRF = [0    0.4470    0.7410];
colorDRFW = [0.9290    0.6940    0.1250];
colorStrict = [0.4660    0.6740    0.1880];
colorProposed = [0.8500    0.3250    0.0980];
colorCellsExperiment = {colorDRF; colorStrict; colorProposed};
colorArraySimulation = [colorDRF colorDRFW colorStrict colorProposed];

colorBursty = 'red';
colorBatch = 'blue';
colorWasted = 'yellow';

colorBarMinMax='k';
lineWidthBarMinMax=1.5;

% colorBursty0 = [0    0.4470    0.7410];
colorBursty0 = [hex2dec('1f')    hex2dec('49')    hex2dec('7d')]/255;

% colorBatch0 = [0.8500    0.3250    0.0980];
colorBatch0 = [hex2dec('f7')    hex2dec('96')    hex2dec('46')]/255;
colorBatch1 = [0.9290    0.6940    0.1250];
colorBatch2 = [0.4940    0.1840    0.5560];
colorBatch3 = [0.4660    0.6740    0.1880];
colorBatch4 = [0.3010    0.7450    0.9330];
colorBatch5 = [0.6350    0.0780    0.1840];
colorBatch6 = [0.7500    0.7500         0];
colorBatch7 = [0.2500    0.2500    0.2500];

colorb8i1 = {colorBursty0; colorBatch0; colorBatch1; colorBatch2; colorBatch3; colorBatch4; colorBatch5; colorBatch6; colorBatch7};
colorb1i1 = {colorBursty0; colorBatch0};

%  0         0    1.0000
%          0    0.5000         0
%     1.0000         0         0
%          0    0.7500    0.7500
%     0.7500         0    0.7500
%     0.7500    0.7500         0
%     0.2500    0.2500    0.2500