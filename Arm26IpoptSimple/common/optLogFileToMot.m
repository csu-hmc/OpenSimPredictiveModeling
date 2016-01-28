

function optLogFileToMot(data,motFileName,resultsName,inDegrees)

%optLogFileToMot- convert the output from an optimization run to a mot file
%that can be used by openSim.
%
%
%optLogFileToMot(data,motFileName,resultsName,inDegrees)
%       Inputs:
%               data - the data found in one of the results file.  The data
%                   is stored in the structure logXXX 
%               motFileName - name of mot file to be created
%               resultName - (optional, default is optRun) each mot file 
%                   gives the results a name.  
%               inDegrees - (optional, default is 0)
%
%       Outputs:
%               None
%
%   Example:
%       load('logfile_15-03-30-22-20-25','log587')
%       optLogFileToMot(log587,'pso587.mot')

if nargin <3
    resultsName='optRun';
end
if nargin<4
    inDegrees=0;
end

%d=log500;

dataMat=data.modelResults.OutputData.data;
columnNames=data.modelResults.OutputData.labels;
%fileName='OptRun2.mot';
osSimpleStorage(motFileName,resultsName,columnNames,dataMat,inDegrees);
