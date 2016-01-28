function modelControls = plantControlsFunctionOpenSim(osimModel, osimState, tp, pCoeffs)
%plantControlsFunctionOpenSim- This function allows for the generation of
%   varying control values during each integrator step.  
%
% plantControlsFunctionopenSim(osimModel, osimState, tp, P)
%
%  This function is a modified version of OpenSim's Dynamic Walking
%  Example.
%
%   Inputs:
%       osimModel - Reference to an openSim Model Object
%       osimState - An openSim state object to be updated
%       tp: Vector containing times that control values take place at
%       P: Control Value Matrix, where rows are times and column are controls
%           (muscles excitations)
%
%
%   Outputs:
%       modelControls - refernce to ossimModels controls (after update)



% Load Library
import org.opensim.modeling.*;

numControls=osimModel.getNumControls();

% Check Size
if( numControls< 1)
    error('OpenSimPlantControlsFunction:InvalidControls', ...
        'This model has no controls.');
end

% Get a reference to current model controls
modelControls = osimModel.updControls(osimState);

% Initialize a vector for the actuator controls
% Most actuators have a single control.  For example, muscle have a
% signal control value (excitation);
actControls = Vector(1, 0.0);


simTime=osimState.getTime();

for i=1:numControls
    %controlValue=spline(tp,P(:,i),simTime);
    
    controlValue=ppval(simTime,pCoeffs(i));
    
    
    % Set Actuator Controls Vector
    actControls.set(0, controlValue);
    
    % Update modelControls with the new values
    osimModel.updActuators().get(i-1).addInControls(actControls, modelControls);
end
