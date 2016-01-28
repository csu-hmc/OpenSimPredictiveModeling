

addpath('E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')

% Load Library
import org.opensim.modeling.*;

%osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize_Equib.osim';


osimModelName='pendulumWithController.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();
osimModel.computeStateVariableDerivatives(osimState);


%%
% x1=[0];
% xd=[0];
% u=[0];


load Results
x1=rOsim.x;
xd=diff(x1)./diff(rOsim.t);
u=rOsim.u;

% x1=pi/2
% xd=1;
% u=9.81;

for i=1:length(xd)
    osimModel.getCoordinateSet().get(0).setValue(osimState,x1(i));
    osimModel.getCoordinateSet().get(0).setSpeedValue(osimState,xd(i))
    %Need to do this before setting control or it fails.
    osimModel.computeStateVariableDerivatives(osimState);
    
    controlVector=osimModel.getControls(osimState);
    controlVector.set(0,u(i))
    osimModel.setControls(osimState,controlVector);
    osimModel.computeStateVariableDerivatives(osimState);
    
    qdotdot(i)=osimModel.getCoordinateSet().get(0).getAccelerationValue(osimState);
    qdot(i)=osimModel.getCoordinateSet().get(0).getSpeedValue(osimState);
    q(i)=osimModel.getCoordinateSet().get(0).getValue(osimState);
    
    aa=1;
end


figure
subplot(4,1,1)
plot(rOsim.t(1:length(q)),q*180/pi)
ylabel('x (deg)')

subplot(4,1,2)
plot(rOsim.t(1:length(q)),qdot)
ylabel('xdotdot (deg/s2)')

subplot(4,1,3)
plot(rOsim.t(1:length(q)),qdotdot,'r')
hold on
plot(rOsim.t(1:length(rOsim.xdd)),rOsim.xdd,'b')
legend('OSIM Calc','Finite Diff')
ylabel('xdotdot (deg/s2)')

subplot(4,1,4)
plot(rOsim.t(1:length(u)),u)
ylabel('Torque')

% 
% %Manually integrate and compare
% dt=rOsim.t(2)-rOsim.t(1);
% p=cumtrapz(qdot)*dt;
% v=cumtrapz(qdotdot)*dt;
% figure
% plot(p,'r');hold on;plot(q,'b')


