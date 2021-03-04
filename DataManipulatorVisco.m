function [convergence, bestData, bestCount] = DataManipulatorVisco(outputDataSet, realData, bestPrevData, bestCount,genCount, maxGens)
%% Performs data manipulation to produce new variables for model consideration
%perform the prony manipulation
numInGen = 24;
dataManip = ViscoPronyManip(outputDataSet(:,1:7), numInGen);
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
Gvalues = zeros(numInGen * 3,1); Tvalues = zeros(numInGen * 3,1); count = 1;
for i = 1:numInGen
    Gvalues(count,1) = dataManip(i,2); Tvalues(count,1) = dataManip(i,5); count = count + 1;
    Gvalues(count,1) = dataManip(i,3); Tvalues(count,1) = dataManip(i,6); count = count + 1;
    Gvalues(count,1) = dataManip(i,4); Tvalues(count,1) = dataManip(i,7); count = count + 1;
end

filename = strcat(pwd, '\Prony Code\AbacusVariablesVisco.xlsx');
loc = strcat('B1:B',int2str(numInGen * 3));
writematrix(Gvalues,filename,'Sheet',1,'Range',loc);
loc = strcat('D1:D',int2str(numInGen * 3));
writematrix(Tvalues,filename,'Sheet',1,'Range',loc);