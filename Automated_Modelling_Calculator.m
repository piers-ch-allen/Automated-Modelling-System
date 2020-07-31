function Automated_Modelling_Calculator(numIterations, realData, initialSolution)
%%Function to provide the parent class of the Automated modelling process
% Itdoes inital data calculation and then provides a framework for
% rerunning the process until a convergence is met.
% Excel file called "AbacusVariables.xlsx" required.  It contains all
% variable definitions for the model parameters.  Check readme for how this
% is to be defined.

%% Initial Step
%Gather the dataFile at its initialisation point
[~,~] = DataManipulator(initialSolution, realData, 1, 1);
output = MainMultiple(1);
iterCount = 2;
bestData = 1;

%perform data changes based on outputs and sve over data file.
bestCount = 0;
[convergence, bestData] = DataManipulator(output, realData, bestData, bestCount);

%% Start iteration loop for model convergence
%iterate through a number of model creations and data changes until a level
%of convergence is reached.
while (iterCount < numIterations && convergence == false)
    %perform model calculations on the curent dataSet
    output = MainMultiple(iterCount);
    
    %perform data manipulation on the dataset
    [convergence, bestData] = DataManipulator(output, realData, bestData, bestCount);
    
    %increase iteration nunmber
    iterCount = iterCount + 1;
end

%% Do something with the output results after iterations are completed 
% or a convergence is met
