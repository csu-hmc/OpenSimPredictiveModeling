
[data,columnNames,isInDegrees]=osLoadMotFile('SimpleRunCMCOut.mot');
if 0
    
    actData=data(:,6:2:end);
    PInit=[];
    tp=data(:,1)';
    P=actData;
else
    makeFitOfOpenSimControlResults;
    PInit=[];
    tp=actFit(:,1)';
    P=actFit(:,2:end);
end

addpath('E:\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')


%% Setup OpenSim Model

% Load Library
import org.opensim.modeling.*;

osimModelName='Arm28_Optimize_Equib.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();





%% Setup MATLAB Integrator
% Integrate plant using Matlab Integrator
timeSpan = [0.03 2];
integratorName = 'ode15s';
%integratorName = 'ode23';
%integratorName = 'ode23t';
% IntegratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
integratorOptions =[];

%% Setup Controls
controlsFuncHandle = @plantControlsFunctionOpenSim;  % Controls function  
controlsFuncHandle = [];  % Controls function

% % Initial Control Values
% numControls=osimModel.getNumControls();
% tp=[1 2];
% P=ones(length(tp),numControls);
% 
% actCnt=1;
% for c=5:2:(osimState.getY().size)
% 
%     PInit(actCnt)=osimState.getY.get(c-1);
%         actCnt=actCnt+1;
% end
% 
% 
% P(1,:)=P(1,:).*PInit; %All controls at time 0 = 0.01
% P(2,:)=P(2,:).*PInit; %All controls at Time 1 = 0.02
% %P(3,:)=P(3,:).*PInit; %All controls at Time 2 = 0.03


%PInit=actData(1,:);

% Add a prescribed controller if a controls function is not provided
if isempty(controlsFuncHandle)
    addPrescribedController;
end

% Flatten Initial Controls Values
Po=reshape(P',1,[]);   %Convert to row vectors where c1@t0 c2@t0 .... c6@t0  c1@t1......


constObjFuncName='arm26CalcObjConstraints';  %Objective and constraint function



% Setup and Initial Log file
format='yy-mm-dd-HH-MM-SS';
logFileName=['logfile_' datestr(now,format)];
save(logFileName,'osimModelName')



% Setup needed global for storing "fixed" parameters
global m
m.PInit=PInit;
m.osimModel=osimModel;
m.controlsFuncHandle=controlsFuncHandle;
m.timeSpan=timeSpan;
m.integratorName=integratorName;
m.integratorOptions=integratorOptions;
m.tp=tp;
m.constObjFuncName=constObjFuncName;
m.h=0.00001;
m.saveLog=logFileName;  %Set to [] for no log
m.runCnt=0;
m.bestYetValue=Inf;
m.bestYetIndex=[];
m.lastPm=[];
m.lastModelResults=[];
m.lastGradObj=[];
m.lastJacConst=[];

Pv=reshape(P',1,[]);   %Convert to row vectors where c1@t0 c2@t0 .... c6@t0  c1@t1......

obj1=objOpenSimModel(Pv);
%obj2=objOpenSimModel(Pv);
%obj2=objOpenSimModel(Pv);
%constr=constOpenSimModel(Pv);
%gradObj=gradObjOpenSimModel(Pv); 
%jacConst=jacConstOpenSimModel(Pv);


%%
% load('logFile')
% figure
% 
% 
% for i=2:size(log2.modelResults.OutputData.data,2)
%     plot(log2.modelResults.OutputData.data(:,1),log2.modelResults.OutputData.data(:,i),'color',pcolors(i))
%     hold on
% end


if 1
resData=load(logFileName);
fileName='arm26_IPOPT_RunWithOpenSimMuscleActivationResults.mot';
resultsName='arm26Opt';
data=resData.log1.modelResults.OutputData.data;
columnNames=resData.log1.modelResults.OutputData.labels;
inDegrees=resData.log1.modelResults.OutputData.inDegrees;
osSimpleStorage(fileName,resultsName,columnNames,data,inDegrees);
end

% resultsName={'results name'};
% fileName='stop3.txt';
% inDegrees=1;
% data=magic(4)/1.3;
% columnNames={'a','b','c','d'};

