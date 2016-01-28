load('logfile_15-02-25-10-08-06.mat');


obJMat=reshape(log1.gradObj,8,[])'

c=0;
for i=1:1:32
    c=c+1;
    time=log1.gradModelResultsOut.modelResults{1, i}.OutputData.data(:,1);
    muscleAct=log1.gradModelResultsOut.modelResults{1, i}.OutputData.data(:,8);
    muscleAct=log1.gradModelResultsOut.modelResults{1, i}.OutputData.data(:,9);
    plot(time,muscleAct,'color',pcolors(c))
    hold on
end
