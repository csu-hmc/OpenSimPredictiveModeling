function constr=constOpenSimModelFMINCON(Pv)

%constOpenSimMod - function to be used in anonymous function for
%   optimizer.  Given control input matrix, the objective will be returned.
%
%constr=constOpenSimModel(Pv)
%
%   Inputs:
%       Pv - A vector of Control Values (this is reshaped into a matrix,
%           vector is used because that it was is provided by IPOPT.
%           Vector is formated such that:
%               [C1@t0 C2@t0.. C1@t1 C2@t1.... C1@t3 C2@t3....]
%
%       Global Variables
%       m - this is a global structure with "constants" used in the
%           the analysis. m.constObjFuncName contains the name (string)
%           of the constraints function to be used.
%           See objOpenSimModel for details.
%
%
%   Outputs:
%       constr - vector with constraint values returned.


global m


display([datestr(now,13) ' Calculating Constarints.'])

m.osimModel.initSystem();

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


if isequal(m.lastPm,Pm)
    modelResults = m.lastModelResults;
else
    modelResults = runOpenSimModel(m.osimModel, m.controlsFuncHandle,...
        m.timeSpan, m.integratorName, m.integratorOptions,m.tp,Pm, ...
        m.constObjFuncName);
    m.lastPm=Pm;
    m.lastModelResults=modelResults;
    m.lastGradObj=[];
    m.lastJacConst=[];
end


constr=modelResults.constraints;

obj=modelResults.objective;

m.runCnt=m.runCnt+1;

if m.bestYetValue<obj;
    m.bestYetValue=obj;
    m.bestYetIndex=m.runCnt;
end

display([datestr(now,13) ' Constarints: ' sprintf('%f ',constr) '(' num2str(m.runCnt) ')']);

%Update the logfile
if ~isempty(m.saveLog)
    data.functionType=3;
    data.P=Pm;
    data.modelResults=modelResults;
    data.runCnt=m.runCnt;
    data.obj=[];
    data.gradObj=[];
    data.constr=constr;
    data.jacConst=[];
    data.time=now;
    varName=['log' num2str(m.runCnt)];
    eval([varName '=data;']);
    save(m.saveLog,varName,'-append')
end

constr=[-constr 0];