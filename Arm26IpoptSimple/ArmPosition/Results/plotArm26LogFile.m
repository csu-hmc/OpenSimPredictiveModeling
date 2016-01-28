%plotArm26LogFile - script to plot each step in the IPOPT porcessing.  
% These steps are recorded into a logFile.

clear,close all

% Load the log file into variable logData
logData=load('logfile_15-03-11-15-41-12');

%runCnt=logData.m.runCnt;  %Number of Steps Completed


runCnt=length(fieldnames(logData))-1;  %Ugly way to get number of steps.

t=[0:0.1:2]';  %Time vector used in generating splines from controls

pHuge=[];  %Put all of the P values in one large matrix
for i=1:runCnt
%for i=1:203
    %There is a variable in the logData structure for each step:
    % logData.log1, logData.log2, logData.logX  where X is the step number
    varName=['logData.log',num2str(i)];
    eval(['tempValue=' varName ';']);  %Save into tempVariable for easy access
    
    %Get the objectives and constraints into arrays
    obj(i)=tempValue.modelResults.objective;
    constr(i,:)=tempValue.modelResults.constraints;
    
    %get the control values into an array
    %Ptemp=reshape(tempValue.P,3,8);   %Reshape from vector to matrix format
    Ptemp=tempValue.P;
    
    
    for m=1:8  %^ muscles in this model
        if i==1
            P{m}=Ptemp(:,m);
            muscleControls{m}=spline([0 0.2 1 2],Ptemp(:,m),t);
        else
            P{m}=[P{m} Ptemp(:,m)];
            muscleControls{m}=[muscleControls{m} spline([0 0.2 1 2],Ptemp(:,m),t)];
        end
    end
    pHuge=[pHuge;tempValue.P];
end

%% Create plot of Objectives and Constraints
figure
subplot(7,1,1)
plot(obj)
ylabel({'Objective Vertical Vel', '(m/s)'})

subplot(7,1,2)
plot(constr(:,1))
ylabel({'Horiz Vel Const.','[-0.001 0.001] (m/s)'})

% subplot(7,1,3)
% plot(constr(:,2))
% ylabel({'Hand Postion Const.','[0 Inf] (m)'})
% 
% subplot(7,1,4)
% plot(constr(:,3)*180/pi)
% ylabel({'Min Elbow','[15 130] (deg)'})
% xlabel('Step #')
% 
% 
% subplot(7,1,5)
% plot(constr(:,4)*180/pi)
% ylabel({'Max Elbow','[15 130] (deg)'})
% 
% subplot(7,1,6)
% plot(constr(:,5)*180/pi)
% ylabel({'Min Shoulder','[-70 160] (deg)'})
% 
% subplot(7,1,7)
% plot(constr(:,6)*180/pi)
% ylabel({'Max Shoulder','[-70 160] (deg)'})
% xlabel('Step #')


figH(1)=gcf;
%%  Create Muscle Plots
titleTxt=logData.log1.modelResults.OutputData.actuatorNames;
for r=1:8
    figH(r+1)=figure;
    mesh([1:size(muscleControls{r},2)],t,[muscleControls{r}])
    xlabel('Step #')
    ylabel('Time (sec)')
    zlabel('Muscle Activation')
    set(gca,'zlim',[0 1])
    title(titleTxt{r})
    
end

 %printpdf('results','l',0,figH)
 
 
%% Plot the results from a step

%stepToPlot=logData.log595;  %Change the variable name to change the step
stepToPlot=tempValue;  %Print the last step

namesOfChannels=stepToPlot.modelResults.OutputData.labels';
dataToPlot=stepToPlot.modelResults.OutputData.data;

figH(end+1)=figure
subplot(2,1,1)
plot(dataToPlot(:,1),dataToPlot(:,3)*180/pi);
ylabel('elbow (deg)')

subplot(2,1,2)
plot(dataToPlot(:,1),dataToPlot(:,2)*180/pi);
ylabel('shoulder (deg)')
xlabel(namesOfChannels{1})


