
%data=load ('../Results/logfile_15-01-05-22-06-52');

data=load ('../Results/logfile_15-01-12-15-21-20');

c=1;
log=data.log13;
labels=log.gradModelResultsOut.modelResults{c}.OutputData.labels;

%% Get the baseline



baseObj=log.gradModelResultsOut.modelResults{c}.objective;
baseConst=log.gradModelResultsOut.modelResults{c}.constraints;
baseData=log.gradModelResultsOut.modelResults{c}.OutputData.data;

r_shoulder_elevBase=baseData(:,2);
r_elbow_flexBase=baseData(:,3);
timeBase=baseData(:,1);

%% Get the gradient

gradObj=log.gradModelResultsOut.dModelResults{c}.objective;
gradConst=log.gradModelResultsOut.dModelResults{c}.constraints;
gradData=log.gradModelResultsOut.dModelResults{c}.OutputData.data;

r_shoulder_elevGrad=gradData(:,2);
r_elbow_flexGrad=gradData(:,3);
timeGrad=gradData(:,1);

%% Plot

figure
subplot(2,1,1)
plot(timeBase,r_shoulder_elevBase,'color',pcolors(1),'displayname','Base')
hold on
plot(timeGrad,r_shoulder_elevGrad,'color',pcolors(2),'displayname','Grad')
legend show

subplot(2,1,2)
plot(timeBase,r_elbow_flexBase,'color',pcolors(1),'displayname','Base')
hold on
plot(timeGrad,r_elbow_flexGrad,'color',pcolors(2),'displayname','Grad')

min_r_shoulder_elevBase=min(r_shoulder_elevBase);
min_r_shoulder_elevGrad=min(r_shoulder_elevGrad);
max_r_shoulder_elevBase=max(r_shoulder_elevBase);
max_r_shoulder_elevGrad=max(r_shoulder_elevGrad);

dMinShoulder=min_r_shoulder_elevGrad-min_r_shoulder_elevBase;
dMaxShoulder=max_r_shoulder_elevGrad-max_r_shoulder_elevBase;



% 
% subplot(3,1,3)
% plot(timeBase,r_shoulder_elevGrad-r_shoulder_elevBase,'color',pcolors(1),'displayname','Base')
% hold on
% plot(timeGrad,r_elbow_flexGrad-r_elbow_flexBase,'color',pcolors(2),'displayname','Grad')
% 

