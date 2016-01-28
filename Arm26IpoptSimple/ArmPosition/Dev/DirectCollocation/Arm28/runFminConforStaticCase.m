

duration=1;
nNodes=10;

cmcData=[8.99000000	      0.00733262	      0.33320676	      0.00015488	     -0.00033950	      0.05000000	      0.14376217	      0.05000000	      0.07748684	      0.05000000	      0.07254413	      0.09740720	      0.13967521	      0.11168993	      0.14165325	      0.06957605	      0.08636286	      0.05000000	      0.16171813	      0.10730129	      0.10873707];
%targetangleIn=cmcData(2:3);
targetangleIn=[pi/4 45*pi/180];
targetvelocityIn=[0 0];

initAngleIn=cmcData(2:3);
initVelocityIn=[0 0];
initMsucleAct=cmcData(6:2:end);
initMuscleLength=cmcData(7:2:end);




result = arm28DirectCoFMINCONTheFminCon(duration, targetangleIn, targetvelocityIn, nNodes, initAngleIn, initVelocityIn, initMuscleLength, initMsucleAct);


% 
% load('asdasadasd2.mat')
% N=10;
% nJoints=2;
% nMuscles=8;
% duration=1;
% 
% numJointStates = N*nJoints;   %The number of joint displacement states in vector
% numMuscleStates = N*nMuscles; %The number of muscle length states in vector
% 
% qX=x(1:numJointStates);
% lceX=x(numJointStates+1 : numJointStates+numMuscleStates );
% actX=x(numJointStates+numMuscleStates+1 : end );
% 
% qMat=reshape(qX,[],nJoints);
% % Each column is a muscle length, each row is a time
% lceMat=reshape(lceX,[],nMuscles);
% % Each column is a muscle, each row is a time
% actMat=reshape(actX,[],nMuscles);
% 
% 
% h = duration/(N-1);		% time interval between nodes
% t = h*(0:(N-1))';
% 
% i=N-2;
% 
% t=t(1:i);
% 
% columnNames={'time','TRIlong','TRIlat','TRImed','BIClong','BICshort','BRA','DeltAnt','DeltPost'};
% inDegrees=0;
% data=[t,actMat(1:i,:)];
% osMakeControlsFileSimple('Arm28FminConDCResults.sto',columnNames,data,inDegrees);
% 
% 
% % columnNames={'time','r_shoulder_elev','r_elbow_flex','r_shoulder_elev_u','r_elbow_flex_u','TRIlong.activation','TRIlong.fiber_length','TRIlat.activation','TRIlat.fiber_length','TRImed.activation','TRImed.fiber_length','BIClong.activation','BIClong.fiber_length','BICshort.activation','BICshort.fiber_length','BRA.activation','BRA.fiber_length','DeltAnt.activation','DeltAnt.fiber_length','DeltPost.activation','DeltPost.fiber_length'};
% % inDegrees=0;
% j1v=diff(qMat(:,1))/h;
% j2v=diff(qMat(:,2))/h;
% 
% j1=qMat(1:i,1);
% j2=qMat(1:i,2);
% j1v=j1v(1:i);
% j2v=j2v(1:i);
% 
% mInterlace=[]
% for m=1:nMuscles
% mInterlace=[mInterlace lceMat(:,m) actMat(:,m)];
% end
% mInterlace=mInterlace(1:i,:);
% 
% data=[t j1 j1v j2 j2v mInterlace]; 

     


