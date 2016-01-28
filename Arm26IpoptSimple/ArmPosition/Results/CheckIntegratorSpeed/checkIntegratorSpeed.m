%plotArm26LogFile - script to plot each step in the IPOPT porcessing.  
% These steps are recorded into a logFile.

clear,close all

% Load the log file into variable logData
logData15s=load('logFileBaseLineOde15s');
logData23=load('logFileBaselineOde23');

runCnt15s=logData15s.m.runCnt;  %Number of Steps Completed
runCnt23=logData23.m.runCnt;  %Number of Steps Complet


for i=1:runCnt15s
    %There is a variable in the logData structure for each step:
    % logData.log1, logData.log2, logData.logX  where X is the step number
    varName=['logData15s.log',num2str(i)];
    eval(['tempValue=' varName ';']);  %Save into tempVariable for easy access
    
    %Get the objectives and constraints into arrays
    obj15s(i)=tempValue.modelResults.objective;
    constr15s(i,:)=tempValue.modelResults.constraints;
    
    time15s(i)=tempValue.time;
    
    fType15s(i)=tempValue.functionType;
    p15s(i,:)=tempValue.P;
    
end


for i=1:runCnt23
    %There is a variable in the logData structure for each step:
    % logData.log1, logData.log2, logData.logX  where X is the step number
    varName=['logData23.log',num2str(i)];
    eval(['tempValue=' varName ';']);  %Save into tempVariable for easy access
    
    %Get the objectives and constraints into arrays
    obj23(i)=tempValue.modelResults.objective;
    constr23(i,:)=tempValue.modelResults.constraints;
    time23(i)=tempValue.time;
    
        fType23(i)=tempValue.functionType;
        
        p23(i,:)=tempValue.P;
end


%% Create plot of Objectives and Constraints
figure
subplot(4,1,1)
plot(obj15s,'b')
hold on
plot(obj23,'r','linestyle','-.')
ylabel({'Objective Vertical Vel', '(m/s)'})
legend('ode15s','ode23')

subplot(4,1,2)
plot(constr15s(:,1),'b')
hold on
plot(constr23(:,1),'r','linestyle','-.')
ylabel({'Horiz Vel Const.','[-0.001 0.001] (m/s)'})

subplot(4,1,3)
plot(constr15s(:,2),'b')
hold on
plot(constr23(:,2),'r','linestyle','-.')
ylabel({'Hand Postion Const.','[0 Inf] (m)'})

subplot(4,1,4)
plot(constr15s(:,3),'b')
hold on
plot(constr23(:,3),'r','linestyle','-.')
ylabel({'Elbow Angle Const.','[0 3.14] (rad)'})
xlabel('Step #')

figH(1)=gcf;


%% Create a plot of Elapsed Time vs Step #

%Calculate total Elpased Time
stepElapsed15s=(time15s(1:250)-time15s(1))*1440;
stepElapsed23=(time23(1:250)-time23(1))*1440;

%Calculate durataion of each step
stepDuration15s=[0 diff(stepElapsed15s)];
stepDuration23=[0 diff(stepElapsed23)];

figure
plot(stepElapsed15s,'r'); %*1440: convert days to minutes
hold on;
plot(stepElapsed23,'b')
legend('ode15s','ode23')
xlabel('Step #')
ylabel('Elapsed Time (min)')

%%  Plot Duration of Each Step

i15sObjEval1=find(fType15s(1:250)==1);
i15sObjEval2=find(fType15s(1:250)==2);
i15sObjEval3=find(fType15s(1:250)==3);
i15sObjEval4=find(fType15s(1:250)==4);

figure
subplot(2,1,1)
plot(i15sObjEval1,stepDuration15s(i15sObjEval1),'linestyle','none','marker','.','color','b','markersize',20,'displayname','Obj');
hold on
plot(i15sObjEval2,stepDuration15s(i15sObjEval2),'linestyle','none','marker','.','color','r','markersize',20,'displayname','Obj Grad');
plot(i15sObjEval3,stepDuration15s(i15sObjEval3),'linestyle','none','marker','.','color','m','markersize',20,'displayname','Const');
plot(i15sObjEval4,stepDuration15s(i15sObjEval4),'linestyle','none','marker','.','color','c','markersize',20,'displayname','Const Jacob');
ylabel({'ode15s';'Step Duration (min)'});
legend show

