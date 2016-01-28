function osMakeControlsFileSimple(fileName,columnNames,data,inDegrees)


%osMakeControlsFileSimple - Write an OpenSim Controls Input file
%
%  osMakeControlsFileSimple(fileName,columnNames,data,inDegrees)
%
% Input:
%   filename - name of file to be written
%   columnNames - the names of the columns to be written.  First column
%       should be 'time' and then each column should be the name of an
%       actuator.
%   data  - the data to be written.  First column is time values and each
%       column is an actuator
%   inDegrees - typically set to 0
%
%   Example:
%       a=[0 1;1,10];
%       osMakeControlsFilesimple('MycontrolFile.sto',{'time','Torq1'},a,0)


% Example Header
% controls
% version=1
% nRows=14
% nColumns=2
% inDegrees=no
% endheader
% time	Torq1
%       0.00000000	      1.00000000
%       0.01000000	      2.00000000

dlmwrite(fileName,'controls','delimiter','');
dlmwrite(fileName,'version=1','delimiter','','-append');
nR=num2str(size(data,1));
dlmwrite(fileName,['nRows=',nR],'delimiter','','-append');
nC=num2str(size(data,2));
dlmwrite(fileName,['nColumns=',nC],'delimiter','','-append');
if inDegrees
    dlmwrite(fileName,'inDegrees=yes','delimiter','','-append');
else
    dlmwrite(fileName,'inDegrees=no','delimiter','','-append');
end
dlmwrite(fileName,'endheader','delimiter','','-append');

columnNames{1}='time';
fid = fopen(fileName,'a');
for i=1:length(columnNames)-1
    fprintf(fid, '%s\t', columnNames{i});
end
fprintf(fid, '%s\n', columnNames{i+1});
dlmwrite(fileName,data,'precision','%16f','delimiter','\t','-append')

%type(fileName)