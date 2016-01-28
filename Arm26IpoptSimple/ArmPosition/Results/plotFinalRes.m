%%  Final Results Plot

load('logfile_15-01-05-22-06-52')
%%
data=log1587.modelResults.OutputData.data;
t=data(:,1);
shoulderQ=data(:,2);
elbowQ=data(:,3);
labels=log1587.modelResults.OutputData.labels;

figure
subplot(2,1,1)
plot(t,elbowQ/pi*180,'color',pcolors(1),'linewidth',2,'displayname','Elbow')
hold on
plot(t,shoulderQ/pi*180,'color',pcolors(2),'linewidth',2,'displayname','Shoulder')
legend('show','location','eastoutside')
legend boxoff
ylabel('Angle (deg)')

subplot(2,1,2)
for i=6:2:20
    lname=labels{i};
    n=strfind(lname,'.')-1;
    lname=lname(1:n);
    plot(t,data(:,i),'color',pcolors(i),'linewidth',2,'displayname',lname)
    hold on
end

ylabel('Muscle Activation')
xlabel('Time (sec)')
legend('show','location','eastoutside')
legend boxoff
