function [gradObj,jacConst,gradModelResultsOut]=evalGradOpenSimModel(...
    modelResults,osimModel, controlsFuncHandle, timeSpan,...
    integratorName, integratorOptions,tp,P,constObjFuncName,h)
% evalGradOpenSimModel - evalue the gradient of the constraints and
%   objective function of an OpenSimModel.  This function is used in
%   optimizers.  Finite diference is used to calculate gradients.
%
%   An inital point is provided (modelResults) along with it's control
%   values (P).  Using finite difference with the a delta (h), gradients
%   of the constraints and the objective (constObjFuncName) are calculated.
%
%  For IPOPT, this function is wrapped in the anouynmous functions:
%       gradObjOpenSimModel and jacConstOpenSimModel
%
%   [gradObj,jacConst,gradModelResultsOut]=evalGradOpenSimModel(...
%       modelResults,osimModel, controlsFuncHandle, timeSpan,...
%       integratorName, integratorOptions,tp,P,constObjFuncName,h)
%
%  Inputs:
%       modelResults: Initial Point to start gradient from 
%           (see integrateOpenSimPlant for definition)
%       controlsFunctionHandle:  A handle to model specific function that
%           contains the calculations for the OpenSim Model controls.
%       timeSpan: The time span to integrate over (see
%           IntegrateOpenSimPlant).  [0 2] will integrate from 0 to 2
%           seconds.
%       integratorName: String containg the name of the integrator to be
%           used.  For example: 'ode15s'
%       integratorOptions: Structure containing integrator options.  See
%           ode15s for examples.  
%           integratorOptions = odeset('AbsTol', (1E-05), 'RelTol', (1E-03));
%       tp:  A vector of times at which the control values are provided.
%       P:  Control value Inputs into the model.  Matrix where:
%           Columns:  One column for each control (muscle) input in the
%               model.
%           Rows are the values of the control at the times in tp.  A cubic
%               spline is fit between the values for each control.
%       constObjFuncName: A handle to model specific function that
%           contains the calculations for the OpenSim Model constraint
%           values and objective.
%       h: delta value to add to controls in calculating finite differences
%
% Outputs:
%   gradObj: The gradient of the objective. This is a two dimensional
%       matrix: rows: time, columns: control
%   jacConst: The jacobian of the constraints.  This is a 3 dimensional
%       matrix: rows: time, columns: control, page: constraint 


% Import Java libraries
import org.opensim.modeling.*;


numTime=size(P,1); %P Each Row is Time
numControls=size(P,2); %P Each Column is Control

numGrad=0;

% osimModel.print('temp.osim');
% osimModel=[];
Pn=P;

for i=2:numTime
    
    for j=1:numControls
        %numGrad=numGrad+1;
        
        numGrad=((i-2)*numControls)+j;
        
        display([datestr(now,13) ' Gradient Step ' num2str(numGrad) ...
           ' of ' num2str((numTime-1)*numControls)])
        
       
       
        initialState=osimModel.initSystem();
        
        
        
        Pm=Pn;
        Pm(i,j)=P(i,j)+h;

        
        updatePresContSpline;

        
        ModelResultsP = runOpenSimModel(osimModel,initialState, ... 
             timeSpan, integratorName, ...
            integratorOptions, constObjFuncName);

        Pm=Pn;
        Pm(i,j)=Pm(i,j)-h;
        
        updatePresContSpline;
        
        ModelResultsM =  runOpenSimModel(osimModel,initialState, ... 
             timeSpan, integratorName, ...
            integratorOptions, constObjFuncName);

        
        %Foreward 1st Order
        %gradObj(i-1,j)=(dModelResults.objective - modelResults.objective)/h;
        
        
        %Central 2nd
        yp=ModelResultsP.objective;
        ym=ModelResultsM.objective;
        %y=modelResults.objective;
               
        %gradObj(i-1,j)=(dModelResults.objective - modelResults.objective)/h;
        gradObj(i-1,j)=(yp-ym)/(2*h);
        
        
        %Calculate the jacobian of the constraints
        %3dim matrix: row(i): time, column(j) control, page(k) constraint 
        for k=1:length(ModelResultsM.constraints)
%             jacConst(i-1,j,k) = (dModelResults.constraints(k) - ....
%                 modelResults.constraints(k))/h;

            yp=ModelResultsP.constraints(k);
            ym=ModelResultsM.constraints(k);
            
            jacConst(i-1,j,k) = (yp-ym)/(2*h);
            
        end  
        
        %If the gradient Model results are requested, put them in a 
        %structure to be output.
        if nargout>2
           gradModelResultsOut.dModelResults{1,numGrad} = ModelResultsP;
           gradModelResultsOut.dModelResults{2,numGrad} = ModelResultsM;
           
           gradModelResultsOut.h{numGrad} = h;
           gradModelResultsOut.P{numGrad} = Pn;
           gradModelResultsOut.Pn{numGrad} = P;
           %gradModelResultsOut.modelResults{numGrad} = modelResults;
        else
            gradModelResultsOut=[];
        end
        
    end
end

