function ind = getStateVarIndex( motionLabels,labelToFind )

%Find motion label name

ind=0;
for i=1:length(motionLabels)
    if strcmp(motionLabels{i},labelToFind)
        ind=i;
    end
end

