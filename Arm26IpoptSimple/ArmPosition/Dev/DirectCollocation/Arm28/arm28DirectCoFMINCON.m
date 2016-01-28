function result = arm28DirectCoFMINCON(duration, targetangleIn, targetvelocityIn, nNodes, initMuscleLength, initMsucleAct, oldresult)% Finds optimal motion of the Arm28 model (2 joints, 8 muscle model).% Task is to move from one static posture to another in a given time.% Method: direct collocation with 3-point discretization formula for acceleration.%% This is based on Dr. Ton van den Bogert's pendulum example code%% Inputs:%	duration		duration of the movement (s)%	targetangle		target angle (deg) of the joints%   targetVelocity  (Reserved)%	nNodes				number of collocation nodes to use% 	oldresult       (Reserved)%%  Example:%%     result = arm28DirectCo(2,[pi/2 0],[],20);global h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2 ax1 ax2N=nNodes;targetangle=targetangleIn;targetvelocity=targetvelocityIn;% settingsMaxIterations = 1000;% initializationsclose alltich = duration/(N-1);		% time interval between nodestimes = h*(0:N-1)';		% list of time points%% Setup OpenSim Model%Add the path with osim utilities the model exists%addpath('E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')% Load Libraryimport org.opensim.modeling.*;% Update this to location of modelosimModelName='E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\OpenSimModels\Arm26WithDelts\Arm28_Optimize.osim';% Open a Model by nameosimModel = Model(osimModelName);% Initialize the system and get the initial stateosimState = osimModel.initSystem();nJoints=osimModel.getJointSet().getSize();nMuscles=osimModel.getMuscles().getSize();Ncon = nJoints*(N-2) + nMuscles*(N-2) + 8 + nMuscles ;  %Number of constraintsnumJointStates = N*nJoints;   %The number of joint displacement states in vectornumMuscleStates = N*nMuscles; %The number of muscle length states in vectornumContStates = N*nMuscles;  %The number of controls states in vectorNX=numJointStates+numMuscleStates+numContStates;%Build the objective gradient array here because it is constantobjGradArray=zeros(NX,1);objGradArray(numJointStates+numMuscleStates+1:end)=2;%Proto type the input variablesx = zeros(numJointStates,1);l = zeros(numMuscleStates,1);u = zeros(numContStates,1);% The finite differnce step for the Jacobiandq=0.00001;    %delta Angledl=0.00001; %delta muslce lengthda=0.0001;     %delta muscle activation%[theta,mact,mlength]=modelStateFromMotFile();% %Get the joints starting displacement and speed% for j=1:nJoints%     xDefault(j)=osimModel.getCoordinateSet().get(j-1).getDefaultValue();%     %xdDefault(j)=osimModel.getCoordinateSet().get(j-1).getDefaultSpeedValue();  %Will be used in the constraints% end% % %xDefault=theta;% %targetangle=theta;xDefault=targetangleIn;%Make the defaults the initial guess for IPOPTxInit=repmat(xDefault,N,1);xInit=reshape(xInit,[],1);%osimModel.computeStateVariableDerivatives(osimState);%osimModel.equilibrateMuscles(osimState);% %Get the muscle starting fiber length% for p=1:nMuscles%     %     aaaaa=osimModel.getMuscles().get(p-1);%     lDefault(p)=osimModel.getMuscles().get(p-1).getFiberLength(osimState);%     uDefault(p)=osimModel.getMuscles().get(p-1).getActivation(osimState);%     %     % endlDefault=initMuscleLength;uDefault=initMsucleAct;lmin=lDefault*0.25;lmin=reshape(repmat(lmin,N,[]),1,[]);lmax=lDefault*2;lmax=reshape(repmat(lmax,N,[]),1,[]);%Make every time step equal to these valueslInit=repmat(lDefault,N,1);lInit=reshape(lInit,[],1);uInit=repmat(uDefault,N,1);uInit=reshape(uInit,[],1);% encode initial guess of unknowns into a long column vector XX0 = [xInit ; lInit; uInit];% The number of task constraintsnumTaskConsPerJoint=4;numTaskConstPerMuscle=1;% solve the NLP with IPOPTfuncs.objective = @objfun;funcs.gradient  = @objgrad;funcs.constraints = @confun;funcs.jacobian    = @conjac;funcs.jacobianstructure = @conjacstructure;options.cl = zeros(Ncon,1);options.cu = zeros(Ncon,1);%options.ipopt.max_iter = 10;options.ipopt.hessian_approximation = 'limited-memory';options.ipopt.mu_strategy='adaptive';%options.lb = [-pi/2*ones(1,N) 0.0873*ones(1,N) 0.001*ones(1,nMuscles*N) 0.01*ones(1,nMuscles*N)];%options.ub = [pi*ones(1,N) 1.9*pi*ones(1,N) 1*ones(1,nMuscles*N) ones(1,nMuscles*N)];options.lb = [-pi/2*ones(1,N) 0.0873*ones(1,N) lmin 0.01*ones(1,nMuscles*N)];options.ub = [pi*ones(1,N) 1.9*pi*ones(1,N) lmax ones(1,nMuscles*N)];options.ipopt.constr_viol_tol=0.01;exNum=0;l1=0;l2=0;[c d]=confun(X0);%J = full(conjac(X0));%Jf = full(conJacFull(X0));% dp=[-0.5:0.001:0.5];% for i=1:length(dp)%     xd=X0;%     xd(72)=xd(72)*(1+dp(i));%     [c2 d2]=confun(xd,1,c);%     c57(i)=c2(57);%     % end% figure% plot(dp,c57)figuresubplot(2,1,1)l1=line(1:size(X0),X0);hold online(1:size(X0),X0,'color','r');xlabel('Input #')ylabel('Input Value')legend('Current Guess','Initial Guess')subplot(2,1,2)l2=line(1:size(c),c);hold online(1:size(c),c,'color','r');xlabel('Constraint #')ylabel('Constraint Value')figuresubplot(2,1,1)plot(NaN,NaN)hold onylabel('Objective')ax1=gca;subplot(2,1,2)plot(NaN,NaN)hold onax2=gca;ylabel('Max Norm(C)')xlabel('Iteration #')% Run IPOPT[X, info] = ipopt(X0,funcs,options);% Store resultsresult.t = times;result.x = X;result.F = objfun(X);  %Objectiveresult.G = objgrad(X); %Objective Gradientresult.c = confun(X);result.J = conjac(X);  %Constraint Jacobian% osimModel.print('pendulumWithController.osim')% osSimpleStorage('pendOsim.sto','controls',{'time','Torq1'},[rOsim.t rOsim.u],0);% start of embedded functions%=========================================================function F = objfun(X)% objective function: integral of squared controlsglobal h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2 ax1 ax2actX=X(numJointStates+numMuscleStates+1 : end );F = 100*sum(actX.^2);exNum=exNum+1;axes(ax1)plot(exNum,F,'linestyle','none','marker','.','markersize',10,'color','b')%=========================================================function G = objgrad(X)global h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2% gradient of the objective function coded in objfunG = 100*objGradArray.*X;%=========================================================function [c d] = confun(X,Nindx,c0)%Constraint function%   Inputs%       X - input variables%       Nindex - optional, a vector of time steps to calculate the%           constraints over.  This allows for the function to%           perform only the calculations at time steps that are%           required (for example, the effect of changing the joint%           2's position at N=10 does not need to be calculated for%           the acceleration at N=1).  If the function is called%           with only one argument, c=confun(X), all time steps are%           evaluated.%       c0 - the constarint vector to be updated when Nindex is%           used.%global h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2 ax1 ax2if nargin==1    Nindx=1:(N-2);end%Get the states:qX=X(1:numJointStates);lceX=X(numJointStates+1 : numJointStates+numMuscleStates );actX=X(numJointStates+numMuscleStates+1 : end );%Now reshape into matrix.% Each column is a joint, each row is timestepqMat=reshape(qX,[],nJoints);% Each column is a muscle length, each row is a timelceMat=reshape(lceX,[],nMuscles);% Each column is a muscle, each row is a timeactMat=reshape(actX,[],nMuscles);% Initialize the Joint and Muscle Dynamic Constraint Variablesif nargin==1   %If the constraints will be calculated at every N    cJointAccel=zeros(N-2,nJoints);    cMuscleVel=zeros(N-2,nMuscles);else    %If the constraints will be updated for just a subset of N    %Nindx=max([(Nindx-2),1]):Nindx;    b=nJoints*(N-2);    c=nMuscles*(N-2);    cJointAccel=c0(1:b);    cJointAccel=reshape(cJointAccel,[],nJoints);    cMuscleVel=c0(b+1 : b+c);    cMuscleVel=reshape(cMuscleVel,[],nMuscles);end% Dynamic Constraints%Each row will be a time and each column a joint Accel/muscle Velocity constraintfor i=1:length(Nindx)        n=Nindx(i);        q1 = qMat(n,:);    q2 = qMat(n+1,:);    q3 = qMat(n+2,:);        q = q2;    qd = (q3 - q1)/(2*h);    qdd(i,:) = (q3 - 2*q2 + q1)/(h^2); % Three-point formula for angular acceleration - Central differences            lce1 = lceMat(n,:);    lce2 = lceMat(n+1,:);    lce3 = lceMat(n+2,:);    lced(i,:) = (lce3 - lce1)/(2*h);    lce=lce2;        act = actMat(n+1,:);        [qddOsim(i,:) lcedOsim(i,:)]= armDynamics(q,qd,lce,act);        cJointAccel(n,:) = (    qddOsim(i,:)*(h^2) - qdd(i,:)*(h^2)    )/1000;    cMuscleVel(n,:) = (lcedOsim(i,:)*(2*h) - lced(i,:)*(2*h) )  /100;    end% Task Joint Constraints%Each column is a joint, each row a task joint constraintfor w = 1:nJoints    % initial position must be equal to initial model angle:    cTaskJoints(1,w) = qMat(1,w) - xDefault(w);    % initial velocity must be zero:    cTaskJoints(2,w) = qMat(2,w) - qMat(1,w);     %(X(2)-X(1));    % final position must be at target angle:    cTaskJoints(3,w)= qMat(end,w) - targetangle(w); %X(N) - targetangle(w)*pi/180;    % final velocity must be zero:    cTaskJoints(4,w) =   (qMat(end,w) - qMat(end-1,w)) ; %(X(N)-X(N-1))/h - targetvelocity(w);end% Task Muscle Constraints% Each column is a muscle, each row a task muscle contraintfor v=1:nMuscles    % initial velocity must be zero:    cTaskMuscles(1,v) = lceMat(2,v) - lceMat(1,v);end%Flatten (stack columns) and appendcJointAccel=reshape(cJointAccel,[],1);cMuscleVel=reshape(cMuscleVel,[],1);cTaskJoints=reshape(cTaskJoints,[],1);cTaskMuscles=reshape(cTaskMuscles,[],1);c=[cJointAccel;cMuscleVel;cTaskJoints;cTaskMuscles];if max(abs(c))>100    pppppppppp=1;endif nargout>1    d.qddOsim=qddOsim;    d.lcedOsim=lcedOsim;    d.cJointAccel=cJointAccel;    d.cMuscleVel=cMuscleVel;    d.cTaskJoints=cTaskJoints;    d.cTaskMuscles=cTaskMuscles;endif nargin==1 & l1~=0    set(l1,'ydata',X)    set(l2,'ydata',c)    %pause    exNum=exNum+1;    axes(ax2)    plot(exNum,max(abs(c)),'linestyle','none','marker','.','markersize',10,'color','r')    drawnowend%=========================================================function J=conJacFull(X)%Function to build full Jacobian by iteration over all elements.%Not used by IPOPT as it is slow (all elements of the Jacoboian are%calculated.  Used for troubleshooting.%Get the states:xDisp0=X(1:numJointStates);xMuscle0=X(numJointStates+1 : numJointStates+numMuscleStates );uAct0=X(numJointStates+numMuscleStates+1 : end );c0 = confun(X);for i=1:NX    if i<=numJointStates        del= dq;    elseif i>numJointStates & i<=(numJointStates+numMuscleStates)        del=dl;    else        del=da;    end    Xp=X;  %perturbed X    Xp(i)=Xp(i)+del;    cp = confun(Xp);        J(:,i)=(cp-c0)/del;    end%=========================================================function J = conjac(X)%Function to calculate the constraint Jacobianglobal h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2%Get the "operating point"c0 = confun(X);%Get the states:xDisp0=X(1:numJointStates);xMuscle0=X(numJointStates+1 : numJointStates+numMuscleStates );uAct0=X(numJointStates+numMuscleStates+1 : end );%Joint Position InputsconCnt=0;for jointCnt=1:nJoints    for nCnt=1:N        %conCnt=(jointCnt-1)*N + nCnt;        conCnt=conCnt+1;        Xp=X;        Xp(conCnt)=Xp(conCnt)+dq;        Nindx=max([(nCnt-2),1]):min(N-2,nCnt);        cout = confun(Xp,Nindx,c0);        cdiff(:,conCnt)=(cout-c0)/dq;    endend%Muscle Length Inputsfor muscleCnt=1:nMuscles    for nCnt=1:N        conCnt=conCnt+1;        Xp=X;        Xp(conCnt)=Xp(conCnt)+dl;        Nindx=max([(nCnt-2),1]):min(N-2,nCnt);        %Nindx=min(N-2,max(nCnt-1,1));        %Nindx=nCnt;        cout = confun(Xp,Nindx,c0);        cdiff(:,conCnt)=(cout-c0)/dl;    endend%Muscle Activation Inputsfor muscleCnt=1:nMuscles    for nCnt=1:N        conCnt=conCnt+1;        Xp=X;        Xp(conCnt)=Xp(conCnt)+da;        %This could be optimized further in that only the diganol needs to be performed.        Nindx=max([(nCnt-2),1]):min(N-2,nCnt);        cout = confun(Xp,Nindx,c0);        cdiff(:,conCnt)=(cout-c0)/da;    endendJ=sparse(cdiff);%=========================================================function J = conjacstructure(X)%Function to calculate the constraint jacobianglobal h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2% A zero matrix prototypezeroMat=zeros(N-2,N);%Create a prototype matrix of a N-2 by N with ones on the diagnonal%shift up 1diag1=diag(ones(N-2,1),1);diag1(end,:)=[];diag1=[diag1 zeros(size(diag1,1),1)];%Create a prototype matrix of a N-2 by N with ones on the upper 3%diagonalsdiag3=diag(ones(N,1)) + diag(ones(N-1,1),1) + diag(ones(N-2,1),2);diag3=diag3(1:end-2,:);%Create the Dynmamic constraint rows for joint accelerationsingleJoint=[ repmat(diag3,1,nJoints)   repmat(diag1,1,nMuscles)  repmat(zeroMat,1,nMuscles) ];jAccelC=repmat(singleJoint,nJoints,1);%Create the Dynamic constraint rows for muscle velocitiesjIn_mVelC=repmat(diag1,nMuscles,nJoints);tmp = repmat({diag3},nMuscles,1);mLenIn_mVelC = blkdiag(tmp{:});tmp = repmat({diag1},nMuscles,1);actIn_mVelC = blkdiag(tmp{:});mVelC=[jIn_mVelC mLenIn_mVelC actIn_mVelC];  %Concatinating%The dyanmic constraint portion of the JacobiandynJac=[jAccelC ; mVelC];%Task portion of jacobianposDiag=zeros(4,N);posDiag(1,1)=1; posDiag(2,1:2)=1; posDiag(4-1,N)=1; posDiag(4,(N-1):N)=1;tmp = repmat({posDiag},nJoints,1);jIn_jC = blkdiag(tmp{:});tmp = zeros(size(jIn_jC,1),N*2*nMuscles);jIn_jC = [jIn_jC  tmp];mIn_mC=zeros(nMuscles, (nJoints+2*nMuscles)*N );jOffset=nJoints*N;for i=0:nMuscles-1    mIn_mC(i+1,jOffset+(i*N)+1)=1;    mIn_mC(i+1,jOffset+(i*N)+3)=1;endtaskJac=[jIn_jC; mIn_mC];J=[dynJac;taskJac];J=sparse(J);%============================================================function [qddOsim lcedOsim] = armDynamics(q,qd,lce,act)%Function to evaluate the states of the model at a particular time%step.%   Inputs:%        q - vector of joint angles%        qd - vector of joint velocities%       lce - vector of muscle length%       act - vector of muscl activations%   Outputs%       qddOsim - vector of joint accelerations%       lcedOsim - vector of muscle velocities% Load Libraryimport org.opensim.modeling.*;global h N osimModel osimState nJoints nMuscles numJointStates numMuscleStates NX objGradArray dq dl da xDefault targetangle targetvelocity exNum l1 l2%Set the kinematic propertiesfor i=1:nJoints    osimModel.getCoordinateSet().get(i-1).setValue(osimState,q(i));    osimModel.getCoordinateSet().get(i-1).setSpeedValue(osimState,qd(i));endosimModel.computeStateVariableDerivatives(osimState);%Set Muscle ParametersmuscleObj=[];for i=1:nMuscles    %Set the muscle parameters    forceObj=osimModel.getMuscles().get(i-1);    muscleType = char(forceObj.getConcreteClassName);    eval(['muscleObj =' muscleType '.safeDownCast(forceObj);']);    muscleObj.setActivation(osimState, act(i));    muscleObj.setFiberLength(osimState, lce(i) );endosimModel.computeStateVariableDerivatives(osimState);%Ask Opensim for state variablesfor i=1:nJoints    qddOsim(i)=osimModel.getCoordinateSet().get(i-1).getAccelerationValue(osimState);  %Joint Accelerationsendfor i=1:nMuscles    lcedOsim(i)=osimModel.getMuscles().get(i-1).getFiberVelocity(osimState);   %Lce Velocityend