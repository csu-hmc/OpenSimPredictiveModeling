function result = pendOsim(duration, targetangle, targetvelocity, N, oldresult)% Finds optimal motion of a torque-driven pendulum.  Task is to move from one% static posture to another in a given time.% Method: direct collocation with 3-point discretization formula for acceleration.% Author: Ton van den Bogert <a.vandenbogert@csuohio.edu>% This work is licensed under a Creative Commons Attribution 3.0 Unported License.% http://creativecommons.org/licenses/by/3.0/deed.en_US% Inputs:%	duration		duration of the movement (s)%	targetangle		target angle (deg)%	N				number of collocation nodes to use% 	oldresult		(optional) initial guess% Notes:% 1. This code may be useful as a template for solving other optimal control problems, such%    as cart-pole upswing.% 2. IPOPT will be used when it is installed, otherwise Newton's method.  IPOPT is recommended%    because it is more robust.  Newton's method can still solve most problems, but you may%    need to solve a sequence of problems of increasing difficulty to ensure convergence.% 3. The solution may be a local optimum, especially for tasks that involve multiple%    revolutions.  Try different initial guesses (maybe random) to check for this.% The following examples all converge with IPOPT or Newton:%	r = pend(1.0, 180, 100);		% swing up in 1 second, 100 collocation nodes%   r = pend(3.0, 180, 100);		% now do it in 3 seconds, note the countermovement%   r = pend(10.0, 180, 100);		% now do it in 10 seconds, multiple countermovements are seen%   r = pend(5.0, 720, 300);		% do two full revolutions in 5 seconds, 300 collocation nodes%   r2 = pend(..,..,..,r);			% use previous result r as initial guess% settingsMaxIterations = 1000;% initializationsclose alltich = duration/(N-1);		% time interval between nodestimes = h*(0:N-1)';		% list of time points%% Setup OpenSim Model%global osimState osimModel%addpath('E:\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\Dev\PSO\PSO');addpath('E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')% Load Libraryimport org.opensim.modeling.*;%osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize_Equib.osim';osimModelName='E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\OpenSimModels\Arm26WithDelts\Arm28_OptimizeWithController.osim';%osimModelName='pendulumWithController.osim';% Open a Model by nameosimModel = Model(osimModelName);% Initialize the system and get the initial stateosimState = osimModel.initSystem();nJoints=osimModel.getJointSet().getSize();nMuscles=osimModel.getMuscles().getSize();%Ncon = N-2 + 4;			% N-2 dynamics constraints and 4 task constraintsNcon = nJoints*(N-2) + nMuscles*(N-2) + 8 + nMuscles ;% state variable is x: angle relative to hanging down% control variable is u: torque applied at jointnumJointStates = N*nJoints;   %The number of joint displacement states in vectornumMuscleStates = N*nMuscles; %The number of muscle length states in vectornumContStates = N*nMuscles;  %The number of controls states in vectorNX=numJointStates+numMuscleStates+numContStates;%Lets build the objective gradient array here because it is constantobjGradArray=zeros(NX,1);objGradArray(numJointStates+numMuscleStates+1:end)=1;x = zeros(numJointStates,1);l = zeros(numMuscleStates,1);u = zeros(numContStates,1);% The finite differnce step for the Jacobiandq=0.0001;    %delta Angledl=0.00001; %delta muslce lengthda=0.001;     %delta muscle activation     %Get the joints starting displacement and speedfor j=1:nJoints    xDefault(j)=osimModel.getCoordinateSet().get(j-1).getDefaultValue();    %xdDefault(j)=osimModel.getCoordinateSet().get(j-1).getDefaultSpeedValue();  %Will be used in the constraintsend%Make the defaults the initial guess for IPOPTxInit=repmat(xDefault,N,1);xInit=reshape(xInit,[],1);osimModel.computeStateVariableDerivatives(osimState);osimModel.equilibrateMuscles(osimState);%Get the muscle starting fiber lengthfor p=1:nMuscles    lDefault(p)=osimModel.getMuscles().get(p-1).getFiberLength(osimState);    uDefault(p)=osimModel.getMuscles().get(p-1).getActivation(osimState);endlInit=repmat(lDefault,N,1);lInit=reshape(lInit,[],1);uInit=repmat(uDefault,N,1);uInit=reshape(uInit,[],1);% encode initial guess of unknowns into a long column vector XX0 = [xInit ; lInit; uInit];% The number of task constraintsnumTaskConsPerJoint=4;numTaskConstPerMuscle=1;osimModel.computeStateVariableDerivatives(osimState);% solve the NLP with IPOPTfuncs.objective = @objfun;funcs.gradient  = @objgrad;funcs.constraints = @confun;funcs.jacobian    = @conjac;funcs.jacobianstructure = @conjacstructure;options.cl = zeros(Ncon,1);options.cu = zeros(Ncon,1);options.ipopt.max_iter = MaxIterations;options.ipopt.hessian_approximation = 'limited-memory';options.lb = [-pi/2*ones(1,N) 0*ones(1,N) 0.001*ones(1,nMuscles*N) 0.05*ones(1,nMuscles*N)];  options.ub = [pi*ones(1,N) 1.9*pi*ones(1,N) Inf*ones(1,nMuscles*N) ones(1,nMuscles*N)];% Jstruct = conjacstructure(X0);% J=conjac(X0);% c=confun(X0);%Run IPOPT[X, info] = ipopt(X0,funcs,options);% store resultsresult.t = times;result.x = X(1:N);result.u = X(N+(1:N));result.F = objfun(X);  %Objectiveresult.G = objgrad(X); %Objective Gradient[c, xdd, qdotdot] = confun(X);  %Constraintsresult.c=c;result.xdd=xdd;result.qdotdot=qdotdot;result.J = conjac(X);  %Constraint Jacobian% osimModel.print('pendulumWithController.osim')% osSimpleStorage('pendOsim.sto','controls',{'time','Torq1'},[rOsim.t rOsim.u],0);% start of embedded functions%=========================================================    function F = objfun(X)        % objective function: integral of squared controls        actX=X(numJointStates+numMuscleStates+1 : end );        F = sum(actX.^2);    end%=========================================================    function G = objgrad(X)        % gradient of the objective function coded in objfun        G = objGradArray;    end%=========================================================% 	function H = objhess(X);% 		% hessian of objective function coded in objfun% 		H = spalloc(NX,NX,N);% 		H(iu,iu) = 2 * h * speye(N,N);% 	end%=========================================================    function [c cJointAccel cMuscleVel cTaskJoints cTaskMuscles] = confun(X,Nindx,c0)                if nargin==1           Nindx=1:(N-2);         end                %Get the states:        qX=X(1:numJointStates);        lceX=X(numJointStates+1 : numJointStates+numMuscleStates );        actX=X(numJointStates+numMuscleStates+1 : end );                %Now reshape into matrix.        % Each column is a joint, each row is timestep        qMat=reshape(qX,[],nJoints);        % Each column is a muscle length, each row is a time        lceMat=reshape(lceX,[],nMuscles);        % Each column is a muscle, each row is a time        actMat=reshape(actX,[],nMuscles);                % Initialize the Joint and Muscle Dynamic Constraint Variables        if nargin==1   %If the constraints will be calculated at every N            cJointAccel=zeros(N-2,nJoints);            cMuscleVel=zeros(N-2,nMuscles);        else    %If the constraints will be updated for just a subset of N            %Nindx=max([(Nindx-2),1]):Nindx;            b=nJoints*(N-2);            c=nMuscles*(N-2);            cJointAccel=c0(1:b);            cJointAccel=reshape(cJointAccel,[],nJoints);            cMuscleVel=c0(b+1 : b+c);            cMuscleVel=reshape(cMuscleVel,[],nMuscles);        end        % Dynamic Constraints        %Each row will be a time and each column a joint Accel/muscle Velocity constraint        for i=1:length(Nindx)            n=Nindx(i);                        q1 = qMat(n,:);            q2 = qMat(n+1,:);            q3 = qMat(n+2,:);                        q = q2;            qd = (q3 - q1)/(2*h);            qdd(i,:) = (q3 - 2*q2 + q1)/(h^2); % Three-point formula for angular acceleration - Central differences                                    lce1 = lceMat(n,:);            lce2 = lceMat(n+1,:);            lce3 = lceMat(n+2,:);            lced(i,:) = (lce3 - lce1)/(2*h);            lce=lce2;                        act = actMat(n+1,:);                        [qddOsim(i,:) lcedOsim(i,:)]= armDynamics(q,qd,lce,act);                                    cJointAccel(n,:) = qddOsim(i,:) - qdd(i,:);            cMuscleVel(n,:) = lcedOsim(i,:) - lced(i,:);                     end                % Task Joint Constraints        %Each column is a joint, each row a task joint constraint        for w = 1:nJoints            % initial position must be equal to initial model angle:            cTaskJoints(1,w) = qMat(1,w) - xDefault(w);            % initial velocity must be zero:            cTaskJoints(2,w) = qMat(2,w) - qMat(1,w);     %(X(2)-X(1));            % final position must be at target angle:            cTaskJoints(3,w)= qMat(end,w) - targetangle(w)*pi/180; %X(N) - targetangle(w)*pi/180;            % final velocity must be zero:            cTaskJoints(4,w) =   (qMat(end,w) - qMat(end-1,w)) ; %(X(N)-X(N-1))/h - targetvelocity(w);        end                % Task Muscle Constraints        % Each column is a muscle, each row a task muscle contraint        for v=1:nMuscles            % initial velocity must be zero:            cTaskMuscles(1,v) = lceMat(2,v) - lceMat(1,v);        end                %Flatten (stack columns) and append        cJointAccel=reshape(cJointAccel,[],1);        cMuscleVel=reshape(cMuscleVel,[],1);        cTaskJoints=reshape(cTaskJoints,[],1);        cTaskMuscles=reshape(cTaskMuscles,[],1);                c=[cJointAccel;cMuscleVel;cTaskJoints;cTaskMuscles];            end%=========================================================    function J=conJacFull(X)    %Function to build full Jacobian by iteration over all elements            %Get the states:    xDisp0=X(1:numJointStates);    xMuscle0=X(numJointStates+1 : numJointStates+numMuscleStates );    uAct0=X(numJointStates+numMuscleStates+1 : end );        c0 = confun(X);        for i=1:NX       if i<=numJointStates          del= dq;       elseif i>numJointStates & i<=(numJointStates+numMuscleStates)           del=dl;       else           del=da;       end       Xp=X;  %perturbed X       Xp(i)=Xp(i)+del;       cp = confun(Xp);              J(:,i)=(cp-c0)/del;           end        cccc=1;    end          %=========================================================      function J = conjac(X)                     %Get the "operating point"        [c0 cJointAccel0 cMuscleVel0 cTaskJoints0 cTaskMuscles0] = confun(X);                %Get the states:        xDisp0=X(1:numJointStates);        xMuscle0=X(numJointStates+1 : numJointStates+numMuscleStates );        uAct0=X(numJointStates+numMuscleStates+1 : end );                       %Joint Position Inputs        conCnt=0;        for jointCnt=1:nJoints            for nCnt=1:N                %conCnt=(jointCnt-1)*N + nCnt;                conCnt=conCnt+1;                Xp=X;                Xp(conCnt)=Xp(conCnt)+dq;                             Nindx=max([(nCnt-2),1]):min(N-2,nCnt);                cout = confun(Xp,Nindx,c0);                cdiff(:,conCnt)=(cout-c0)/dq;                           end        end                %Muscle Length Inputs        for muscleCnt=1:nMuscles            for nCnt=1:N                conCnt=conCnt+1;                Xp=X;                Xp(conCnt)=Xp(conCnt)+dl;                Nindx=max([(nCnt-2),1]):min(N-2,nCnt);                %Nindx=min(N-2,max(nCnt-1,1));                %Nindx=nCnt;                cout = confun(Xp,Nindx,c0);                cdiff(:,conCnt)=(cout-c0)/dl;            end        end                %Muscle Activation Inputs        for muscleCnt=1:nMuscles            for nCnt=1:N                conCnt=conCnt+1;                Xp=X;                Xp(conCnt)=Xp(conCnt)+da;                %This could be optimized further in that only the diganol needs to be performed.                Nindx=max([(nCnt-2),1]):min(N-2,nCnt);                  cout = confun(Xp,Nindx,c0);                cdiff(:,conCnt)=(cout-c0)/da;            end        end                        J=sparse(cdiff);    end%=========================================================    function J = conjacstructure(X)                        zeroMat=zeros(N-2,N);                %Create a prototype matrix of a N-2 by N with ones on the diagnonal        %shift up 1        diag1=diag(ones(N-2,1),1);        diag1(end,:)=[];        diag1=[diag1 zeros(size(diag1,1),1)];                %Create a prototype matrix of a N-2 by N with ones on the upper 3        %diagonals        diag3=diag(ones(N,1)) + diag(ones(N-1,1),1) + diag(ones(N-2,1),2);        diag3=diag3(1:end-2,:);                                %Create the Dynmamic constraint rows for joint acceleration        singleJoint=[ repmat(diag3,1,nJoints)   repmat(diag1,1,nMuscles)  repmat(zeroMat,1,nMuscles) ];        jAccelC=repmat(singleJoint,nJoints,1);                %Create the Dynamic constraint rows for muscle velocities        jIn_mVelC=repmat(diag1,nMuscles,nJoints);                tmp = repmat({diag3},nMuscles,1);        mLenIn_mVelC = blkdiag(tmp{:});                tmp = repmat({diag1},nMuscles,1);        actIn_mVelC = blkdiag(tmp{:});                mVelC=[jIn_mVelC mLenIn_mVelC actIn_mVelC];  %Concatinating                %The dyanmic constraint portion of the Jacobian        dynJac=[jAccelC ; mVelC];                                        %Task portion of jacobian        posDiag=zeros(4,N);        posDiag(1,1)=1; posDiag(2,1:2)=1; posDiag(4-1,N)=1; posDiag(4,(N-1):N)=1;                tmp = repmat({posDiag},nJoints,1);        jIn_jC = blkdiag(tmp{:});                tmp = zeros(size(jIn_jC,1),N*2*nMuscles);        jIn_jC = [jIn_jC  tmp];                        mIn_mC=zeros(nMuscles, (nJoints+2*nMuscles)*N );        jOffset=nJoints*N;        for i=0:nMuscles-1            mIn_mC(i+1,jOffset+(i*N)+1)=1;            mIn_mC(i+1,jOffset+(i*N)+3)=1;        end                taskJac=[jIn_jC; mIn_mC];                J=[dynJac;taskJac];                J=sparse(J);            end%============================================================    function [qddOsim lcedOsim] = armDynamics(q,qd,lce,act)                %Set the kinematic properties        for i=1:nJoints            osimModel.getCoordinateSet().get(i-1).setValue(osimState,q(i));            osimModel.getCoordinateSet().get(i-1).setSpeedValue(osimState,qd(i));        end        osimModel.computeStateVariableDerivatives(osimState);                %Set Muscle Parameters        muscleObj=[];        for i=1:nMuscles            %Set the muscle parameters            forceObj=osimModel.getMuscles().get(i-1);            muscleType = char(forceObj.getConcreteClassName);            eval(['muscleObj =' muscleType '.safeDownCast(forceObj);']);            muscleObj.setActivation(osimState, act(i));            muscleObj.setFiberLength(osimState, lce(i) );        end                osimModel.computeStateVariableDerivatives(osimState);                %Ask Opensim for state variables        for i=1:nJoints            qddOsim(i)=osimModel.getCoordinateSet().get(i-1).getAccelerationValue(osimState);  %Joint Accelerations        end        for i=1:nMuscles            lcedOsim(i)=osimModel.getMuscles().get(i-1).getFiberVelocity(osimState);   %Lce Velocity        end    endend