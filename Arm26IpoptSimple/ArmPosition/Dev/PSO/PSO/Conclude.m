function Conclude(DisplayFlag, OPTIONS, Population, MinCost, AvgCost)
% Output results of evolutionary optimization algorithm.
if DisplayFlag
    % Count the number of unique individuals
    NumUnique = 0;
    DupIndices = [];
    for i = 1 : OPTIONS.popsize
        if find(DupIndices == i), continue, end
        Chrom1 = Population(i).chrom;
        UniqueFlag = 1;
        for j = i+1 : OPTIONS.popsize
            Chrom2 = Population(j).chrom;
            if isequal(Chrom1, Chrom2)
                DupIndices = [DupIndices j]; %#ok<AGROW>
                UniqueFlag = 0;
                break
            end
        end
        NumUnique = NumUnique + UniqueFlag;
    end
    disp([num2str(NumUnique), ' unique individuals in final population.']);
    % Display the best solution
    Chrom = Population(1).chrom;
    disp(['Best chromosome = ', num2str(Chrom)]); 
    % Plot the minimum and average cost.
    figure, hold on
    GenCount = length(MinCost);
    plot((0:GenCount-1), AvgCost, 'r--', (0:GenCount-1), MinCost, 'b-')
    legend('Average Cost', 'Minimum Cost')
    xlabel('Generation')
    ylabel('Cost')
end
return