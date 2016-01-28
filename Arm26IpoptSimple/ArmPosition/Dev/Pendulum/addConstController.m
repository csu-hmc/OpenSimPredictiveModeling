


% Load Library
import org.opensim.modeling.*;

%osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize_Equib.osim';
osimModelName='pendulum.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

%Add a constant controller
numActuators=osimModel.getActuators.getSize;
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
    s(i)=Constant();
    s(i).setValue(0);
    
    %Add the function to function set
    fSet(i).set(0,s(i));
    %fSet.setName(['OptFunc_' muscleName]);
    
    %Add function tocontroller
    pCont(i).set_ControlFunctions(fSet(i));
    pCont(i).get_ControlFunctions(0).setName(['OptFunc_' muscleName]);
    
    % Add Controller
    osimModel.addController(pCont(i));
    
end
osimModel.updControllerSet();

osimModel.print('pendulumWithController.osim')