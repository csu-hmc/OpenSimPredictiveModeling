load('PSO_InitialConverg')

figure

plot(unnamed(:,1),'color',pcolors(1),'displayname','min')
hold on
plot(unnamed(:,2),'color',pcolors(2),'displayname','average')
xlabel('Generation')
ylabel('Cost')
title('Arm28 PSO Initial Trial')
legend show