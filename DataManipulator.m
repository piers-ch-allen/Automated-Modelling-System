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



%% Write new values to the Abacus Variables file.
filename = strcat(pwd, '\AbacusVariables.xlsx');
numModels = size(newOgdenVars,1);
loc = strcat('b20:J',int2str(20+numModels - 1));
writematrix(newOgdenVars,filename,'Sheet',1,'Range',loc);