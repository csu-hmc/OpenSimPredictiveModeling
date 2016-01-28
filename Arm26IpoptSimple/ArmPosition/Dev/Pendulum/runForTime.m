%% OpenSim Model
[rOsim,osimModel] = pendOsim(1.0, 180, 100);
osimModel.print('pendulumWithController.osim')
osSimpleStorage('pendOsim.sto','controls',{'time','Torq1'},[rOsim.t rOsim.u],0);

%% Ton's Model
rPend = pend(1.0, 180, 100);
osSimpleStorage('pend.sto','controls',{'time','Torq1'},[rPend.t rPend.u],0);

save('Results','rOsim','rPend')

%% Figure
figure

		subplot(2,1,1)
        plot(rOsim.t,rOsim.x*180/pi)
        hold on
        plot(rPend.t,rPend.x*180/pi,'r')
        title('angle')
		
        subplot(2,1,2);
        plot(rOsim.t,rOsim.u)
        hold on
        plot(rPend.t,rPend.u,'r')
        title('torque');
		
   figure
   plot(rPend.t,rPend.x-rOsim.x)

