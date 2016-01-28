%arm26_IPOPT - Run Arm26 Optmization Problem with IPOPT.

%% Setup OpenSim Model

%matlabpool(4)

% Load Library
import org.opensim.modeling.*;

osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Don't use the visualizer (must be done before the call to init system)
osimModel.setUseVisualizer(false);

% Initialize the system and get the initial state
%osimStateOrig = osimModel.initSystem();

%osimStateNew = osimModel.initSystem();  %Make another copy of the state

%osimModel.equilibrateMuscles(osimStateNew);
%osimModel.computeStateVariableDerivatives(osimStateNew);
% %osimStateNew2 = osimModel.initSystem();
% if 1
% [tool,model]=osForwardDynamics(osimModel);
% tool.setStartTime(0);
% tool.setFinalTime(0.1);
% a=tool.run();
% else
%     model=osimModel;
% end
% %initStates=Storage('_states.sto');
% %tool=StaticOptimization('bthtemp.xml');
% %tool.setStatesStore('_states.sto');
% 
% toolOptions.setCoordinatesFileName='_states_degrees.mot';
% [tool modelRef]=osStaticOptimization(model,toolOptions,[]);
%  %tool.run();
% 
% %tool.run();

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

% %Get the fiberlength values from the file
% fiberCnt=0;
% fiberKey=strfind(columnNames,'.fiber_length');
% for i=1:length(fiberKey)
%     if ~isempty(fiberKey{i})
%        fiberCnt=fiberCnt+1;
%        fiberNames{fiberCnt}=strrep(columnNames{i},'.fiber_length','');
%        muscleDb.(fiberNames{fiberCnt}).length=data(end,i);
%     end
% end
% 
% % Reopen the orginal model (to revert to model with correct locked coords)
osimModel = Model(osimModelName);
osimModel.setUseVisualizer(false);
% 
% %Set default muscle lengths to above values
 numMuscles=osimModel.getMuscles().getSize();
% for i=0:numMuscles-1
%     muscle=osimModel.getMuscles.get(i);   %Get the muscle and it's name
%     muscleName=char(muscle.getName());
%     if isfield(muscleDb,muscleName)  %Check make sure that the fiber length 
%                                     %was found in the Forward Analysis Step
%         switch char(muscle.getConcreteClassName)
%             case 'Thelen2003Muscle'
%                 m=Thelen2003Muscle.safeDownCast(muscle);
%                 m.setDefaultFiberLength(muscleDb.(muscleName).length);
%             otherwise
%                 warning(['Muscle: ' muscleName ' default length not being set (unknown muscle type).']);
%         end
%     else
%         warning(['Muscle : ' muscleName ' default length is not being set (length value can not be found).'])
%     end
% end


%Run static optimization to get muscle activation
toolOptions.setCoordinatesFileName=fixedCoordsFileName;
[soTool osimModel]=osStaticOptimization(osimModel,toolOptions,[]);

 soFileName=['temp' datestr(now,30)];
 soFileName='SoRun';
 soTool.setName(soFileName);
 soTool.setStartTime(0);
 soTool.setFinalTime(1);
 soTool.run();

%Update default activaton with values from static optmization
 % Load the results
 soActFileName=[soFileName '_StaticOptimization_activation.sto'];
[data,columnNames,isInDegrees]=osLoadMotFile(soActFileName);

%Get the activation values from the file
for i=2:length(columnNames)
       muscleDb.(columnNames{i}).activation=data(end,i);
       muscleDb.(columnNames{i}).activation=data(end,i);
end

osimModel = Model(osimModelName);  %Had to add this or forward reran the SO
osimModel.setUseVisualizer(false);




for i=0:numMuscles-1
    muscle=osimModel.getMuscles.get(i);   %Get the muscle and it's name
    muscleName=char(muscle.getName());
    if isfield(muscleDb,muscleName)  %Check make sure that the fiber length 
                                    %was found in the Forward Analysis Step
        switch char(muscle.getConcreteClassName)
            case 'Thelen2003Muscle'
                m=Thelen2003Muscle.safeDownCast(muscle);
                m.setDefaultActivation(muscleDb.(muscleName).activation);
                %m.setActivation(muscleDb.(muscleName).activation);
                
            otherwise
                warning(['Muscle: ' muscleName ' default length not being set (unknown muscle type).']);
        end
    else
        warning(['Muscle : ' muscleName ' default length is not being set (length value can not be found).'])
    end
end

si=osimModel.initSystem();

osimModel.equilibrateMuscles(si);

for i=0:numMuscles-1
    muscle=osimModel.getMuscles.get(i);   %Get the muscle and it's name
    muscleName2{i+1,1}=char(muscle.getName());
    muscleName2{i+1,2}=muscle.getActivation(si);
    muscleName2{i+1,3}=muscle.getFiberLength(si);
end


 [fTool,osimModel]=osForwardDynamics(osimModel);
 fTool.setStartTime(0);
 fTool.setFinalTime(1);
 fTool.setControlsFileName([soFileName '_StaticOptimization_controls.xml']);
 fTool.setControlsFileName([soFileName '_StaticOptimization_activation.sto']);
 fTool.setSolveForEquilibrium(0);
 fName=['FinalFDtemp' datestr(now,30)];
 fName='FinalFdRun';
 fTool.setName(fName);
 fTool.run();