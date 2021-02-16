function Automated_Modelling_Calculator(numIterations, realData)
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

%perform data changes based on outputs and save over data file.
[convergence,bestData] = DataManipulatorVisco(initData, AllData, 1, 1);
%gather displacement data from the solved models
output = MainMultiple(iteration);
iterCount = 2;
bestCount = 2;

%% Start iteration loop for model convergence
%iterate through a number of model creations and data changes until a level
%of convergence is reached.
while (iterCount < numIterations && convergence == false)
    %perform model calculations on the curent dataSet
    [convergence, bestData] = DataManipulatorVisco(initData, AllData, bestData, bestCount);
    %increase iteration nunmber
    iterCount = iterCount + 1;
    output = MainMultiple(iteration);
end

%% Do something with the output results after iterations are completed 
% or a convergence is met
