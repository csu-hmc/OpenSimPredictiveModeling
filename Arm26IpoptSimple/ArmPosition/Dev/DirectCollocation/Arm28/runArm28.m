
%%
osimModelName='E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\OpenSimModels\Arm26WithDelts\Arm28_Optimize.osim';


duration=1;
nNodes=10;

cmcData=[8.99000000	      0.00733262	      0.33320676	      0.00015488	     -0.00033950	      0.05000000	      0.14376217	      0.05000000	      0.07748684	      0.05000000	      0.07254413	      0.09740720	      0.13967521	      0.11168993	      0.14165325	      0.06957605	      0.08636286	      0.05000000	      0.16171813	      0.10730129	      0.10873707];
%targetangleIn=cmcData(2:3);
targetangleIn=[pi/4 45*pi/180];
targetvelocityIn=[0 0];

initAngleIn=cmcData(2:3);
initVelocityIn=[0 0];
initMuscleAct=cmcData(6:2:end);
initMuscleLength=cmcData(7:2:end);
oldresult=[];


% %% -------------------------Objective Function 0--------------------
% 
display([datestr(now,13) ' fmincon-ip obj 0 begin']);
optOptions = optimoptions('fmincon','Algorithm','interior-point');
optimizer=0;
objFunc=0;
resultInterior0 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult);
save('benchMark3','resultInterior0')
display([datestr(now,13) ' fmincon-ip obj 0 end']);

% %%  Does not run bc constraints
% %optOptions = optimoptions('fmincon','Algorithm','trust-region-reflective');  
% %optimizer=0;
% %resultTrust = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% %save('benchMark3','resultTrust','-append')

display([datestr(now,13) ' fmincon-sqp obj 0 begin']);
optOptions = optimoptions('fmincon','Algorithm','sqp');
optimizer=0;
objFunc=0;
resultSqp0 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
save('benchMark3','resultSqp0','-append')
display([datestr(now,13) ' fmincon-sqp obj 0 end']);


% optOptions = optimoptions('fmincon','Algorithm','active-set');
% optimizer=3;
% objFunc=0;
% resultActSet = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% save('benchMark3','resultActSet','-append')


display([datestr(now,13) 'ipopt obj 0 begin']);
optOptions=[];
optimizer=1;
objFunc=0;
resultIPOPT0 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
save('benchMark3','resultIPOPT0','-append')
display([datestr(now,13) ' ipopt obj 0 end']);









%% -------------------------Objective Function 1--------------------

display([datestr(now,13) ' fmincon-ip obj 1 begin']);
optOptions = optimoptions('fmincon','Algorithm','interior-point');
optimizer=0;
objFunc=1;
resultInterior1 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult);
save('benchMark3','resultInterior1','-append')
display([datestr(now,13) ' fmincon-ip obj 1 end']);
% 
% %%
% %optOptions = optimoptions('fmincon','Algorithm','trust-region-reflective');  Does not run bc constraints
% %optimizer=0;
% %resultTrust = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% %save('benchMark3','resultTrust','-append')
% 
%%
display([datestr(now,13) ' fmincon-sqp obj 1 begin']);
optOptions = optimoptions('fmincon','Algorithm','sqp');
optimizer=0;
objFunc=1;
resultSqp1 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
save('benchMark3','resultSqp1','-append')
display([datestr(now,13) ' fmincon-sqp obj 1 end']);


% optOptions = optimoptions('fmincon','Algorithm','active-set');
% optimizer=3;
% objFunc=1;
% resultActSet = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% save('benchMark3','resultActSet','-append')
% 
%%  Had not converged after 2253 IPOPT iterations and 12000 function evals
% display([datestr(now,13) ' ipopt obj 1 begin']);
% optOptions=[];
% optimizer=1;
% objFunc=1;
% resultIPOPT1 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% save('benchMark3','resultIPOPT1','-append')
% display([datestr(now,13) ' ipopt obj 1 end']);




%% -------------------------Objective Function 2--------------------
%
display([datestr(now,13) ' fmincon-ip obj 2 begin']);
optOptions = optimoptions('fmincon','Algorithm','interior-point');
optimizer=0;
objFunc=2;
resultInterior2 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult);
save('benchMark3','resultInterior2','-append')
display([datestr(now,13) ' fmincon-ip obj 2 end']);

%
% optOptions = optimoptions('fmincon','Algorithm','trust-region-reflective');  Does not run bc constraints
% optimizer=0;
% resultTrust = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% save('benchMark3','resultTrust','-append')

%
display([datestr(now,13) ' fmincon-sqp obj 2 begin']);
optOptions = optimoptions('fmincon','Algorithm','sqp');
optimizer=0;
objFunc=2;
resultSqp2 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
save('benchMark3','resultSqp2','-append')
display([datestr(now,13) ' fmincon-sqp obj 2 end']);

%
% optOptions = optimoptions('fmincon','Algorithm','active-set');
% optimizer=3;
% objFunc=2;
% resultActSet = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% save('benchMark3','resultActSet','-append')

%  Did not converge after 1904 IPOPT iterations or ~14000 function evals
% display([datestr(now,13) ' ipopt obj 2 begin']);
% optOptions=[];
% optimizer=1;
% objFunc=2;
% resultIPOPT2 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult)
% save('benchMark3','resultIPOPT2','-append')
% display([datestr(now,13) ' ipopt obj 2 end']);


