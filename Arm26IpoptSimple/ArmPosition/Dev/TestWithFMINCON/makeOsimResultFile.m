%%

logFileName='logfile_15-02-20-19-19-08.mat'

resData=load(logFileName);
fileName='arm26_IPOPT_RunWithOpenSimMuscleActivationResults.mot';
resultsName='arm26Opt';
data=resData.log285.modelResults.OutputData.data;
columnNames=resData.log285.modelResults.OutputData.labels;
inDegrees=resData.log285.modelResults.OutputData.inDegrees;
osSimpleStorage(fileName,resultsName,columnNames,data,inDegrees);

%%
logFileName='logfile_15-02-20-19-19-08.mat'

load(logFileName);

%%
for i=1:285
   eval(['d(i)=log' num2str(i) '.obj;']) 
end
figure
plot(d)
xlabel('Step #')
ylabel('Objective, Final Velocity (m/s)')

%%  Final Results Plot

data=log285.modelResults.OutputData.data;
t=data(:,1);
shoulderQ=data(:,2);
elbowQ=data(:,3);
labels=log285.modelResults.OutputData.labels;

figure
subplot(2,1,1)
plot(t,elbowQ/pi*180,'color',pcolors(1),'linewidth',2,'displayname','Elbow')
hold on
plot(t,shoulderQ/pi*180,'color',pcolors(2),'linewidth',2,'displayname','Shoulder')
legend('show','location','eastoutside')
legend boxoff
ylabel('Angle (deg)')

subplot(2,1,2)
for i=6:2:20
    lname=labels{i};
    n=strfind(lname,'.')-1;
    lname=lname(1:n);
    plot(t,data(:,i),'color',pcolors(i),'linewidth',2,'displayname',lname)
    hold on
end

ylabel('Muscle Activation')
xlabel('Time (sec)')
legend('show','location','eastoutside')
legend boxoff

