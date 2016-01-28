function [InitFunction, CostFunction] = ImpedanceControl
InitFunction = @Init;
CostFunction = @Cost;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population, OPTIONS] = Init(OPTIONS)
% Initialize the population
%OPTIONS.MinDomain = [0, 0.0, 0.0,   0];
%OPTIONS.MaxDomain = [5, 0.2, 2.0, 100];
OPTIONS.MinDomain = [0, 0.0, 0.0,   0, -0.2, -100];
OPTIONS.MaxDomain = [2, 0.2, 2.0, 100,  0.2,  100];
OPTIONS.numVar = length(OPTIONS.MinDomain); % number of dimensions in cost function (k1, k2, b, theta_e, k3, theta_a, k4)
Population = struct('chrom', cell([1 OPTIONS.popsize]), 'cost', cell([1 OPTIONS.popsize]));
for popindex = 1 : OPTIONS.popsize
    chrom = OPTIONS.MinDomain + (OPTIONS.MaxDomain - OPTIONS.MinDomain) .* rand(1,OPTIONS.numVar);
    Population(popindex).chrom = chrom;
end
% Population(1).chrom = [3.780, 73e-3, 25e-3, 12, 0, 0]; % Values from Sup & Goldfarb paper
% Population(2).chrom = [0.000,  9e-6, 30e-3, 37, 0, 0];
% Population(3).chrom = [0.000,  9e-3, 16e-3, 52, 0, 0];
% Population(4).chrom = [0.093,  2e-6, 13e-3, 44, 0, 0];
% Population(5).chrom = [0  0.000198915     0.965998      48.5143    0.0438009     -3.06962]; % Best values found with previous PSO run
[OPTIONS.ThetaKnee, OPTIONS.ThetaKneeDot, OPTIONS.ThetaAnkle, OPTIONS.MKnee] = invdyn2d(false); % Read the human reference data but don't plot results
N = 132; % first stride
N = floor(0.4 * N); % first mode per Sup & Goldfarb
OPTIONS.ThetaKnee = OPTIONS.ThetaKnee(1:N);
OPTIONS.ThetaKneeDot = OPTIONS.ThetaKneeDot(1:N);
OPTIONS.ThetaAnkle = OPTIONS.ThetaAnkle(1:N);
OPTIONS.MKnee = OPTIONS.MKnee(1:N);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Cost(Population, OPTIONS)
% Compute the cost of each member in Population
theta = OPTIONS.ThetaKnee;
thetadot = OPTIONS.ThetaKneeDot;
ankle = OPTIONS.ThetaAnkle;
ReferenceMoment = OPTIONS.MKnee;
N = length(ReferenceMoment);
for popindex = 1 : length(Population)
    k1 = Population(popindex).chrom(1);
    k2 = Population(popindex).chrom(2);
    b = Population(popindex).chrom(3);
    theta_e = Population(popindex).chrom(4);
    k3 = Population(popindex).chrom(5);
    theta_a = Population(popindex).chrom(6);
    Moment = k1 * (theta - theta_e) + k2 * (theta - theta_e).^3 + b * thetadot + k3 * (ankle - theta_a);
    Population(popindex).cost = sqrt(sum((Moment-ReferenceMoment).^2) / N);
end
return