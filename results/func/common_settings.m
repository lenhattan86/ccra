clear; close all; clc;

fontAxis = 12;
fontTitle = 12;
fontLegend = 12;
LineWidth = 2;
FontSize = 12;
is_printed = true;

figSize = [0.0 0 5.0 3.0];

barLineWidth=0;

figIdx=0;

LOCAL_FIG = 'figs/';

PS_CMD_FORMAT='ps2pdf -dEmbedAllFonts#true -dSubsetFonts#true -dEPSCrop#true -dPDFSETTINGS#/prepress %s %s';

fig_path = ['figs/'];


strDRF = 'DRF';
strDRFW = 'DRF-W';
strStrict = 'Strict';
strProposed = 'SpeedFair';

colorDRF = 'blue';
colorDRFW = 'magenta';
colorStrict = 'yellow';
colorProposed = 'red';
colorCellsExperiment = {colorDRF, colorStrict, colorProposed};
colorArraySimulation = [colorDRF colorDRFW colorStrict colorProposed];



