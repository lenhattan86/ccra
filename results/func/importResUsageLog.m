function [queueNames,res1,res2,flag] = importResUsageLog(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [BATCH0,VARNAME2,VARNAME3] = IMPORTFILE(FILENAME) Reads data from text
%   file FILENAME for the default selection.
%
%   [BATCH0,VARNAME2,VARNAME3] = IMPORTFILE(FILENAME, STARTROW, ENDROW)
%   Reads data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [batch0,VarName2,VarName3] = importfile('SpeedFair-output_1_4.csv',1, 250);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2016/11/10 11:05:40

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end


%% Open the text file.
if ~exist(filename, 'file')
   queueNames = 0;
   res1 = 0;
   res2 = 0;
   flag = false;
   return;
end
fileID = fopen(filename,'r');

%% Format string for each line of text:
%   column1: text (%s)
%	column2: double (%f)
%   column3: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
queueNames = dataArray{:, 1};
res1 = dataArray{:, 2};
res2 = dataArray{:, 3};
flag = true;

