function [output, errorTracker] = Automated_Modelling_Calculator(numIterations, N)
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
bestCount = 1; convergence = false;
numInGen = 20; minErr = 0; inErr = 10000; iterCount = 1;
initError = PronySolverScriptChange(AllData, N);
[~, idx]=sort(initError{1,1}(:,(2*N) + 2));
initError{1,1} = initError{1,1}(idx,:);

%initError = errOut;
%Create initial guesses
initGuessData = DataSetTool(initError{1,3}, 50, 1);
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
initError{1,1} = unique(round(initError{1,1},4), 'rows');
order = linspace(1,size(initError{1,1},1) - 25,size(initError{1,1},1) - 25);
order = order(randperm(length(order)));
temp = initError{1,1}(26:size(initError{1,1},1),:);
random50 = temp(order(1,:),:);

%combine the data sets
if size(random50, 2) >= 25
    modelSolutions = [initGuessData;random50(1:25,:)];
else
    modelSolutions = [initGuessData;random50];
end

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

topVals = modelSolutions(1:20,1:(2*N) + 1);
%save inital material parameter data
viscoVariableWriteToFile(topVals, numInGen, N);

%% Start loop for error cacluation and generation of new model possibilities
%% Start iteration loop for model convergence
%iterate through a number of model creations and data changes until a level
%of convergence is reached.
%Run the initial models based on first set of inputs.
output = MainMultiple(iterCount, N);
errorTracker = zeros(numIterations, 3);
solutionTracker = cell(numIterations,3);
numInGen = 50;
while (iterCount <= numIterations && convergence == false)
    %calculate the error on the models for eacg set of associated parameters
    outputData = cell(3,size(output,4));
    for i = 1:size(output, 4)
        try
            data = output{:,:,1,i};
            x = data(:,1)'; displace = data(:,2)'; force = data(:,3)';
            %find location of end of step 1 and its force to define ramp data
            idx = find(x==1.05,1,'first');
            a = 1255000;
            rampData = [a*(x(1,3:idx)-0.05); 10000*displace(1,3:idx)];

            %find min and max of cyclic data to normalise values
            siz = size(data,1);
            cycData = [a*(x(1,idx+1:siz)-0.05);10000*displace(1,idx+1:siz)];
            sizC = size(cycData,2);
            %min displacement
            minD = min(cycData(2,:));
            cycData(2,:) = cycData(2,:) - minD;

            %define loading profile
            t = linspace(1,2,sizC); 
            funcs=1.225+0.493*sin(6.28*t);
            cycData(1,:) = funcs;
            Maxidx = find(funcs(1,:)==max(funcs(1,:)));
            Minidx = find(funcs(1,:)==min(funcs(1,:)));
            cycDataUpper = [cycData(:,Minidx+1:sizC),cycData(:,1:Maxidx)];
            cycDataLower = cycData(:,Maxidx+1:Minidx);
            
            %save data to be evaluated;
            outputData{1,i} = rampData;
            outputData{2,i} = cycDataLower;
            outputData{3,i} = cycDataUpper;
        catch
            outputData{1,i} = [];
            outputData{2,i} = [];
            outputData{3,i} = [];
        end
    end
    load('errorCalcData.mat');
    err = modelErr(outputData, rampData, hystData);
    
    %make a note of all the errors & solutions that are optimal with ecah iteration
    [errorTracker(iterCount, 1), loc1] = min(err{1,1});
    [errorTracker(iterCount, 2), loc2] = min(err{1,2});
    [errorTracker(iterCount, 3), loc3] = min(err{1,3});
    
    %save optimal solutions
    currSoz = (2*N) + 1;
    newTopVals = zeros(1,(2*N) + 1);
    newTopVals(1:3,:) = [topVals(loc1,1:currSoz);topVals(loc2,1:currSoz);topVals(loc3,1:currSoz)];  
    top3 = [topVals(loc1,:);topVals(loc2,:);topVals(loc3,:)];
    
    solutionTracker{iterCount,1} = top3(1,:);
    solutionTracker{iterCount,2} = top3(2,:);
    solutionTracker{iterCount,3} = top3(3,:);
    
    %create variations of the optimal solution to be then combined using
    %the genetic algorithm.
    checkerVals = zeros(75, (2*N) + 1);
    checkerVals(1:25, :) = DataSetTool(newTopVals(1,:),24,1);
    checkerVals(26:50, :) = DataSetTool(newTopVals(2,:),24,1);
    checkerVals(51:75, :) = DataSetTool(newTopVals(3,:),24,1);    
    [its, dataSiz] = size(checkerVals);
    for i = 1:its
        checkerVals(i,dataSiz+1) = ViscoErrFuncIncDist(checkerVals(i,1:dataSiz), AllData);
        if i < 4
           top3(i,8) = ViscoErrFuncIncDist(top3(i,1:dataSiz), AllData);
        end
    end
    
    %take 27 random permutation of top solutions
    checkerVals = unique(round(checkerVals,4), 'rows');
    orders = linspace(1,size(checkerVals,1),size(checkerVals,1));
    orders = orders(randperm(length(orders)));
    temp = checkerVals(1:size(checkerVals,1),:);
    randSelec = temp(orders(1,1:27),:);
    
    topVals = [newTopVals;randSelec(:,1:7)];
    clearvars newTopVals;
    [its, dataSiz] = size(topVals);
    for i = 1:its
        topVals(i,dataSiz+1) = ViscoErrFuncIncDist(topVals(i,1:dataSiz), AllData);
    end
    top = topVals(1,:);
    
    %perform genetic iteration on the 30 samples provided
    topVals = GeneticIterator(topVals, N, 50, 5000, minErr, AllData);
    
    %retrieve unique solutions
    topVals = uniquetol(topVals(:,1:(2*N) + 1),0.05,'ByRows',true);
    for j = 1:size(topVals,1)
        topVals(j,(2*N) + 2) = ViscoErrFuncIncDist(topVals(j,1:(2*N) + 1), AllData);
    end
    [~, idx]=sort(topVals(:,(2*N) + 2));
    topVals = [top;top3;topVals(idx,:)];
    
    %write the new iteration of variables to an excel file.
    viscoVariableWriteToFile(topVals(1:numInGen,1:(2*N) + 1), numInGen, N);
    
    %based on model performance, generate a new set of models to be test
    %perform model calculations on the curent dataSet
    output = MainMultiple(iterCount, N);
    iterCount = iterCount + 1;
    if mod(iterCount, 10) == 0
        s = strcat('iteration ',int2str(iterCount), ' completed');
        disp(s)
        clearvars s;
    end
end



% %perform data changes based on outputs and save over data file.
% [convergence,bestData,bestCount] = DataManipulatorVisco(initData, AllData, ones(1,8), bestCount, genCount, maxGens);
% %gather displacement data from the solved models
% output = MainMultiple(1);
% iterCount = 2;
% 
% 
% % Do something with the output results after iterations are completed 
% or a convergence is met