i23ObjEval1=find(fType23(1:250)==1);
i23ObjEval2=find(fType23(1:250)==2);
i23ObjEval3=find(fType23(1:250)==3);
i23ObjEval4=find(fType23(1:250)==4);

subplot(2,1,2)
plot(i23ObjEval1,stepDuration23(i23ObjEval1),'linestyle','none','marker','.','color','b','markersize',20);
hold on
plot(i23ObjEval2,stepDuration23(i23ObjEval2),'linestyle','none','marker','.','color','r','markersize',20);
plot(i23ObjEval3,stepDuration23(i23ObjEval3),'linestyle','none','marker','.','color','m','markersize',20);
plot(i23ObjEval4,stepDuration23(i23ObjEval4),'linestyle','none','marker','.','color','c','markersize',20);
xlabel('Step #')
ylabel({'ode23';'Step Duration (min)'})

%% Histograms

binsH=[0:.01:1];
nHist15sObjEval1=hist(stepDuration15s(i15sObjEval1),binsH)/length(i15sObjEval1)*100;
nHist15sObjEval2=hist(stepDuration15s(i15sObjEval2)/18,binsH)/length(i15sObjEval2)*100;
nHist15sObjEval3=hist(stepDuration15s(i15sObjEval3),binsH)/length(i15sObjEval3)*100;
nHist15sObjEval4=hist(stepDuration15s(i15sObjEval4)/18,binsH)/length(i15sObjEval4)*100;
nHist15sObjEvalTot=(nHist15sObjEval1+nHist15sObjEval2+nHist15sObjEval3+nHist15sObjEval4)/4;
meanDur15s=mean([stepDuration15s(i15sObjEval1) stepDuration15s(i15sObjEval2)/18 stepDuration15s(i15sObjEval3) stepDuration15s(i15sObjEval4)/18]);

nHist23ObjEval1=hist(stepDuration23(i23ObjEval1),binsH)/length(i23ObjEval1)*100;
nHist23ObjEval2=hist(stepDuration23(i23ObjEval2)/18,binsH)/length(i23ObjEval2)*100;
nHist23ObjEval3=hist(stepDuration23(i23ObjEval3),binsH)/length(i23ObjEval3)*100;
nHist23ObjEval4=hist(stepDuration23(i23ObjEval4)/18,binsH)/length(i23ObjEval4)*100;
nHist23ObjEvalTot=(nHist23ObjEval1+nHist23ObjEval2+nHist23ObjEval3+nHist23ObjEval4)/4;
meanDur23=mean([stepDuration23(i23ObjEval1) stepDuration23(i23ObjEval2)/18 stepDuration23(i23ObjEval3) stepDuration23(i23ObjEval4)/18]);


figure
subplot(1,2,1)
stairs(binsH,nHist15sObjEval1,'color','b','displayname','Obj');
hold on
stairs(binsH,nHist15sObjEval2,'color','r','displayname','Obj Grad (/18)');
stairs(binsH,nHist15sObjEval3,'color','m','displayname','Constraint');
stairs(binsH,nHist15sObjEval4,'color','c','displayname','Const Jacob (/18)');
stairs(binsH,nHist15sObjEvalTot,'color','k','displayname','All','linewidth',2);
xlabel('Step Duration (min)')
ylabel('% Of Steps')
title('ode15s Step Duration Histogram')
legend show
set(gca,'ylim',[0 30]);


subplot(1,2,2)
stairs(binsH,nHist23ObjEval1,'color','b');
hold on
stairs(binsH,nHist23ObjEval2,'color','r');
stairs(binsH,nHist23ObjEval3,'color','m');
stairs(binsH,nHist23ObjEval4,'color','c');
stairs(binsH,nHist23ObjEvalTot,'color','k','displayname','All','linewidth',2);
xlabel('Step Duration (min)')
ylabel('% Of Steps')
set(gca,'ylim',[0 30]);

title('ode23 Step Duration Histogram')


%% Lets Check for unique Ps

[unique23,ia,ic]=unique(p23,'rows');
[unique15s,ia,ic]=unique(p15s,'rows');


diffP15s=diff(p15s,1,1);



