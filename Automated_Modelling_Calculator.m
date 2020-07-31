function Automated_Modelling_Calculator(numIterations, realData)
%%Function to provide the parent class of the Automated modelling process
% Itdoes inital data calculation and then provides a framework for
% rerunning the process until a convergence is met.

%% Initial Step
%Gather the dataFile at its initialisation point
output = MainMultiple(1);
iterCount = 2;

%perform data changes based on outputs and sve over data file.
convergence = dataManip(output);

%% Start iteration loop for model convergence
%iterate through a number of model creations and data changes until a level
%of convergence is reached.
while (iterCount < numIterations && convergence == false)
    %perform model calculations on the curent dataSet
    output = MainMultiple(iterCount);
    
    %perform data manipulation on the dataset
    convergence = dataManip(output);
    
    %increase iteration nunmber
    iterCount = iterCount + 1;
end

