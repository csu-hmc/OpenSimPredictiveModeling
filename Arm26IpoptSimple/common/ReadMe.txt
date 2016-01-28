
-----------------------------------------

The following functions are used as the "main" files for running models

arm26_IPOPT - Run Arm26 Optmization Problem with IPOPT.

arm26_SerialSimulation - Script to test and troublshoot functions 
   (objective, gradinet  objective, constraint, and constraint jacobian) 
   used during IPOPT in serial fashion. 

arm26_ForwardRun - Script to run the arm26 model (with default control 
    parameters).  This model is used to check the MATLAB integrator against
    the results from the OpenSim forward tool.


-----------------------------------------

The following functions are specific to the arm26 model

arm26CalcObjConstraints - function calculate the constraint and objective
   values of the arm26 model.  This function is specific to the arm26
   model. It is specific to the arm26 model.


-----------------------------------------

The following functions are needed by IPOPT

objOpenSimModel - function to be used in anonymous function for
    optimizer.  Given control input matrix, the objective will be returned.

gradObjOpenSimModel - function to be used in anonymous function for
   optimizer.  Given control input matrix, the gradient of the objective 
    for the control inputs will be calculated.

constOpenSimMod - function to be used in anonymous function for
   optimizer.  Given control input matrix, the objective will be returned.

jacConstOpenSimModel - function to be used in anonymous function for
   optimizer.  Given control input matrix, the jacobian of the constraints 
   will be calculated.


-----------------------------------------
OpenSim Integration and evaluation functions (not model specific)

integrateOpenSimPlant - Integrate a plant model that was created from an 
    OpenSim model

evaluateOpenSimModel- evaluate (perform integration and calculate 
  constarinats and objective) of an OpenSim model.  
  
plantFunctionOpenSim - wraps an OpenSimModel and an OpenSimState into a 
   function which can be passed as a input to a Matlab integrator, such as
   ode45, or an optimization routine, such as fmin.

evalGradOpenSimModel - evalue the gradient of the constraints and
   objective function of an OpenSimModel. 

plantControlsFunctionOpenSim - This function allows for the generation of
    varying control values during each integrator step.  This is not
    currently being used.  This is used when the control values are updated
    by MATLAB at each integrator step.  Instead, a prescribed controller 
    is created and the spline are performed by OpenSim.

addPrescribed Controller - Create a prescribed controller that uses a set
    of SimmSplines to produce muscle activations.    The controller is
    created one time, but it's values are updated before each integration
    run (once per full integration).

updatePresContSpline - update the muscle control values before each
    integartion run.
   
   


To do:

Add warm start capability (read BestYet from logFile)
Try Using forward Opensim tool instead of MATLAB inetgartor



