function [motionData, osimState] = integrateOpenSimPlant(osimModel, controlsFuncHandle,...
    timeSpan, integratorName, integratorOptions,tp,P)
%integrateOpenSimPlant - Integrate an opensim plant model.
%
%  This function is a modified version of OpenSim's Dynamic Walking
%  Example.
%
% motionData = IntegrateOpenSimPlant(osimModel, controlsFuncHandle,...
%    timeSpan, integratorName, integratorOptions)
%
%   IntegrateOpenSimPlant is a function for integrating a
%   OpenSim model using one of Matlab's integrator routines.
%
% Input:
%   osimModel: An OpenSim Model object
%   controlsFuncHandle: an optional function handle which can be used to
%       calculate the controls applied to actuators at each time step.
%   timeSpan: A row matrix of time ranges for the integrator. This can be
%       timeRange = [timeInitial timeFinal] or [t1, t2, t3 ... timeFinal].
%   integratorName: A char array of the specific integrator to use
%   integratorOptions: a set of integrator options generated with odeset
%       (for defaults, pass an empty array).
%   tp: Vector containing times that control values take place at
%   P: Control Value Matrix, where rows are times and column are controls
%       (muscles excitations)
%
% Output:
%   motionData - roughly mimics the output of the OpenSim .mot (motion)
%       and .sto (state files)




% Import Java libraries
import org.opensim.modeling.*;

if(~isa(osimModel, 'org.opensim.modeling.Model'))
    error('IntegrateOpenSimPlant:InvalidArgument', [ ...
        '\tError in IntegrateOpenSimPlant\n', ...
        '\tArgument osimModel is not an org.opensim.modeling.Model.']);
end
if(~isempty(controlsFuncHandle))
    if(~isa(controlsFuncHandle, 'function_handle'))
        controlsFuncHandle = [];
        display('controlsFuncHandle was not a valid function_handle');
        display('No controls will be used.');
    end
end

%osimModel.equilibrateMuscles();

% Check to see if model state is initialized by checking size
if(osimModel.getWorkingState().getNY() == 0)
    osimState = osimModel.initSystem();
else
    osimState = osimModel.updWorkingState();
end

% Create the Initial State matrix from the Opensim state
numVar = osimState.getY().size();




InitStates = zeros(numVar,1);
for i = 0:1:numVar-1
    InitStates(i+1,1) = osimState.getY().get(i);
end

% Create a anonymous handle to the OpenSim plant function.  The
% variables osimModel and osimState are held in the workspace and
% passed as arguments



if ~isempty(controlsFuncHandle)
    for m=1:size(P,2)
        pCoeffs(m)=spline(tp,P(:,m));
    end
else
    
    
    updatePresContSpline;
    pCoeffs=0;
end



%varPassedOut=[];
plantHandle = @(t,x) plantFunctionOpenSim(t, x, controlsFuncHandle, osimModel, osimState,tp,pCoeffs);
%varPassedOut=varPassedOut(2:end);






% Integrate the system equations
integratorFunc = str2func(integratorName);
[T, Y] = integratorFunc(plantHandle, timeSpan, InitStates, ...
    integratorOptions);

%Get list of actuators
for a=1:osimModel.getActuators.getSize
    actuatorNames{a}=char(osimModel.getActuators.get(a-1));
end


% Create Output Data structure  (lots of overhead here to be removed)
motionData = struct();
motionData.name = [char(osimModel.getName()), '_states'];
motionData.nRows = size(T, 1);
motionData.nColumns = size(T, 2) + size(Y, 2);
motionData.inDegrees = false;
motionData.labels = cell(1,motionData.nColumns);
motionData.labels{1}= 'time';
for j = 2:1:motionData.nColumns
    motionData.labels{j} = char(osimModel.getStateVariableNames().get(j-2));
end
motionData.data = [T, Y];
motionData.actuatorNames=actuatorNames;



