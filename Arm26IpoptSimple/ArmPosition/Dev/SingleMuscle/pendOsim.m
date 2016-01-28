function result = pendOsim(duration, targetangle, targetvelocity, N, oldresult)% Finds optimal motion of a torque-driven pendulum.  Task is to move from one% static posture to another in a given time.% Method: direct collocation with 3-point discretization formula for acceleration.% Author: Ton van den Bogert <a.vandenbogert@csuohio.edu>% This work is licensed under a Creative Commons Attribution 3.0 Unported License.% http://creativecommons.org/licenses/by/3.0/deed.en_US% Inputs:%	duration		duration of the movement (s)%	targetangle		target angle (deg)%	N				number of collocation nodes to use% 	oldresult		(optional) initial guess% Notes:% 1. This code may be useful as a template for solving other optimal control problems, such%    as cart-pole upswing.% 2. IPOPT will be used when it is installed, otherwise Newton's method.  IPOPT is recommended%    because it is more robust.  Newton's method can still solve most problems, but you may%    need to solve a sequence of problems of increasing difficulty to ensure convergence.% 3. The solution may be a local optimum, especially for tasks that involve multiple%    revolutions.  Try different initial guesses (maybe random) to check for this.% The following examples all converge with IPOPT or Newton:%	r = pend(1.0, 180, 100);		% swing up in 1 second, 100 collocation nodes%   r = pend(3.0, 180, 100);		% now do it in 3 seconds, note the countermovement%   r = pend(10.0, 180, 100);		% now do it in 10 seconds, multiple countermovements are seen%   r = pend(5.0, 720, 300);		% do two full revolutions in 5 seconds, 300 collocation nodes%   r2 = pend(..,..,..,r);			% use previous result r as initial guess% settingsMaxIterations = 1000;% initializationsclose alltich = duration/(N-1);		% time interval between nodestimes = h*(0:N-1)';		% list of time points%% Setup OpenSim Model%global osimState osimModel%addpath('E:\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\Dev\PSO\PSO');addpath('E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\common')% Load Libraryimport org.opensim.modeling.*;%osimModelName='OpenSimModels/Arm26WithDelts/Arm28_Optimize_Equib.osim';osimModelName='E:\Data\Projects\DigAstro\PredictiveModeling\OpenSimPredictiveModeling\Arm26IpoptSimple\ArmPosition\Dev\SingleMuscle\muscle-mass11.osim';%osimModelName='pendulumWithController.osim';% Open a Model by nameosimModel = Model(osimModelName);% Initialize the system and get the initial stateosimState = osimModel.initSystem();nJoints=osimModel.getJointSet().getSize();nMuscles=osimModel.getMuscles().getSize();%Ncon = N-2 + 4;			% N-2 dynamics constraints and 4 task constraintsNcon = nJoints*(N-2) + nJoints*4;% state variable is x: angle relative to hanging down% control variable is u: torque applied at jointnumJointStates = N*nJoints;   %The number of joint displacement states in vectornumMuscleStates = N*nMuscles; %The number of muscle length states in vectornumContStates = N*nMuscles;  %The number of controls states in vectorx = zeros(numJointStates,1);l = zeros(numMuscleStates,1);u = zeros(numContStates,1);%Get the joints starting displacement and speedfor j=1:nJoints    xDefault(j)=osimModel.getCoordinateSet().get(j-1).getDefaultValue();    %xdDefault(j)=osimModel.getCoordinateSet().get(j-1).getDefaultSpeedValue();  %Will be used in the constraintsend%Make the defaults the initial guess for IPOPTx=repmat(xDefault,N,1);x=reshape(x,[],1);%Get the muscle starting fiber lengthfor p=1:nMuscles    lDefault(p)=osimModel.getMuscles().get(p-1).getFiberLength(osimState);endl=repmat(lDefault,N,1);l=reshape(l,[],1);% encode initial guess of unknowns into a long column vector XX0 = [x ; l; u];% The number of task constraintsnumTaskConsPerJoint=4;numTaskConstPerMuscle=1;osimModel.computeStateVariableDerivatives(osimState);% solve the NLP with IPOPTfuncs.objective = @objfun;funcs.gradient  = @objgrad;funcs.constraints = @confun;funcs.jacobian    = @conjac;funcs.jacobianstructure = @conjacstructure;options.cl = zeros(Ncon,1);options.cu = zeros(Ncon,1);options.ipopt.max_iter = MaxIterations;options.ipopt.hessian_approximation = 'limited-memory';[c, xdd, qdotdot]= confun(X0);%conjac(X0)aaa=1;[X, info] = ipopt(X0,funcs,options);% plot resultsshow(X, confun(X));% store resultsresult.t = times;result.x = X(1:N);result.u = X(N+(1:N));result.F = objfun(X);  %Objectiveresult.G = objgrad(X); %Objective Gradient[c, xdd, qdotdot] = confun(X);  %Constraintsresult.c=c;result.xdd=xdd;result.qdotdot=qdotdot;result.J = conjac(X);  %Constraint Jacobian%osimModel.print('pendulumWithController.osim')% osSimpleStorage('pendOsim.sto','controls',{'time','Torq1'},[rOsim.t rOsim.u],0);% start of embedded functions%=========================================================    function F = objfun(X);        % objective function: integral of squared controls        F = h * sum(X(iu).^2);    end%=========================================================    function G = objgrad(X);        % gradient of the objective function coded in objfun        G = zeros(NX,1);        G(iu) = 2 * h * X(iu);    end%=========================================================% 	function H = objhess(X);% 		% hessian of objective function coded in objfun% 		H = spalloc(NX,NX,N);% 		H(iu,iu) = 2 * h * speye(N,N);% 	end%=========================================================    function [c, xDispMat, xMuscleMat, uActMat] = confun(X)                        %Ncon = N-2 + 4;			% N-2 dynamics constraints and 4 task constraints                                % state variable is x: angle relative to hanging down        % control variable is u: torque applied at joint                                % constraint function (dynamics constraints and task constraints)                % size of constraint vector        %c = zeros(Ncon,1);                % dynamics constraints        % Note: torques at node 1 and node N do not affect movement and will therefore        % always be zero in a minimal-effort solution.                %Get the states:        xDisp=X(1:numJointStates);        xMuscle=X(numJointStates+1 : numJointStates+numMuscleStates );        uAct=X(numJointStates+numMuscleStates+1 : end );                        %Now reshape into matrix.        % Each column is a joint, each row is timestep        xDispMat=reshape(xDisp,[],nJoints);        % Each column is a muscle, each row is a time        xMuscleMat=reshape(xMuscle,[],nMuscles);        uActMat=reshape(uAct,[],nMuscles);                % Dynamic Constraints        %Each row will be a time and each column a joint Accel/muscle Velocity constraint        for i=1:N-2            x1 = xDispMat(i,:);            x2 = xDispMat(i+1,:);            x3 = xDispMat(i+2,:);                        l1 = xMuscleMat(i,:);            l2 = xMuscleMat(i+1,:);            l3 = xMuscleMat(i+2,:);                        u2 = uActMat(i+1,:);                        [cJointAccel(i,:), cMuscleVel(i,:)] = constPend(x1,x2,x3,l1,l2,l3,u2);                                    %c(i) =  xdd - ( -m * g * L*sin(x2) + u2) / I;		% equation of motion must be satisfied            aaa=1;        end                % Task Joint Constraints        %Each column is a joint, each row a task joint constraint        for w = 1:nJoints            % initial position must be equal to initial model angle:            cTaskJoints(1,w) = xDispMat(1,w) - xDefault(w);            % initial velocity must be zero:            cTaskJoints(2,w) = xDispMat(2,w) - xDispMat(1,w);     %(X(2)-X(1));            % final position must be at target angle:            cTaskJoints(3,w)= xDispMat(end,w) - targetangle(w)*pi/180; %X(N) - targetangle(w)*pi/180;            % final velocity must be zero:            cTaskJoints(4,w) =   (xDispMat(end,w) - xDispMat(end-1,w))/h - targetvelocity(w) ; %(X(N)-X(N-1))/h - targetvelocity(w);        end                % Task Muscle Constraints        % Each column is a muscle, each row a task muscle contraint        for v=1:nMuscles            % initial velocity must be zero:            cTaskMuscles(1,v) = xMuscleMat(end,v) - xMuscleMat(end-1,v);        end                %Flatten (stack columns) and append        cJointAccel=reshape(cJointAccel,[],1);        cMuscleVel=reshape(cMuscleVel,[],1);        cTaskJoints=reshape(cTaskJoints,[],1);        cTaskMuscles=reshape(cTaskMuscles,[],1);                c=[cJointAccel;cMuscleVel;cTaskJoints;cTaskMuscles];            end%=========================================================    function J = conjac(X)                dx=0.001;        du=0.05;                [c0, xDispMat0, xMuscleMat0, uActMat0] = confun(X);                dynCnt=(nJoints+2*nMuscles)*N;        for n=1:dynCnt            Xp=X;                        if dynCnt<=100                del=dx;            else                del=du;            end            Xp(n)=Xp(n)+del;            c1(:,n) = confun(Xp);            d(:,n)=(c1(:,n)-c0)/del;            aaa=1;        end                %Get the states:        xDisp0=X(1:numJointStates);        xMuscle0=X(numJointStates+1 : numJointStates+numMuscleStates );        uAct0=X(numJointStates+numMuscleStates+1 : end );                                %Make a matrix with the dynamic constraint 3 diagaonal format        jEye=spalloc(N-2,N,N);        for i =1:N-2            jEye(i,i)=1;            jEye(i,i+1)=1;            jEye(i,i+2)=1;        end                        %Joint Dynamic Constraints to Joint Position Input        jJointAcc_JointPos_Dyn=repmat(jEye,nJoints,nJoints);                %Muscle Velocity Dynamic Constraints to Joint Position Input        jMuscleVel_JointPos_Dyn=repmat(jEye,nMuscles,nJoints);                % Joint Task Constraints        jTaskProto=spalloc(numTaskConsPerJoint,N,N);        jTaskProto(1:2,1)=1;        jTaskProto(2,2)=1;        jTaskProto(end-1:end,end)=1;        jTaskProto(end,end-1)=1;        %Now make a diagnonal matrix of matrices        repCell = repmat({jTaskProto}, 1, nJoints);        jJoint_Joint_Task = full(blkdiag(repCell{:}));                %Muscle Task Constraints with Joint Input        jMuscle_Joint_Task=spalloc(nMuscles,nJoints*N,0);                                                for jnum=1:nJoints            iJointOffset=(jnum-1)*N +1;            for nnum=1:N-2                                x1 = X(iJointOffset+nnum);                x2 = X(iJointOffset+nnum+1);                x3 = X(iJointOffset+nnum+2);                                                                [cJointAccel1, cMuscleVel1] = constPend(x1+dx,x2,x3,l1,l2,l3,u2);                [cJointAccel2, cMuscleVel2] = constPend(x1,x2,x3+dx,l1,l2,l3,u2);                [cJointAccel3, cMuscleVel3] = constPend(x1,x2,x3+dx,l1,l2,l3,u2);                                                J(i,i) 		= (c0x1-c0)/dx;                J(i,i+1) 	= (c0x2-c0)/dx;                J(i,i+2) 	= (c0x3-c0)/dx;                                                            end        end                %         %         %Joint Dynamics Constraints%         %         %Get JointAccelConstraints%         %         %         %         % dynamics constraints%         for i=1:N-2%             % Jacobian matrix: derivatives of c(i) with respect to the elements of X%             % 			x2 = X(i+1);%             % 			J(i,i) 		= 1/h^2;%             % 			J(i,i+1) 	= -2/h^2 + m * g * L * cos(x2) / I;%             % 			J(i,i+2) 	= 1/h^2;%             % 			J(i,N+i+1) 	= -1/I;%             %             %             x1 = X(i);%             x2 = X(i+1);%             x3 = X(i+2);%             %u2 = X(N+i+1);%             %u2 = X(N+i);%             %             c0 = constPend(x1,x2,x3,u2);%             c0x1 = constPend(x1+dx,x2,x3,u2);%             c0x2 = constPend(x1,x2+dx,x3,u2);%             c0x3 = constPend(x1,x2,x3+dx,u2);%             %c0u2 = constPend(x1,x2,x3,u2+du);%             %             J(i,i) 		= (c0x1-c0)/dx;%             J(i,i+1) 	= (c0x2-c0)/dx;%             J(i,i+2) 	= (c0x3-c0)/dx;%             %J(i,N+i+1) 	= (c0u2-c0)/du;%             %             %         end%         aaa=1;%         % task constraints%         %         %         % initial position must be zero:%         J(N-1,	1) = 1;%         % initial velocity must be zero:%         J(N,2) = 1;%         J(N,1) = -1;%         % final position must be at target angle:%         J(N+1,N) = 1;%         % final velocity must be zero:%         J(N+2,N) = 1;%         J(N+2,N-1) = -1;%         %Jf=full(J);%             end%=========================================================    function J = conjacstructure(X)                % size of Jacobian        J = spalloc(Ncon,NX,4*(N-2) + 6);                % dynamics constraints        for i=1:N-2            % Jacobian matrix: derivatives of c(i) with respect to the elements of X            J(i,i) 		= 1;            J(i,i+1) 	= 1;            J(i,i+2) 	= 1;            J(i,N+i+1) 	= 1;        end                % task constraints                % initial position must be zero:        J(N-1,	1) = 1;        % initial velocity must be zero:        J(N,2) = 1;        J(N,1) = 1;        % final position must be at target angle:        J(N+1,N) = 1;        % final velocity must be zero:        J(N+2,N) = 1;        J(N+2,N-1) = 1;            end%============================================================    function show(X,c)        % plot the current solution        x = X(ix);        u = X(iu);        figure        subplot(3,1,1);plot(times,x*180/pi);title('angle')        subplot(3,1,2);plot(times,u);title('torque');        subplot(3,1,3);plot(c);title('constraint violations');    end%============================================================    function [cJointAccel, cMuscleVel, xdd, qdotdot, ld, mdot] = constPend(x1,x2,x3,l1,l2,l3,u)                %xd = (x2 - x1)/h;        xd = (x3 - x1)/(2*h);        xdd = (x3 - 2*x2 + x1)/(h^2); % Three-point formula for angular acceleration - Central differences                ld = (l3-l1)/(2*h);                % Load Library        import org.opensim.modeling.*;                %osimState = osimModel.initSystem();                                x2=-0.1;        u=0.20004;        l2=0.101;        sp2=0;                for k=1:nJoints            %osimModel.getCoordinateSet().get(k-1).setDefaultSpeedValue(xd(k));            %osimModel.getCoordinateSet().get(k-1).setDefaultValue(x2(k));                        osimModel.getCoordinateSet().get(k-1).setValue(osimState,x2(k));            osimModel.getCoordinateSet().get(k-1).setSpeedValue(osimState,xd(k));        end        osimModel.computeStateVariableDerivatives(osimState);        for m=1:nMuscles            myForce=osimModel.getMuscles().get(m-1);            muscleType = char(myForce.getConcreteClassName);            myMuscle=[];            eval(['myMuscle =' muscleType '.safeDownCast(myForce);']);            %display(char(myMuscle))                        %osimModel.getMuscles().get(m-1).setFiberLength(osimState,l2(m))            %osimModel.getMuscles().get(m-1).setActivation(osimState,u(m))                        myMuscle.setActivation(osimState, u(m) );            myMuscle.setFiberLength(osimState, l2(m) );            myMuscle.setSpeed(osimState, sp2 );                    end%         myMuscle.getFiberLength(osimState)%         %myMuscle.getFiberVelocity(osimState)%         %         %osimModel.equilibrateMuscles(osimState);         osimModel.computeStateVariableDerivatives(osimState);%         %         myMuscle.getFiberLength(osimState)%         myMuscle.getFiberVelocity(osimState)%         %         %         osimModel.computeStateVariableDerivatives(osimState);%         %         myMuscle.getFiberLength(osimState)%         myMuscle.getFiberVelocity(osimState)   %         %         %myMuscle.updModel(osimModel);%         %         myMuscle.getFiberLength(osimState)%         %         myMuscle.getFiberVelocity(osimState)%         %osimState = osimModel.initSystem();%         %osimModel.computeStateVariableDerivatives(osimState);%         %         osimModel.equilibrateMuscles(osimState);%         %         myMuscle.getFiberLength(osimState)%         myMuscle.getgetFiberVelocity(osimState)%         %osimModel.computeStateVariableDerivatives(osimState);%         %Get the joint accelerations constraints        for n=1:nJoints            qdotdot(n)=osimModel.getCoordinateSet().get(n-1).getAccelerationValue(osimState);            cJointAccel(n) = xdd(n) - qdotdot(n);        end                        for s=1:nMuscles            aaa=osimModel.getMuscles().get(s-1);            mact=osimModel.getMuscles().get(s-1).getActivation(osimState);            mforce=osimModel.getMuscles().get(s-1).getForce(osimState);            mlength=osimModel.getMuscles().get(s-1).getFiberLength(osimState);            mdot(s)=osimModel.getMuscles().get(s-1).getFiberVelocity(osimState);            cMuscleVel(s) = ld(s) - mdot(s);        end        aaaa=1;    endend