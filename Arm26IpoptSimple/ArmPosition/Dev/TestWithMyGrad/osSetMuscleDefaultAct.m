function [osimModel]=osSetMuscleDefaultAct(osimModel,muscleNames,actValues)

% Load Library
import org.opensim.modeling.*;

if length(muscleNames)~=length(actValues)
    error('muscleNames and a must be the same size.')
end

for i=1:length(muscleNames)
    
    muscle=osimModel.getMuscles.get( strrep(muscleNames{i},'.activation','')  );
    switch char(muscle.getConcreteClassName)
        case 'Thelen2003Muscle'
            m=Thelen2003Muscle.safeDownCast(muscle);
            m.setDefaultActivation(actValues(i));
        otherwise
            warning(['Muscle: ' strrep(muscleNames{i}) ' activation not being set (unknown muscle type).']);
    end
end




