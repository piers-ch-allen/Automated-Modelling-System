function Automated_Modelling_Calculator(numIterations, N)
%%Function to provide the parent class of the Automated modelling process
% Itdoes inital data calculation and then provides a framework for
% rerunning the process until a convergence is met.
% Excel file called "AbacusVariables.xlsx" required.  It contains all
% variable definitions for the model parameters.  Check readme for how this
% is to be defined.

%% Initial Step
%Gather the dataFile at its initialisation point
addpath('Prony Code')
load('dataStart.mat');
bestCount = 1; genCount = 1; maxGens = 100; convergence = false;
numInGen = 10; minErr = 0; inErr = 10000; iterCount = 1;
initError = PronySolverScriptChange(AllData, N);
[~, idx]=sort(initError{1,1}(:,(2*N) + 2));
initError{1,1} = initError{1,1}(idx,:);
disp('Finished gathering initial solutions from phase 1')

%initError = errOut;
%Create initial guesses
initGuessData = DataSetTool(initError{1,3}, 25, 1);
%solve prony error for all initial values
[its, dataSiz] = size(initGuessData);
for i = 1:its
    initGuessData(i,dataSiz+1) = ViscoErrFuncIncDist(initGuessData(i,1:dataSiz), AllData);
end

%remove incorrect solutions that have been included
temp = initError{1,1}; initError{1,1} = []; count = 1;
for i = 1:size(temp,1)
    if temp(i,N+2) < 100
        initError{1,1}(count,:) = temp(i,:);
        count = count + 1;
    end
end

%take 50 random choices to ensure diversity
order = linspace(1,size(initError{1,1},1) - 25,size(initError{1,1},1) - 25);
order = order(randperm(length(order)));
temp = initError{1,1}(26:size(initError{1,1},1),:);
random50 = temp(order(1,:),:);

%combine the data sets
modelSolutions = [initGuessData;random50(1:25,:)];
disp('Initial dataset produced from guess including random and defined permutations.')

%perform an initial genetic run of small number of generations to imrove
%starting results
modelSolutions = GeneticIterator(modelSolutions, N, 50, 5000, minErr, AllData);

%retrieve unique solutions 
top = modelSolutions(1,:);
modelSolutions = uniquetol(modelSolutions(:,1:(2*N) + 1),0.05,'ByRows',true);
for j = 1:size(modelSolutions,1)
    modelSolutions(j,(2*N) + 2) = ViscoErrFuncIncDist(modelSolutions(j,1:(2*N) + 1), AllData);
end
[~, idx]=sort(modelSolutions(:,(2*N) + 2));
modelSolutions = [top;modelSolutions(idx,:)];

top10 = modelSolutions(1:10,1:(2*N) + 1);
%save inital material parameter data
viscoVariableWriteToFile(top10, numInGen, N);

%% Start loop for error cacluation and generation of new model possibilities
%% Start iteration loop for model convergence
%iterate through a number of model creations and data changes until a level
%of convergence is reached.
%Run the initial models based on first set of inputs.
output = MainMultiple(iterCount, N);
disp('First set of model runs completed, automations of run starting now.')

% while (iterCount < numIterations && convergence == false)
%     %calculate the error on the models for eacg set of associated parameters
%     for i = 1:numInGen
%         visOut{i,1} = output{1,1,1,i};
%         %error = blah blah blah
%         %create a new dataset populated by variations of the optimal
%         %solutions proporionate to there ranking.
%     end
%         
%     %perform model calculations on the curent dataSet
%     [convergence, bestData] = DataManipulatorVisco(initData, AllData, bestData, bestCount);
%     %increase iteration nunmber
%     iterCount = iterCount + 1;
%     output = MainMultiple(iterCount);
% end
% 
% 
% 
% %perform data changes based on outputs and save over data file.
% [convergence,bestData,bestCount] = DataManipulatorVisco(initData, AllData, ones(1,8), bestCount, genCount, maxGens);
% %gather displacement data from the solved models
% output = MainMultiple(1);
% iterCount = 2;


%% Do something with the output results after iterations are completed 
% or a convergence is met
