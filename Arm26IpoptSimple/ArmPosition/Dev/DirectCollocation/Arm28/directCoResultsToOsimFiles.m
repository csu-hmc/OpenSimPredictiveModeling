% Load Library
import org.opensim.modeling.*;

% Update this to location of model
osimModelName='E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\OpenSimModels\Arm26WithDelts\Arm28_Optimize.osim';

% Open a Model by name
osimModel = Model(osimModelName);

% Initialize the system and get the initial state
osimState = osimModel.initSystem();


nJoints=osimModel.getJointSet().getSize();
nMuscles=osimModel.getMuscles().getSize();

for i=1:nJoints
    jointNames{i}=char(osimModel.getJointSet().get(i-1).get_CoordinateSet().get(0));
end
for i=1:nMuscles
    muscleNames{i}=char(osimModel.getMuscles().get(i-1));
end




N=10;
duration=1;

h = duration/(N-1);		% time interval between nodes
times = h*(0:N-1)';		% list of time points


%load('asdasadasd3')
X=result.X;


numJointStates = N*nJoints;   %The number of joint displacement states in vector
numMuscleStates = N*nMuscles; %The number of muscle length states in vector
numContStates = N*nMuscles;  %The number of controls states in vector


%Get the states:
qX=X(1:numJointStates);
lceX=X(numJointStates+1 : numJointStates+numMuscleStates );
actX=X(numJointStates+numMuscleStates+1 : end );

%Now reshape into matrix.
% Each column is a joint, each row is timestep
qMat=reshape(qX,[],nJoints);
% Each column is a muscle length, each row is a time
lceMat=reshape(lceX,[],nMuscles);
% Each column is a muscle, each row is a time
actMat=reshape(actX,[],nMuscles);




targetvelocityIn=[0 0];

qdMat=diff(qMat,1,1)./h;
qdMat=[qdMat;targetvelocityIn];

dataControls=[times actMat];
muscleNames=['time' muscleNames];
osMakeControlsFileSimple('DCOutput_controls.sto',muscleNames,dataControls,0);


dataStates=times;
stateNames={'time'};
sCnt=0;
for i=1:nJoints
    sCnt=sCnt+1;
    stateNames{sCnt+1}=jointNames{i};
    
    sCnt=sCnt+1;
    stateNames{sCnt+1}=[jointNames{i} '_u'];
    
    dataStates=[dataStates qMat(:,i)];
    dataStates=[dataStates qdMat(:,i)];
end


for i=1:nMuscles
    sCnt=sCnt+1;
    stateNames{sCnt+1}=[muscleNames{i+1} '.activation'];
    sCnt=sCnt+1;
    stateNames{sCnt+1}=[muscleNames{i+1} '.fiber_length'];
    
    dataStates=[dataStates actMat(:,i)];
    dataStates=[dataStates lceMat(:,i)];
    
end


osMakeControlsFileSimple('DCOutput_states.sto',stateNames,dataStates,0);
