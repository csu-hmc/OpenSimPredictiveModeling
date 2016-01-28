load('logfile_15-03-31-20-02-48','log539')

%%  Make the MOt File
addpath('E:\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')
optLogFileToMot(log539,'Trial1b.mot')

%% Make the Movie
% Go to Opensim and import the .mot and make movie

%% Now change the movie's duration
movieDuration('Trial1b.avi','Arm28PSO_Trial1b',2)


%% Plot Convergence
%Copy and paste then command line output into excel and delimit

load('trial2BConverge')

figure

plot(unnamed(:,1),'color',pcolors(1),'displayname','Population Min','linewidth',2)
hold on
plot(unnamed(:,2),'color',pcolors(2),'displayname','Population Average','linewidth',2)
xlabel('Generation')
ylabel('Objective, Negative Hand Velocity (m/s)')
%title('Arm28 PSO Trial1b (Place 1 Particle at Good Guess)')
legend show


%% Look at the particle with a good guess

load('logfile_15-03-31-20-02-48','log1')
optLogFileToMot(log1,'Trial1bGoodParticle.mot')


%% Plot Results in MATLAB

load('logfile_15-03-31-20-02-48','log541')


%%
%dataMat=data.modelResults.OutputData.data;
%columnNames=data.modelResults.OutputData.labels;

data=log541.modelResults.OutputData.data;
t=data(:,1);
shoulderQ=data(:,2);
elbowQ=data(:,3);
labels=log541.modelResults.OutputData.labels;

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




