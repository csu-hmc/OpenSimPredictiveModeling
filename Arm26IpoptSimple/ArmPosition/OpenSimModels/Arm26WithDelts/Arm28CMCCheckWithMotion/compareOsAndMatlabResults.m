

% Load the opensim CMC results
[osData,osColumnNames]=osLoadMotFile('SimpleRunCMCOut.mot');

% Load the MATLAB integrator results
[matlabData,matlabColumnNames]=osLoadMotFile('arm26_IPOPT_RunWithOpenSimMuscleActivationResults.mot');

matlabData(:,2:5)=matlabData(:,2:5)*180/pi;

%%
figure

for i=2:21
    subplot(7,3,i-1)
    plot(matlabData(:,1),matlabData(:,i),'color','b')
    hold on
    plot(osData(:,1),osData(:,i),'color','r')
    strT=strrep(matlabColumnNames{i},'_',' ');
    if iseven(i)
    ylabel({'',strT})
    else
        ylabel({strT,''})
    end
    xlabel('Time (sec)')
end
%%
figure

subplot(2,2,1)
plot(matlabData(:,1),matlabData(:,2),'color','b')
hold on
plot(osData(:,1),osData(:,2),'color','r')
xlabel('Time (sec)')
ylabel('Shoulder Angle (deg)')

subplot(2,2,2)
plot(matlabData(:,1),matlabData(:,3),'color','b')
hold on
plot(osData(:,1),osData(:,3),'color','r')
xlabel('Time (sec)')
ylabel('Shoulder Velocity (deg/s)')


subplot(2,2,3)
plot(matlabData(:,1),matlabData(:,4),'color','b')
hold on
plot(osData(:,1),osData(:,4),'color','r')
xlabel('Time (sec)')
ylabel('Elbow Angle(deg)')


subplot(2,2,4)
plot(matlabData(:,1),matlabData(:,5),'color','b')
hold on
plot(osData(:,1),osData(:,5),'color','r')
xlabel('Time (sec)')
ylabel('Elbow Velocity (deg/s)')


%%
figure
muscleList={'Triceps Long ',...
    'Triceps Lat. ',...
    'Triceps Med. ',...
    'Bicep Med. ',...
    'Bicep Short ',...
    'Brachialis ',...
    'Deltoid Ant. ',...
    'Deltoid Post.'};

mn=1;
for k=6:21
    subplot(8,2,k-5)
    plot(matlabData(:,1),matlabData(:,k),'color','b')
    hold on
    plot(osData(:,1),osData(:,k),'color','r')
    
    if iseven(k)
        ylabel({muscleList{mn},'Activation'},'fontsize',10)
        set(gca,'ylim',[0 0.4])
    else
        ylabel({muscleList{mn},'Length (m)'},'fontsize',10)
        mn=mn+1;
    end
    
end

subplot(8,2,15)
xlabel('Time (sec)')


subplot(8,2,16)
xlabel('Time (sec)')