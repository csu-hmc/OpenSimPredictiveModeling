function [ThetaKnee, ThetaKneeDot, ThetaAnkle, MKnee] = invdyn2d(PlotFlag)

if ~exist('PlotFlag', 'var')
    PlotFlag = true;
end

% 2D inverse dynamic analysis example from lecture Oct 6, 2014

%=================================================
% load and store marker data and force plate data
%=================================================
d = load('Subject005Trial08.txt');
h = 0.01;				% time interval between frames (samples)
f = 1800:2200;			% frames we will look at
times = h*(f - f(1));	% time values

% markers
HipX   = d(f,26+23);	% RGTRO.PosX
HipY   = d(f,26+24);	% RGTRO.PosY, etc.
KneeX  = d(f,2*26+6);
KneeY  = d(f,2*26+7);
AnkleX = d(f,2*26+15);
AnkleY = d(f,2*26+16);
ToeX   = d(f,2*26+21);
ToeY   = d(f,2*26+22);

% extract force plate data from file
COPx = d(f,6*26+14);
Fx   = d(f,6*26+17);
Fy   = d(f,6*26+18);

% subject information
bodymass = 81.4;		% kg

%===============================================
% solve inverse dynamics for foot segment
%===============================================
% compute foot angle and angular acceleration
theta_foot = atan2(AnkleY-ToeY,AnkleX-ToeX);
alpha_foot = [0; diff(diff(theta_foot))/h^2; 0];

% compute position/acceleration of foot center of mass
Xcmfoot = 0.5*AnkleX + 0.5*ToeX;
Ycmfoot = 0.5*AnkleY + 0.5*ToeY;
Axfoot = [0; diff(diff(Xcmfoot))/h^2; 0];
Ayfoot = [0; diff(diff(Ycmfoot))/h^2; 0];

% compute mass properties of foot
mfoot = 0.0145 * bodymass;  	% using Winter's anthropometry table
Lfoot = mean(sqrt((AnkleY-ToeY).^2+(AnkleX-ToeX).^2));
Ifoot = mfoot*(0.475*Lfoot)^2;

% compute vectors from CM foot to prox and dist load point
Px = AnkleX - Xcmfoot;
Py = AnkleY - Ycmfoot;
Dx = COPx - Xcmfoot;
Dy =   0  - Ycmfoot;

% compute force and moment at the ankle (acting on foot)
FxAnkle = mfoot*Axfoot - Fx;
FyAnkle = mfoot*Ayfoot - Fy + mfoot*9.81;
MAnkle = Ifoot*alpha_foot - ...
	   (Dx.*Fy - Dy.*Fx) - (Px.*FyAnkle - Py.*FxAnkle);

%===============================================
% solve inverse dynamics for shank segment
%===============================================
% compute shank angular acceleration
theta_shank = atan2(KneeY-AnkleY,KneeX-AnkleX);
alpha_shank = [0; diff(diff(theta_shank))/h^2; 0];

% compute position/acceleration of shank CM
Xcmshank = 0.567*KneeX + 0.433*AnkleX;
Ycmshank = 0.567*KneeY + 0.433*AnkleY;
Axshank = [0; diff(diff(Xcmshank))/h^2; 0];
Ayshank = [0; diff(diff(Ycmshank))/h^2; 0];

% compute mass properties of shank
mshank = 0.0465 * bodymass;  		% using Winter's anthropometry data
Lshank = mean(sqrt((AnkleY-KneeY).^2+(AnkleX-KneeX).^2));
Ishank = mshank*(0.302*Lshank)^2;

% loads applied from the foot
MAnkle = -MAnkle;
FxAnkle = -FxAnkle;
FyAnkle = -FyAnkle;

% vectors from CM shank to prox and dist load point
Px = KneeX - Xcmshank;
Py = KneeY - Ycmshank;
Dx = AnkleX - Xcmshank;
Dy = AnkleY - Ycmshank;

% compute force and moment at the knee (acting on shank)
FxKnee = mshank*Axshank - FxAnkle;
FyKnee = mshank*Ayshank - FyAnkle + mshank*9.81;
MKnee = Ishank*alpha_shank - MAnkle - ...
(Dx.*FyAnkle - Dy.*FxAnkle) - (Px.*FyKnee - Py.*FxKnee);

%=================================================
% compute joint angles, plot all results
%=================================================
theta_thigh = atan2(HipY-KneeY, HipX-KneeX);
ThetaAnkle = (theta_foot - theta_shank)*180/pi;		% convert to degrees
ThetaKnee  = -(theta_shank - theta_thigh)*180/pi;
ThetaKneeDot = diff(ThetaKnee) ./ diff(times');
ThetaKneeDot(end+1) = ThetaKneeDot(end);
ThetaKneeDot = ThetaKneeDot * pi / 180; % rad/s

if PlotFlag
    close all
    subplot(2,2,1);plot(times,ThetaKnee);title('knee flexion');ylabel('angle (deg)');grid
    subplot(2,2,2);plot(times,ThetaAnkle);title('ankle dorsiflexion');grid
    subplot(2,2,3);plot(times,-MKnee);ylabel('moment (Nm)');grid
    subplot(2,2,4);plot(times,-MAnkle);grid
    figure, plot(times, ThetaKneeDot), grid
    xlabel('time (s)'), ylabel('knee angle velocity (Nm)')
end

end
