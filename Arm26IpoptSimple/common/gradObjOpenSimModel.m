function gradObj=gradObjOpenSimModel(Pv)
%gradObjOpenSimModel - function to be used in anonymous function for
%   optimizer.  Given control input matrix, the gradient of the objective for
%   the control inputs will be calculated
%
%gradObj=gradObjOpenSimModel(Pv)
%
%   Inputs:
%       Pv - A verctor of Control Values (this is reshaped into a matrix,
%           vector is used because that it was is provided by IPOPT).
%           Vector is formated such that:
%               [C1@t0 C2@t0.. C1@t1 C2@t1.... C1@t3 C2@t3....]
%
%   Global Variables:
%       m - this is a global structure with "constants" used in the
%           the analysis. m.constObjFuncName contains the name (string)
%           of the constraints function to be used. m.h determines change
%           in control value to be used (finite differences).
%           See objOpenSimModel for details.
%
%   Outputs:
%       gradObj - a vector with the gradient for each control vector.

global m

display([datestr(now,13) ' Calculating Objective Gradient'])



% Unflatten the controls vector to a matrix (columns are controls, rows are
% times for the spline

%Handle if initial activation is provided (from model defaults or if they
%are solved for
tp=m.tp;
if ~isempty(m.PInit)  %m.Pint has values that are provided
    Pm=reshape(Pv,[],length(m.tp)-1)';
    Pm=[m.PInit ;Pm];
else   %All values will be solved for.
    Pm=reshape(Pv,[],length(m.tp))';
end

%Evalute the model (Integrate and calculate obj/const)
if isequal(m.lastPm,Pm) && ~isempty(m.lastGradObj)
    modelResults = m.lastModelResults;
    gradObj=m.lastGradObj;
    jacConst=m.lastJacConst;
    gradModelResultsOut=[];
else
    %     if isequal(m.lastPm,Pm)
    %         modelResults = m.lastModelResults;
    %     else
    %         % Initalize the model
    %         initState=m.osimModel.initSystem();
    %         modelResults = runOpenSimModel(m.osimModel, initState,...
    %             m.timeSpan, m.integratorName, m.integratorOptions, ...
    %             m.constObjFuncName);
    %     end
    
    modelResults=[];
    %Using the above evaluation as a starting, get the gradient
    [gradObj,jacConst,gradModelResultsOut]=evalGradOpenSimModel(modelResults,m.osimModel, m.controlsFuncHandle,...
        m.timeSpan, m.integratorName, m.integratorOptions,m.tp,Pm,m.constObjFuncName,m.h);
    
    
    m.lastPm=Pm;
    m.lastModelResults=modelResults;
    m.lastGradObj=gradObj;
    m.lastJacConst=jacConst;
    m.gradModelResultsOut=gradModelResultsOut;
end



gradObj=reshape(gradObj',1,[]);  % Reshape so [c1t0....c6t0 c1t1....c6t1 c1t3....c6t3]

%Flatten 3dim matrix into 2 dim matrix where:
%      each row is for a constraint.  Columns match Pv
for i=1:size(jacConst,3)
    jacConstTemp(i,:)=reshape(jacConst(:,:,i)',[],1)';
end

%Make sparse (doubtful any 0s though)
jacConst=sparse(jacConstTemp);


m.runCnt=m.runCnt+1;

display([datestr(now,13) ' Objective Gradient Complete' '(' num2str(m.runCnt) ')'])

% Update bestYet
% if m.bestYetValue<obj;
%     m.bestYetValue=obj;
%     m.bestYetIndex=m.runCnt;
% end

%Update the log file to include this step
if ~isempty(m.saveLog)
    data.functionType=2;
    data.P=Pm;
    data.modelResults=modelResults;
    data.runCnt=m.runCnt;
    data.obj=[];
    data.gradObj=gradObj;
    data.constr=[];
    data.jacConst=jacConst;
    data.time=now;
    data.gradModelResultsOut=gradModelResultsOut;
    varName=['log' num2str(m.runCnt)];
    eval([varName '=data;']);
    save(m.saveLog,varName,'-append')
end



