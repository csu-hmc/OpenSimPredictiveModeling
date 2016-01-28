[data,columnNames,isInDegrees]=osLoadMotFile('SimpleRunCMCOut.mot');



actData=data(:,[1 6:2:end]);


muscleNames=columnNames([6:2:end]);

actFit(:,1)=[0.03 0.5 1 1.5 2.0]';

n=size(actData,2);
for i=2:n
    actFit(:,i)=spline(actData(:,1),actData(:,i),actFit(:,1));
    actPlot=spline(actFit(:,1),actFit(:,i),actData(:,1));
    
    
    subplot(n-1,1,i-1)
    plot(actData(:,1),actData(:,i),'b')
    hold on
    plot(actData(:,1),actPlot,'r')
    plot(actFit(:,1),actFit(:,i),'r','marker','.','linestyle','none')
    
    
end

legend('Full CMC','5pt Spline')
tp=actFit(:,1);
Pinit=actFit(:,2:end);
save('Arm28ResultsFromCMCasInitGuess','tp','Pinit','muscleNames')