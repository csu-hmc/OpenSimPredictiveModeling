% Load Library
import org.opensim.modeling.*;

% Open a Model by name
osimModel = Model('muscle-mass11.osim');

% Initialize the system and get the initial state
osimState = osimModel.initSystem();

q=-0.1;  %Joint Position
qd=0;   %Joint velocity
a=0.20004;   %Muscle Activation
lce=0.101;   %Muscle Length

%Set the kinematic properties
osimModel.getCoordinateSet().get(0).setValue(osimState,q);
osimModel.getCoordinateSet().get(0).setSpeedValue(osimState,qd);

osimModel.computeStateVariableDerivatives(osimState);

%Set the muscle parameters
forceObj=osimModel.getMuscles().get(0);
muscleType = char(forceObj.getConcreteClassName);
eval(['muscleObj =' muscleType '.safeDownCast(forceObj);']);
muscleObj.setActivation(osimState, a );
muscleObj.setFiberLength(osimState, lce );

lceBeforeEquib=osimModel.getMuscles().get(0).getFiberLength(osimState);

%% Using Equibriate Muscle
% Compute the values  (Comment out to use either equilibrateMuscles or computeStateVariableDerivatives
osimModel.equilibrateMuscles(osimState);
%osimModel.computeStateVariableDerivatives(osimState);

%Get the resulting position states  (Really just want accel, but check pos and vel do not change
qPostEquib=osimModel.getCoordinateSet().get(0).getValue(osimState)  
qdotdotPostEquib=osimModel.getCoordinateSet().get(0).getAccelerationValue(osimState)
qdotPostEquib=osimModel.getCoordinateSet().get(0).getSpeedValue(osimState)

%Get the muscle values
mActPostEquib=osimModel.getMuscles().get(0).getActivation(osimState)
mForcePostEquib=osimModel.getMuscles().get(0).getForce(osimState)
mLengthPostEquib=osimModel.getMuscles().get(0).getFiberLength(osimState)
mVeldotPostEquib=osimModel.getMuscles().get(0).getFiberVelocity(osimState)


%% Using computeStateVariables

% ReInitialize the system and get the initial state
osimState = osimModel.initSystem();

%Set the kinematic properties
osimModel.getCoordinateSet().get(0).setValue(osimState,q);
osimModel.getCoordinateSet().get(0).setSpeedValue(osimState,qd);

osimModel.computeStateVariableDerivatives(osimState);

%Set the muscle parameters
forceObj=osimModel.getMuscles().get(0);
muscleType = char(forceObj.getConcreteClassName);
eval(['muscleObj =' muscleType '.safeDownCast(forceObj);']);
muscleObj.setActivation(osimState, mActPostEquib );
muscleObj.setFiberLength(osimState, mLengthPostEquib );
%muscleObj.setFiberLength(osimState, 0.1010 );


lceBeforecSV=osimModel.getMuscles().get(0).getFiberLength(osimState);

%% Using computeStateVariableDerivatives
% Compute the values  (Comment out to use either equilibrateMuscles or computeStateVariableDerivatives
%osimModel.equilibrateMuscles(osimState);
osimModel.computeStateVariableDerivatives(osimState);

%Get the resulting position states  (Really just want accel, but check pos and vel do not change
qPostCsv=osimModel.getCoordinateSet().get(0).getValue(osimState)  
qdotdotPostCsv=osimModel.getCoordinateSet().get(0).getAccelerationValue(osimState)
qdotPostCsv=osimModel.getCoordinateSet().get(0).getSpeedValue(osimState)

%Get the muscle values
mActPostCsv=osimModel.getMuscles().get(0).getActivation(osimState)
mForcePostCsv=osimModel.getMuscles().get(0).getForce(osimState)
mLengthPostCsvb=osimModel.getMuscles().get(0).getFiberLength(osimState)
mVeldotPostCsv=osimModel.getMuscles().get(0).getFiberVelocity(osimState)
