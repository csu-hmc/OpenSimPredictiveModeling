function [MinCost] = PSOFully(ProblemFunction, DisplayFlag, phiMax, alpha, GenLimit)

% Fully informed particle swarm optimization for optimizing a general function.

% INPUTS: ProblemFunction = the handle of the function that returns the handles of the initialization and cost functions
%         DisplayFlag = whether or not to display information during iterations and plot results
%         phiMax = maximum value of each component of phi
%         alpha = constriction coefficient scale factor
%         GenLimit = generation limit

if ~exist('ProblemFunction', 'var') || isempty(ProblemFunction)
    ProblemFunction = @Ackley;
end
if ~exist('DisplayFlag', 'var') || isempty(DisplayFlag)
    DisplayFlag = true;
end
if ~exist('phiMax', 'var') || isempty(phiMax)
    phiMax = 2;
end
if ~exist('KFactor', 'var') || isempty(alpha)
    alpha = 0.9;
end
if ~exist('GenLimit', 'var') || isempty(GenLimit)
    GenLimit = 40;
end
OPTIONS.Maxgen = GenLimit;
OPTIONS.popsize = 40;
[OPTIONS, MinCost, AvgCost, Population] = Init(DisplayFlag, ProblemFunction, OPTIONS);
KFactor = alpha * 2 / (3 * phiMax - 2);

for k = 1 : OPTIONS.popsize
    Population(k).vel(1 : OPTIONS.numVar) = 0; % initialize velocities
end
BestInd = Population; % personal best of each particle
Distance = zeros(OPTIONS.popsize, OPTIONS.popsize); % distance between particles

% Begin the optimization loop
for GenIndex = 1 : OPTIONS.Maxgen
    % Update the personal best for each particle
    for i = 1 : OPTIONS.popsize
        if Population(i).cost < BestInd(i).cost
            BestInd(i) = Population(i);
        end
        % Update the distance array
        for j = 1 : OPTIONS.popsize 
            Distance(i, j) = norm(Population(i).chrom - Population(j).chrom);
        end
    end
    % Update the position and velocity of each particle
    WorstCost = max([Population.cost]);
    for i = 1 : OPTIONS.popsize
        MaxDistance = max(Distance(i, :));
        CostFactors = WorstCost - [Population.cost];
        DistanceFactors = MaxDistance - Distance(i, :);
        ScaleFactor = max(CostFactors) / max(DistanceFactors);
        Weights = CostFactors + ScaleFactor * DistanceFactors;
        phi = phiMax * rand(1, OPTIONS.popsize);
        x = reshape([BestInd.chrom], OPTIONS.popsize, OPTIONS.numVar);
        psubi = (Weights .* phi) * x / (Weights * phi');
        Population(i).vel = KFactor * (Population(i).vel + mean(phi) * (psubi - Population(i).chrom));
        Population(i).chrom = Population(i).chrom + Population(i).vel;
        Population(i).chrom = max( min(Population(i).chrom, OPTIONS.MaxDomain), OPTIONS.MinDomain);
    end 
    % Calculate cost
    Population = OPTIONS.CostFunction(Population);
    % Sort from best to worst
    Population = PopSort(Population);
    MinCost(GenIndex+1) = Population(1).cost;
    AvgCost(GenIndex+1) = mean([Population.cost]);
    if DisplayFlag
        disp(['Gen # ', num2str(GenIndex), ': min cost = ', num2str(MinCost(GenIndex+1)), ', ave cost = ', num2str(AvgCost(GenIndex+1))]);
    end
end
Conclude(DisplayFlag, OPTIONS, Population, MinCost, AvgCost);
return