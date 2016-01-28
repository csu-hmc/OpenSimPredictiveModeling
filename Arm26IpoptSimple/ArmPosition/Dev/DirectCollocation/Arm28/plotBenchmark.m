load('benchMark3')
t=resultSqp0.times;

figure
subplot(2,3,1)
plot(t,resultInterior0.X(1:10),'color',pcolors(1),'linestyle','-','displayname','fmincon-interior-point')
hold on
plot(t,resultSqp0.X(1:10),'color',pcolors(2),'linestyle','-','displayname','fmincon-sqp')
plot(t,resultIPOPT0.X(1:10),'color',pcolors(3),'linestyle','-','displayname','IPOPT')
xlabel('Time (sec)')
ylabel('Shoulder Angle (rad)')
title('Activation Only Objective Function','fontsize',10)
legend show

subplot(2,3,2)
plot(t,resultInterior1.X(1:10),'color',pcolors(1),'linestyle','-')
hold on
plot(t,resultSqp1.X(1:10),'color',pcolors(2),'linestyle','-')
xlabel('Time (sec)')
ylabel('Shoulder Angle (rad)')
title('F_m_a_x Scaled Objective Function','fontsize',10)

subplot(2,3,3)
plot(t,resultInterior2.X(1:10),'color',pcolors(1),'linestyle','-')
hold on
plot(t,resultSqp2.X(1:10),'color',pcolors(2),'linestyle','-')
xlabel('Time (sec)')
ylabel('Shoulder Angle (rad)')
title('F_m_a_x and L_o_p_t Scaled Objective Function','fontsize',10)

subplot(2,3,4)
plot(t,resultInterior0.X(11:20),'color',pcolors(1),'linestyle','-','displayname','fmincon-interior-point')
hold on
plot(t,resultSqp0.X(11:20),'color',pcolors(2),'linestyle','-')
plot(t,resultIPOPT0.X(11:20),'color',pcolors(3),'linestyle','-')
xlabel('Time (sec)')
ylabel('Elbow Angle (rad)')
title('Activation Objective Function','fontsize',10)


subplot(2,3,5)
plot(t,resultInterior1.X(11:20),'color',pcolors(1),'linestyle','-')
hold on
plot(t,resultSqp1.X(11:20),'color',pcolors(2),'linestyle','-')
xlabel('Time (sec)')
ylabel('Elbow Angle (rad)')
title('F_m_a_x Scaled Objective Function','fontsize',10)

subplot(2,3,6)
plot(t,resultInterior2.X(11:20),'color',pcolors(1),'linestyle','-')
hold on
plot(t,resultSqp2.X(11:20),'color',pcolors(2),'linestyle','-')
xlabel('Time (sec)')
ylabel('Elbow Angle (rad)')
title('F_m_a_x and L_o_p_t Scaled Objective Function','fontsize',10)



obj(1,1)=resultInterior0.fval;
obj(2,1)=resultInterior1.fval;
obj(3,1)=resultInterior2.fval;
obj(1,2)=resultSqp0.fval;
obj(2,2)=resultSqp1.fval;
obj(3,2)=resultSqp2.fval;
obj(1,3)=resultIPOPT0.fval;


c(1,1)=max(abs(resultInterior0.constVal));
c(2,1)=max(abs(resultInterior1.constVal));
c(3,1)=max(abs(resultInterior2.constVal));
c(1,2)=max(abs(resultSqp0.constVal));
c(2,2)=max(abs(resultSqp1.constVal));
c(3,2)=max(abs(resultSqp2.constVal));
c(1,3)=max(abs(resultIPOPT0.constVal));



