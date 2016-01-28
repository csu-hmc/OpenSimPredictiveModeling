function [MinCost] = NPSO(ProblemFunction, GenLimit, DisplayFlag, phi1max, phi2max, phi3max, phi4max, phi5max, phi6max, alpha)

% Negative reinforcment PSO for optimizing a general function.

% INPUTS: ProblemFunction = the handle of the function that returns the handles of the initialization and cost functions
%         DisplayFlag = whether or not to display information during iterations and plot results
%         phi1max = cognitive constant
%         phi2max = social constant for neighborhood interaction
%         phi3max = social constant for global interaction
%         phi4max = negative reinforcement cognitive constant
%         phi5max = negative reinforcement social constant for neighborhood interaction
%         phi6max = negative reinforcement social constant for global interaction
%         alpha = constriction coefficient scale factor
%         GenLimit = generation limit

if ~exist('ProblemFunction', 'var') || isempty(ProblemFunction)
    ProblemFunction = @Ackley;
end
if ~exist('DisplayFlag', 'var')
    DisplayFlag = true;
end
if ~exist('phi1max', 'var')
    phi1max = 2;
end
if ~exist('phi2max', 'var')
    phi2max = 2;
end
if ~exist('phi3max', 'var')
    phi3max = 2;
end
if ~exist('phi4max', 'var')
    phi4max = 0.1;
end
if ~exist('phi5max', 'var')
    phi5max = 0;
end
if ~exist('phi6max', 'var')
    phi6max = 0;
end
if ~exist('alpha', 'var')
    alpha = 0.9;
end
KFactor = alpha * 2 / (phi1max + phi2max + phi3max - phi4max - phi5max - phi6max - 2);
if ~exist('GenLimit', 'var')
    GenLimit = 100;
end
OPTIONS.Maxgen = GenLimit;
OPTIONS.popsize = 20;
[OPTIONS, MinCost, AvgCost, Population] = Init(DisplayFlag, ProblemFunction, OPTIONS);
OPTIONS.neighbors = 5; % size of particle swarm neighborhood

for k = 1 : OPTIONS.popsize
    Population(k).vel(1 : OPTIONS.numVar) = 0; % initialize velocities
end
pbest = Population; % personal best of each particle
pworst = Population; % personal worst of each particle
nbest = Population; % neighborhood best of each particle
nworst = Population; % neighborhood worst of each particle
gbest = Population(1); % global best
gworst = Population(end); % global worst

% Begin the optimization loop
for GenIndex = 1 : OPTIONS.Maxgen
    % Update the global best and worst if needed
    if Population(1).cost < gbest.cost
        gbest = Population(1);
    elseif Population(end).cost > gworst.cost
        gworst = Population(end);
    end
    % Update the personal best and neighborhood best for each particle
    for i = 1 : OPTIONS.popsize 
        % Update each personal best and worst as needed
        if Population(i).cost < pbest(i).cost
            pbest(i) = Population(i);
        elseif Population(i).cost > pworst(i).cost
            pworst(i) = Population(i);
        end
        % Update each neighborhood best and worst as needed
        Distance = zeros(OPTIONS.popsize, 1);
        for j = 1 : OPTIONS.popsize 
            Distance(j) = norm(Population(i).chrom - Population(j).chrom);
        end
        [~, indices] = sort(Distance);
        nbest(i).cost = inf;
        nworst(i).cost = -inf;
        for j = 2 : OPTIONS.neighbors
            nindex = indices(j);
            if Population(nindex).cost < nbest(i).cost
                nbest(i) = Population(nindex);
            elseif Population(nindex).cost > nworst(i).cost
                nworst(i) = Population(nindex);
            end
        end
    end
    % Update the position and velocity of each particle (except the elites)
    for i = 1 : OPTIONS.popsize
        r = rand(6, OPTIONS.numVar);
        x = Population(i).chrom;
        deltaVpersonal = phi1max * r(1,:) .* (pbest(i).chrom - x);
        deltaVneighborhood = phi2max * r(2,:) .* (nbest(i).chrom - x);
        deltaVglobal = phi3max * r(3,:) .* (gbest.chrom - x);
        deltaVpworst = -phi4max * r(4,:) .* (pworst(i).chrom - x);
        deltaVnworst = -phi5max * r(5,:) .* (nworst(i).chrom - x);
        deltaVgworst = -phi6max * r(6,:) .* (gworst.chrom - x);
        Population(i).vel = KFactor * (Population(i).vel + deltaVpersonal + deltaVneighborhood + ...
             + deltaVglobal + deltaVpworst + deltaVnworst + deltaVgworst);
        Population(i).chrom = x + Population(i).vel;
        Population(i).chrom = max( min(Population(i).chrom, OPTIONS.MaxDomain), OPTIONS.MinDomain);
    end 
    % Calculate cost
    Population = OPTIONS.CostFunction(Population, OPTIONS);
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