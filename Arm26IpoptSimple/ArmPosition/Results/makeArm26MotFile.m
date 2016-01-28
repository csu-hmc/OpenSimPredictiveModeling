



% t=[0:0.01:2]';
% 
% shoulderT=[0 0.3 2];
% shoulderA=[0 -30 70]/180*pi;
% 
% elbowT=[0 0.3 2];
% elbowA=[20 10 60]/180*pi;
% 
% shoulderData=spline(shoulderT,shoulderA,t);
% elbowData=spline(elbowT,elbowA,t);
% 
% data=[t,shoulderData,elbowData];



d=log500;

data=d.modelResults.OutputData.data;
columnNames=d.modelResults.OutputData.labels;
fileName='OptRun2.mot';
resultsName='optRun';
inDegrees=0;
osSimpleStorage(fileName,resultsName,columnNames,data,inDegrees);