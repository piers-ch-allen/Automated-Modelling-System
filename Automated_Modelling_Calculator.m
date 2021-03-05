function Automated_Modelling_Calculator(numIterations, realData, N)
%%Function to provide the parent class of the Automated modelling process
% Itdoes inital data calculation and then provides a framework for
% rerunning the process until a convergence is met.
% Excel file called "AbacusVariables.xlsx" required.  It contains all
% variable definitions for the model parameters.  Check readme for how this
% is to be defined.

%% Initial Step
%Gather the dataFile at its initialisation point
addpath('Prony Code')
newData1 = load('-mat', 'dataStart.mat');
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end
clearvars i newData1 vars
bestCount = 1; genCount = 1; maxGens = 100; convergence = false;
numInGen = 25; minErr = 0; inErr = 10000; iterCount = 1;

%Create initial guesses
initGuessData = DataSetTool(errOut{1,N}, 25, 1);
%solve prony error for all initial values
dataSiz = size(initGuessData , 2);
for i = 1:numInGen
    initGuessData(i,dataSiz+1) = ViscoErrFuncIncDist(initGuessData(i,1:dataSiz), AllData);
end

%% Start loop for error cacluation and generation of new model possibilities
%% Start iteration loop for model convergence
%iterate through a number of model creations and data changes until a level
%of convergence is reached.
while (iterCount < numIterations && convergence == false)
    %calculate the error based on the current parameters
    %run the models:
    output = MainMultiple(iterCount);
    
    %perform model calculations on the curent dataSet
    [convergence, bestData] = DataManipulatorVisco(initData, AllData, bestData, bestCount);
    %increase iteration nunmber
    iterCount = iterCount + 1;
    output = MainMultiple(iterCount);
end



%perform data changes based on outputs and save over data file.
[convergence,bestData,bestCount] = DataManipulatorVisco(initData, AllData, ones(1,8), bestCount, genCount, maxGens);
%gather displacement data from the solved models
output = MainMultiple(1);
iterCount = 2;


%% Do something with the output results after iterations are completed 
% or a convergence is met
