

addpath('E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')

%import org.opensim.modeling.*;

%% OpenSim Model
 rOsim = pendOsim(15.0, 90, 100);
osMakeControlsFileSimple('pendOsim.sto',{'time','Torq1'},[rOsim.t rOsim.u],0);


%% Ton's Model
rPend = pend(15.0, 90, 100);
%osSimpleStorage('pend.sto','controls',{'time','Torq1'},[rPend.t rPend.u],0);

save('Results','rOsim','rPend')

%% Plot Rsults


load('Results')

figure

subplot(2,1,1)
plot(rOsim.t,rOsim.x*180/pi)
hold on
plot(rPend.t,rPend.x*180/pi,'r--')
ylabel('Angle (deg)')
legend('pendOsim.m (OpenSim Numeric)','pend.m (Analytical)')

subplot(2,1,2);
plot(rOsim.t,rOsim.u)
hold on
plot(rPend.t,rPend.u,'r--')
ylabel('Torque (N-m)');
xlabel('Time (sec)');

figure
plot(rPend.t,rPend.x-rOsim.x)

osMakeControlsFileSimple('DirectColControls.sto',{'time','Torq1'},[rOsim.t,rOsim.u],0);
osMakeControlsFileSimple('TonPendtrols.sto',{'time','Torq1'},[rPend.t,rPend.u],0);