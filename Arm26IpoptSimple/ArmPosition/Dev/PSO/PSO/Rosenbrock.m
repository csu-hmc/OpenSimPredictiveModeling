function [InitFunction, CostFunction] = Rosenbrock
InitFunction = @Init;
CostFunction = @Cost;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population, OPTIONS] = Init(OPTIONS)
% Initialize population
OPTIONS.numVar = 10;
OPTIONS.MinDomain = -2.048 * ones(1, OPTIONS.numVar);
OPTIONS.MaxDomain = +2.048 * ones(1, OPTIONS.numVar);
Population = struct('chrom', cell([1 OPTIONS.popsize]), 'cost', cell([1 OPTIONS.popsize]));
for popindex = 1 : OPTIONS.popsize
    chrom = OPTIONS.MinDomain + (OPTIONS.MaxDomain - OPTIONS.MinDomain) .* rand(1,OPTIONS.numVar);
    Population(popindex).chrom = chrom;
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Population] = Cost(Population, OPTIONS)
% Compute the cost of each member in Population
p = length(Population(1).chrom);
for popindex = 1 : length(Population)
    Population(popindex).cost = 0;
    for i = 1 : p-1
        x1 = Population(popindex).chrom(i);
        x2 = Population(popindex).chrom(i+1);
        temp = 100 * (x2 - x1^2)^2 + (x1 - 1)^2;
        Population(popindex).cost = Population(popindex).cost + temp;
    end
end
return