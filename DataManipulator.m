function [convergence, bestData] = DataManipulator(outputDataSet, realData, bestPrevData, bestCount)
%% Performs data manipulation to produce new variables for model consideration
%import current variable values
AbacusVariables = ImportScripts(pwd, 1);
ogden = AbacusVariables(13:size(AbacusVariables,1),:); 
ogden = ogden(1:size(ogden,1),2:size(ogden,2));
for i = 1:size(ogden,2)
    if strcmp(ogden{1,i},"")
        ogden = ogden(1,1:i-1); break;
    end
end
ogden = cell2mat(ogden);

% Check if it is initialisation run, ogden will have no values so set to
% initial value passed through as outputDataSet
if(isempty(ogden))
    ogden = [outputDataSet;outputDataSet];
end

%define number of models
numModels = 10;

%% Compare displacement data of real values to model outputs.
% order the possible variable combinations.
newData = ones(numModels - 2, 9);


%include top two models from previous iteration and define new dataset.
newOgdenVars = ones(numModels,9);
newOgdenVars(1:2,:) = ogden(1:2,:);
newOgdenVars(3:numModels, :) = newData;
bestData = ogden(1,:);
if(bestData == bestPrevData)  
    bestCount = bestCount + 1; 
else
    bestCount = 1;
end

%if the same data is the best for 10 consecutive runs.
if(bestCount == 10)
    convergence = true;
end

%% Write new values to the Abacus Variables file.
filename = strcat(pwd, '\AbacusVariables.xlsx');
loc = strcat('b20:J',int2str(20+numModels - 1));
writematrix(newOgdenVars,filename,'Sheet',1,'Range',loc);