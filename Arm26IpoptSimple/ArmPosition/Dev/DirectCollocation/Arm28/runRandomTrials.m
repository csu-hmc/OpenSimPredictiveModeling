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
for i=1:20
    display([datestr(now,13) 'Running ' num2str(i) ': fmincon-ip obj 2 begin']);
    optOptions = optimoptions('fmincon','Algorithm','interior-point');
    optimizer=0;
    objFunc=2;
    resultInterior0 = openSimDirectCoPosition(osimModelName, duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMuscleAct, optimizer, optOptions, objFunc, oldresult);
    resultRand{i}=resultInterior0;
    save('benchMarkRandom2','resultRand')
    display([datestr(now,13) 'Running ' num2str(i) ': fmincon-ip obj 2 end']);
end