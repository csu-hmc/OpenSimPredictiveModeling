% This file documents the use of the MEX function das3mex.
% The actual function is the file das3mex.mexw32

% The MEX function has several ways in which it can be used.

%==========================================================================
% Initialization
function das3mex()
% This needs to be done first.  During initialization, the model will be initialized from
% the model description files.

%==========================================================================
% Dynamics
function [f, dfdx, dfdxdot, dfdu, FGH, FSCAP, qTH] = das3mex(x, xdot, u, M, exF)
% This is to evaluate the model dynamics in the implicit form f(x, xdot, u) = 0.
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%	xdot	(298 x 1) 	State derivatives
%	u		(138 x 1) 	Muscle excitations

% Optional inputs
% 	M		(5 x 1)		Moments applied to the thorax-humerus YZY axes and the elbow flexion and supination axes
%   exF     (2 x 1)     Vertical force of amplitude exF(2) applied to the ulna at a distance of exF(1) (meters) from the elbow 
%						(to simulate a mobile arm support)

% Outputs
%	f		(298 x 1) 			Dynamics imbalance

% Optional outputs
%	dfdx	(298 x 298 sparse) 	Jacobian of f with respect to x
%	dfdxdot	(298 x 298 sparse) 	Jacobian of f with respect to xdot
%	dfdu	(298 x 138 sparse)	Jacobian of f with respect to u
%	FGH		(3 x 1)				3D GH contact force, acting on scapula, expressed in scapula reference frame
%   FSCAP 	(3 x 2)				3D Contact forces acting on TS and AI, expressed in thorax reference frame
%	qTH		(3 x 1)				angles between thorax and humerus (YZY sequence)

% Notes
% 	1. FGH is only correct when dynamics are satisfied, i.e. f is zero
%	2. The three Jacobians must always be requested together, or not at all.

%==========================================================================
% Extract mass parameters of the muscle elements
function MusMass = das3mex('MuscleMass')
%
% Outputs
%	MussMass	(138 x 1)	Mass for all muscle elements (in kg)

%==========================================================================
% Extract LCEopt parameters of the muscle elements
function LCEopt = das3mex('LCEopt')
%
% Outputs
%	Lceopt	(138 x 1)	Optimal fiber length parameters for all muscle elements (in meters)

%==========================================================================
% Extract SEEslack parameters of the muscle elements
function SEEslack = das3mex('SEEslack')
%
% Outputs
%	SEEslack (138 x 1)	Slack length of series elastic element for all muscle elements (in meters)

%==========================================================================
% Compute stick figure coordinates
function stick = das3mex('Stick', x)
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%
% Outputs
%   stick   (3 x 9)				3D coords of 9 points for stick figure: IJ, SC, AC, TS, AI, GH, UL, RD, HD (meters)

%==========================================================================
% Compute scapula contact
function F_contact = das3mex('Scapulacontact', x)
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%
% Outputs
%   F_contact (2 x 1)	Thorax surface equation solved for TS and AI

%==========================================================================
% Compute joint moments
function moments = das3mex('Jointmoments', x)
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%
% Outputs
%   moments (11 x 1)			Joint moments (N m)

%==========================================================================
% Compute muscle forces
function forces = das3mex('Muscleforces', x)
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%
% Outputs
%   forces	(138 x 1)			Muscle forces (N)

%==========================================================================
% Compute moment arms
function momentarms = das3mex('Momentarms', x)
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%
% Outputs
%   momentarms	(138 x 11 sparse)	Moment arms of 138 muscle elements at 11 joints (meters)

%==========================================================================
% Compute muscle-tendon lengths
function lengths = das3mex('Musclelengths', x)
%
% Inputs
%	x		(298 x 1) 	Model state, consists of 11 generalized coordinates (rad), 11 generalized velocities (rad/s),
%						138 CE lengths (relative to LCEopt), and 138 muscle active states (between 0 and 1).
%
% Outputs
%   lengths	(138 x 1)	Length of 138 muscle elements (meters)
%==========================================================================
% Find muscle name
function name = das3mex('Musclename', number)
%
% Inputs
%	number	(scalar) 	Number of a muscle element, must be in the range 1..138
%
% Outputs
%   name	(string)	Name of the muscle element, as define on the das3.bio file
%==========================================================================
% Find muscle name
function crossGH_flag = das3mex('crossGH', number)
%
% Inputs
%	number	(scalar) 	Number of a muscle element, must be in the range 1..138
%
% Outputs
%   crossGH_flag	(scalar)	1 if the muscle crosses GH, 0 if it doesn't