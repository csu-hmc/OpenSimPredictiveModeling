function c = constPend(x1,x2,x3,u)

global osimModel osimState h

xd = (x2 - x1)/h;
xdd = (x3 - 2*x2 + x1)/h^2;							% three-point formula for angular acceleration

% Load Library
import org.opensim.modeling.*;





osimModel.getCoordinateSet().get(0).setValue(osimState,x1);
osimModel.getCoordinateSet().get(0).setSpeedValue(osimState,xd)
%Need to do this before setting control or it fails.
osimModel.computeStateVariableDerivatives(osimState);


controlVector=osimModel.getControls(osimState);
controlVector.set(0,u)
osimModel.setControls(osimState,controlVector);
osimModel.computeStateVariableDerivatives(osimState);


qdotdot=osimModel.getCoordinateSet().get(0).getAccelerationValue(osimState);

c = xdd - qdotdot;
