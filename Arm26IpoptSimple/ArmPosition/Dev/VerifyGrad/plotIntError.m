
% dat2 - ode15s 1e-5 tolerance Abs.  Pv(1,1)    0.0001
% dat3 - ode15s  default Integrateor setting  Pv(1,1)    0.0001
% dat4 - ode23  default setting  Pv(1,1)    0.0001
% dat5 - ode15s default Pv(1,1) 0.01
% dat6 - ode15s default Pv(1,1) 0.005
% dat7 - ode15s odeset('AbsTol', (1E-06), 'RelTol', (1E-05));   Pv(1,1) 0.0001 
% dat9 - ode15s odeset('AbsTol', (1E-06), 'RelTol', (1E-04));   Pv(1,1) 0.001 

dat1=load('dat1');
dat3=load('dat3');
dat4=load('dat4');
dat5=load('dat5');
dat6=load('dat6');
dat7=load('dat7');
dat8=load('dat8');
dat9=load('dat9');

figure
plot(dat1.Pd,dat1.obj,'color',pcolors(1),'marker','.','displayname','ode15s, 1e-6 Abs Tol, h=0.0001')
hold on
plot(dat3.Pd,dat3.obj,'color',pcolors(2),'marker','.','displayname','ode15s, 1e-6 Abs Tol, h=0.0001')
plot(dat4.Pd,dat4.obj,'color',pcolors(3),'marker','.','displayname','ode23, Default Tol, h=0.0001')
plot(dat5.Pd,dat5.obj,'color',pcolors(4),'marker','.','displayname','ode15s, Default Tol, h=0.01')
plot(dat6.Pd,dat6.obj,'color',pcolors(5),'marker','.','displayname','ode15s, 1e-6 Abs Tol, h=0.005')
plot(dat7.Pd,dat7.obj,'color',pcolors(6),'marker','.','displayname','ode15s, 1e-6 Abs Tol 1e-5 Rel Tol, h=0.0001')
%plot(dat8.Pd,dat8.obj,'color',pcolors(7),'marker','.','displayname',' ')
plot(dat9.Pd,dat9.obj,'color',pcolors(7),'marker','.','displayname','ode15s, 1e-6 Abs Tol 1e-4 Rel Tol, h=0.001')
ylabel('Objective, Final Velocity (m/s)')
xlabel('TRI Muscle Activation at T=0') 
legend show
title('Manual Gradient')




% figure
% plot(dat9.Pd(2:end),diff(dat9.obj)./diff(dat9.Pd))