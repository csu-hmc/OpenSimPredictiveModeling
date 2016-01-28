function das3sim(tstep)
% Runs a 4-second simulation and times it
% Plots the resulting angles and saves them in an Opensim motion file
% tstep is the timestep (default: 3ms)
%
% Dimitra Blana, June 2014

% Some model related variables
ndof = 11;
nmus = 138;
nstates = 2*ndof + 2*nmus;

% Initialize the model
das3mex();

% Set simulation parameters
t = 0;
tend = 4.0;
if (nargin < 1)
    tstep = .003;
end
nsteps = round((tend-t)/tstep);
		
% Reserve space to store results
tout = tstep*(0:nsteps)';
xout = zeros(nsteps+1, nstates);
tout(1) = t;

% Load passive equilbrium state x
load('equilibrium.mat');

% Initialize derivatives and muscle excitations
xdot = zeros(nstates,1);
step_u = zeros(nmus,1);

% Run simulation
xout(1,:) = x';
tic
for i=1:nsteps
    % Made-up muscle excitations (slowly increasing to 1)
    u = (i/nsteps)*ones(nmus,1);
    
    % Advance simulation by a step
    [x, xdot, step_u] = das3step(x, u, tstep, xdot, step_u);
    
    % Save state
    xout(i+1,:) = x';			
end
simtime = toc;
fprintf('CPU time per time step: %8.3f ms\n', 1000*simtime/nsteps);
fprintf('Simulation speed is %8.3f times faster than real time\n',tend/simtime);

% Plot on screen
figure(1);
plotangles(tout,xout);

% Export to mat file and to opensim motion file
save simulation tout xout
make_osimm('simulation', xout(:,1:ndof), tout);
end

function plotangles(t,x)
% Plots the eleven angles of DAS3 on four subplots

subplot(2,2,1)
plot(t,180/pi*x(:,1:3));
title('Sternoclavicular angles');
legend('Clavicle protraction/retraction','Elevation/depression','Axial rotation');
ylabel('angle (deg)');

subplot(2,2,2)
plot(t,180/pi*x(:,4:6));
title('Acromioclavicular angles');
legend('Scapula protraction/retraction','Lateral/medial rotation','Tilt');

subplot(2,2,3)
plot(t,180/pi*x(:,7:9));
title('Glenohumeral angles');
legend('Humerus plane of elevation','Elevation angle','Axial rotation');
ylabel('angle (deg)');
xlabel('time (s)');

subplot(2,2,4)
plot(t,180/pi*x(:,10:11));
title('Elbow/forearm angles');
legend('Elbow flexion/extension','Forearm pronation/supination');
xlabel('time (s)');

end

function make_osimm(filename,angles,time)
% Creates motion file for OpenSim
%
% Inputs:
% filename: the name of the motion file, without the extension
% angles: an 11xn or nx11 matrix of angles in radians, n the number of
% frames
% time (optional): a 1xn or nx1 vector of time values. If this is not
% provided, the timestep is assumed to be 0.01s.
%
% Corrected: angles now in radians instead of degrees
% Dimitra Blana, February 2012

[nrows,ncolumns]=size(angles);
if ncolumns~=11
    angles=angles';
    nrows = ncolumns;
end

if nargin <3
    time = 0.01:0.01:0.01*nrows;
end

if size(time,2)~=1, time = time'; end
if size(time,1)~=nrows
    errordlg('The time vector does not have the same length as the angle data.','Dimension error');
    return;
end
% data = [time angles*180/pi];  % in degrees for the Opensim model <--
data = [time angles];  

% create motion file
% the header of the motion file is:
%
% <motion name>
% nRows=x
% nColumns=y
% endheader
% time SC_y SC_z SC_x AC_y AC_z AC_x GH_y1 GH_z GH_y2 EL_x PS_y
%
fid = fopen([filename '.sto'],'wt');
fprintf(fid,'%s\n',filename);
fprintf(fid,'%s%i\n','nRows=',nrows);
fprintf(fid,'%s\n','nColumns=12');
fprintf(fid,'%s\n','endheader');
fprintf(fid,'%s\n','time  SC_y  SC_z SC_x  AC_y  AC_z  AC_x  GH_y  GH_z  GH_yy  EL_x  PS_y');
fprintf(fid,'%f  %f  %f  %f  %f  %f  %f  %f  %f  %f  %f  %f\n',data');
fclose(fid);
end