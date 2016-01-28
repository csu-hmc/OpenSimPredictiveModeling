function [OPTIONS, MinCost, AvgCost, Population] = Init(DisplayFlag, ProblemFunction, OPTIONS)
% Initialize population-based optimization software.
RandSeed = fix(sum(100*clock));
rng(RandSeed); % initialize the random number generator
% Get the addresses of the initialization and cost functions
[OPTIONS.InitFunction, OPTIONS.CostFunction] = ProblemFunction();
% Initialize the population.
[Population, OPTIONS] = OPTIONS.InitFunction(OPTIONS);
% Compute cost of each individual  
Population = OPTIONS.CostFunction(Population, OPTIONS);
% Sort the population from most fit to least fit
Population = PopSort(Population);
MinCost = zeros(OPTIONS.Maxgen+1, 1);
AvgCost =  zeros(OPTIONS.Maxgen+1, 1);
MinCost(1) = Population(1).cost;
AvgCost(1) = mean([Population.cost]);
if DisplayFlag
    disp(['Gen # 0: min cost = ', num2str(MinCost(1)), ', ave cost = ', num2str(AvgCost(1))]);
end
return