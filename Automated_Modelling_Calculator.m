function output = Automated_Modelling_Calculator(numIterations, N)
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
output = MainMultiple(numIterations, N);
load('ValidationData.mat');
disp('First set of model runs completed, automations of run starting now.')

while (iterCount < numIterations && convergence == false)
    %calculate the error on the models for eacg set of associated parameters
    outputData = cell(1,10);
    for i = 1:10
        try
            data = output{:,:,1,i};
            x = data(:,1)'; disp = data(:,2)'; force = data(:,3)';
            %find location of end of step 1 and its force to define ramp data
            idx = find(x==1,1,'first');
            curForScal = 1255000 / force(1,idx);
            rampData = [x(1,1:idx);curForScal*disp(1,1:idx);curForScal*force(1,1:idx)];
            
            %find min and max of cyclic data to normalise values
            siz = size(data,1);
            cycData = [x(1,idx:siz);curForScal*disp(1,idx:siz);curForScal*force(1,idx:siz)];
            Maxidx = find(cycData(3,:)==max(cycData(3,:)),1,'first');
            Minidx = find(cycData(3,:)==min(cycData(3,:)),1,'first');
            cycData = cycData(:,Maxidx:Minidx);
            
            %normalise the displacement
            cycData(2,:) = cycData(2,:) - min(cycData(2,:));
        catch
            
        end
        outputData{1,i} = {rampData;cycData};
    end
    err = modelErr(outputData, rampTestData, hystCompAverage);
    
    %based on model performance, generate a new set of models to be test
    %.......
    %save new models to file 
    %viscoVariableWriteToFile(top10, numInGen, N);
        
    %perform model calculations on the curent dataSet
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