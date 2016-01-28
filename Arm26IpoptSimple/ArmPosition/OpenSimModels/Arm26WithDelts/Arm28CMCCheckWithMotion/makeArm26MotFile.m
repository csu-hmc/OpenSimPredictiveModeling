



t=[0:0.01:2]';

shoulderT=[0 0.3 2];
shoulderA=[0 -30 70]/180*pi;

elbowT=[0 0.3 2];
elbowA=[20 10 60]/180*pi;

shoulderData=spline(shoulderT,shoulderA,t);
elbowData=spline(elbowT,elbowA,t);

data=[t,shoulderData,elbowData];

fileName='OptRun2.mot';
resultsName='optRun';
columnNames={'time','r_shoulder_elev','r_elbow_flex'};
inDegrees=0;
osSimpleStorage(fileName,resultsName,columnNames,data,inDegrees);