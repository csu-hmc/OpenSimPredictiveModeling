function modelResults = runOpenSimModel(osimModel,initialState,...
    timeSpan, integratorName, integratorOptions, constObjFuncName)
%evaluateOpenSimModel- evaluate (perform integration and calculate
%   constarinats and objective) of an OpenSim model.  Use the function in
%   controlsFuncHandle to calculate the control values at integrator time
%   steps.
%
%   modelResults = evaluateOpenSimModel(osimModel, controlsFuncHandle,...
%       timeSpan, integratorName, integratorOptions,tp,P,constObjFuncName)
%
%    Inputs:
%       osimModel: An opensim model object
%       controlsFunctionHandle:  A handle to model specific function that
%           contains the calculations for the OpenSim Model controls.
%       timeSpan: The time span to integrate over (see
%           IntegrateOpenSimPlant).  [0 2] will integrate from 0 to 2
%           seconds.
%       integratorName: String containg the name of the integrator to be
%           used.  For example: 'ode15s'
%       integratorOptions: Structure containing integrator options.  See
%           ode15s for examples.
%           integratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
%       tp:  A vector of times at which the control values are provided.
%       P:  Control value Inputs into the model.  Matrix where:
%           Columns:  One column for each control (muscle) input in the
%               model.
%           Rows are the values of the control at the times in tp.  A cubic
%               spline is fit between the values for each control.
%       constObjFuncName: A handle to model specific function that
%           contains the calculations for the OpenSim Model constraint
%           values and objective.

% Import Java libraries
import org.opensim.modeling.*;


% Integrate the Plant Model
[OutputData,osimState]= integrateOpenSimPlant(osimModel, initialState, timeSpan, ...
    integratorName, integratorOptions);

modelResults.OutputData=OutputData;

if ~isempty(constObjFuncName)
    % Calculate constraints and objective
    constObjFuncHandle=str2func(constObjFuncName);
    [objective,constraints]=constObjFuncHandle(osimState,osimModel,OutputData);
    
    %Update the modelresults structure
    modelResults.objective=objective;
    modelResults.constraints=constraints;
    
else  %No constraint or objective function provided
    modelResults.objective=[];
    modelResults.constraints=[];
    
end






