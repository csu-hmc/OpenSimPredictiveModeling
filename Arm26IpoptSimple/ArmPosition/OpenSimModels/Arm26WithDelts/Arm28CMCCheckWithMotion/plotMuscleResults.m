[data,columnNames,isInDegrees]=osLoadMotFile('SimpleRunCMCOut.mot');


time=data(:,1);
act=data(:,6:2:end);
muscleNames=columnNames(:,6:2:end);
figure

for i=1:size(act,2)
    plot(time,act(:,i),'color',pcolors(i),'displayname',muscleNames{i});
    hold on
end

legend show