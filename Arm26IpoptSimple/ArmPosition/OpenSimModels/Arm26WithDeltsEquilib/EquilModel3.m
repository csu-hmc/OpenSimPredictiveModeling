% Load Library
import org.opensim.modeling.*;

osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

%Lock coordiantes
[osimModel,defLocked]=osSetCoordLock(osimModel,1);

%Generate motion file and get muscle lengths
%Run a forward analysis
[fTool,osimModel]=osForwardDynamics(osimModel);
fTool.setStartTime(0);
fTool.setFinalTime(1);
fName=['temp' datestr(now,30)];
fName='InitFdRun';
fTool.setName(fName);
fTool.run();

% Load the results
fixedCoordsFileName=[fName '_states.sto'];
[data,columnNames,isInDegrees]=osLoadMotFile(fixedCoordsFileName);

% Reopen the orginal model (to revert to model with correct locked coords)
osimModel = Model(osimModelName);
osimModel.setUseVisualizer(false);
options.setTimeWindow=0.5;
options.setDesiredKinematicsFileName='InitFdRun_states.sto';
options.setTaskSetFileName='arm26_ComputedMuscleControl_Tasks.xml';
options.setName='test';

%[cmcTool,osimModel]=osCmc(osimModel,options);
[cmcTool]=osCmc(osimModel,options);

cmcTool.run();

[data,columnNames,isInDegrees,stoDb]=osLoadMotFile('test_states.sto');


osimModel = Model(osimModelName);
osimModel.setUseVisualizer(false);
osimModel=osSetMuscleDefaultActAndLength(osimModel,stoDb);

%Check with a forward run
if 0
    %Reopen Model
    osimModel = Model(osimModelName);
    osimModel.setUseVisualizer(false);
    
    [tool,model]=osForwardDynamics(osimModel);
    [fTool,osimModel]=osForwardDynamics(osimModel);
    
    fName='FdCheckRun';
    fTool.setName(fName);
    fTool.setControlsFileName
    
    fTool.run();
    
    
end
%si=osimModel.initSystem();

osimModel.print('NewModel.osim');


