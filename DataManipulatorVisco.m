function [convergence, bestData, bestCount] = DataManipulatorVisco(outputDataSet, realData, bestPrevData, bestCount,genCount, maxGens)
%% Performs data manipulation to produce new variables for model consideration
%perform the prony manipulation
numInGen = 24;
dataManip = ViscoPronyManip(outputDataSet(:,1:5), numInGen);
dataSiz = size(dataManip , 2);
for i = 1:numInGen
    dataManip(i,dataSiz+1) = ViscoErrFuncIncDist(dataManip(i,1:dataSiz), realData);
end
[~, idx]=sort(dataManip(:,8));
dataManip = dataManip(idx,:);
if(dataManip(1,8) == bestPrevData(1,8))
   bestCount = bestCount + 1;
   bestData = dataManip(1,1:7);
end

if(bestCount == 10)
   convergence = true;
else
   convergence = false;
end

%% Write new values to the Abacus Variables file.
viscoVariableWriteToFile(dataManip, numInGen, N);