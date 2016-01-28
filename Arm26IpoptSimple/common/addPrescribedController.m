
%Script addPrescribedController
%
% This script adds a prescribed controller to an OpenSim Model
% (Has to be a script or OpenSim crashes when function completes)
%
% The prescribed controller is then used to provide excitation to muscles.
% A SimmSpline is used as the controller function.  The values of the
% spline are determined by the optimizer input, P.  See script
% updatePresContSpline for how the controller values are updated.

%Append zero values



PWith0=[PInit;P];


numActuators=osimModel.getActuators.getSize;

numTimePts=length(tp);

if numActuators~=size(PWith0,2)
    error('addPrescribedController:  Number of P Columns must equal number of actuators in model.')
end

for i=1:numActuators
    
    % Get an Actuator
    anActuator(i)=osimModel.getActuators.get(i-1);
    muscleName=char(anActuator(i));
    
    % Create Controller
    pCont(i) = PrescribedController();
    pCont(i).setName(['OptCntrl_' muscleName]);
    
    % Create an Actuator Set
    setOfActuators(i)=SetActuators();
    
    % Add Actuator
    setOfActuators(i).set(0,anActuator(i));
    
    %  Add Actuator Set to Controller
    pCont(i).setActuators(setOfActuators(i));
    
    % Create a function set and add points
    fSet(i)=FunctionSet();
    s(i)=SimmSpline();
    
    for mc=1:numTimePts
        s(i).addPoint(tp(mc),PWith0(mc,i)); 
    end
    
    %s(i).addPoint(0,0); 
    
    %Add the function to function set
    fSet(i).set(0,s(i));
    %fSet.setName(['OptFunc_' muscleName]);
    
    
    %Add function tocontroller
    pCont(i).set_ControlFunctions(fSet(i));
    pCont(i).get_ControlFunctions(0).setName(['OptFunc_' muscleName]);
    
    % Add Controller
    osimModel.addController(pCont(i));
    
end


% clear pCont  setOfActuators anActuator 
% clear pCont fSet setOfActuators anActuator s

osimModel.updControllerSet();



%osimModel.disownAllComponents();
%osimModel.print('modelName.osim')
