
addpath('E:\Data\GitRepo\opensim-utilities\AnalysisTools')

%% Ton's Model with 180deg Stoping point
tStop=10;  %Time to complete swing

%Run Ton's Model
figure
rPend = pend(tStop, 180, 100);

%Get the torque values ready for Simulink
simin=[rPend.t,rPend.u];

%Run the Simulink Integration
sim('PendMod.mdl')

%Run OpenSim Model with ton's torques
%Make an input file
osMakeControlsFileSimple('TonPendtrols.sto',{'time','Torq1'},[rPend.t,rPend.u],0);

%Run the Model
import org.opensim.modeling.*
model='pendulumWithController.osim';
options.setControlsFileName='TonPendtrols.sto';
options.setFinalTime=tStop;
options.setInitialTime=0;
options.setName='RunWithPendTorques'; 

[tool,model]=osForwardDynamics(model,options);
tool.run();

[data,columnNames,isInDegrees,stoDb]=osLoadMotFile('RunWithPendTorques_states.sto');

%Plot The Results
figure
plot(rPend.t,rPend.x*180/pi,'b','displayname','Pend.m')
hold on
plot(tout,simout*180/pi,'r','displayname','Simulink Model')
ylabel('Pendulum angle (deg)')
xlabel('time (sec)')
title('180deg Swing Up')


%% Ton's Model with 90deg Stoping point
tStop=10;  %Time to complete swing

%Run Ton's Model
figure
rPend = pend(tStop, 90, 100);

%Get the torque values ready for Simulink
simin=[rPend.t,rPend.u];

%run the Simulink Integration
sim('PendMod.mdl')

%Plot The Results
figure
plot(rPend.t,rPend.x*180/pi,'b','displayname','Pend.m')
hold on
plot(tout,simout*180/pi,'r','displayname','Simulink Model')
ylabel('Pendulum angle (deg)')
xlabel('time (sec)')
title('90deg Swing Up')