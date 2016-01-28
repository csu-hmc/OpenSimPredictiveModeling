

duration=2;
nNodes=10;

cmcData=[8.99000000	      0.00733262	      0.33320676	      0.00015488	     -0.00033950	      0.05000000	      0.14376217	      0.05000000	      0.07748684	      0.05000000	      0.07254413	      0.09740720	      0.13967521	      0.11168993	      0.14165325	      0.06957605	      0.08636286	      0.05000000	      0.16171813	      0.10730129	      0.10873707];
targetangleIn=cmcData(2:3);
targetvelocityIn=[0;0];
initMsucleAct=cmcData(6:2:end);
initMuscleLength=cmcData(7:2:end);

result = arm28DirectCoFMINCON(duration, targetangleIn, targetvelocityIn, nNodes, initMuscleLength, initMsucleAct);