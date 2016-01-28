function NPSOMonte(FcnPtr)
% INPUT: FcnPtr = Pointer to cost function - e.g., @Ackley, @Rastrigin, etc.
nMonte = 2;
GenLimit = 3;
MinCostPSO = zeros(nMonte, GenLimit+1);
MinCostNPSO = zeros(nMonte, GenLimit+1);
for i = 1 : nMonte
    disp(['Run # ', num2str(i), ' of ', num2str(nMonte)]);
    MinCostPSO(i, :) = PSO(FcnPtr, GenLimit, false); 
    MinCostNPSO(i, :) = NPSO(FcnPtr, GenLimit, false); 
end
MinCostPSO = mean(MinCostPSO, 1);
MinCostNPSO = mean(MinCostNPSO, 1);
figure
plot(0:GenLimit,MinCostPSO,'r', 0:GenLimit, MinCostNPSO,'b')
xlabel('Generation')
ylabel('Minimum Cost')
legend('PSO', 'NPSO')
return