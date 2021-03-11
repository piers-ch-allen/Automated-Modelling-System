function [bestParam, errorIt, currentPool] = GeneticSolver(numIts, numInGen, numInitGuess, minError, inErr)
%Data = Real Data, N = Number of terms in series, numIts = number of
%iterations of genetic algorithm, numInitGuess = number of first guesses.

%% Collate initial randomised data guesses
%Initialise the random guesses between the defined bounds
%One guess will 2n+1 vraiables long

if(numInitGuess < 100 || numInitGuess > 1000000)
    numInitGuess = floor(10000 * rand(1));
end

%create the randomised data set
% [initProny, initError, errOut] = getInitProny(5,20000);
load('dataStart.mat');

ovSiz = size(inErr,2);
N = (ovSiz - 1) / 2;
% initGuessData = randomDataSet(N, numInitGuess, storStart, lossStart);
initGuessData = uniquetol(DataSetTool(inErr, numInitGuess, 1),0.005,'ByRows',true);


%% Solve error for all of the initial guesses.
for i = 1:size(initGuessData,1)
    if (mod(i,50000) == 0)
        disp(strcat(int2str(i), ' iteration'));
    end
    initGuessData(i,(2*N) + 2) = ViscoErrFuncIncDist(initGuessData(i,1:(2*N) + 1), AllData);
end
%% Construct the inital gene pool
%perform the selection operation
[~, idx]=sort(initGuessData(:,(2*N) + 2));
currentPool = initGuessData(idx,:);


%% Initialise the genetic loop for the correct number of generations
errorIt = zeros(numIts + 1, 1);
for i = 1:numIts
    if (mod(i, 20) == 0)
        disp(strcat(int2str(i), ' genetic iteration'));
    end
    
    %add a check for current minimum error once rance of errors defined.
    if (currentPool(1,(2*N) + 2) < minError)
        break;
    end
    
    currentPool = currentPool(:,1:ovSiz);
    checkSize = size(currentPool, 1);
    if checkSize > 50
        top50 = currentPool(1:50,:);
    else
        top50 = currentPool;
    end
    
    if checkSize > 100
        %take 50 random choices to ensure diversity
        order = linspace(1,size(currentPool,1) - 50,size(currentPool,1) - 50);
        order = order(randperm(length(order)));
        temp = currentPool(51:size(currentPool,1),:);
        random50 = temp(order(1,1:50),:);
    elseif checkSize < 100 && checkSize > 50
        random50 = currentPool(51:checkSize, :);
    end
    
    
    
    %create a random set to include to improve diversity of results
    randoSet = DataSetTool(inErr, 10000, 0);
    randoSet = uniquetol(randoSet,0.01,'ByRows',true);
    for j = 1:size(randoSet,1)
        randoSet(j,(2*N) + 2) = ViscoErrFuncIncDist(randoSet(j,1:(2*N) + 1), AllData);
    end
    [~, idx]=sort(randoSet(:,(2*N) + 2));
    randoSet = randoSet(idx,1:ovSiz);
    
    %initialise the mutations amd crossovers
    if checkSize > 50
        resultSet = ViscoPronyManip([top50;random50;randoSet(1:25,:)], numInGen);
        currentPool = [resultSet;randoSet;top50;random50];
    else
        resultSet = ViscoPronyManip([top50;randoSet(1:25,:)], numInGen);
        currentPool = [resultSet;randoSet;top50];
    end
    
    %Solve for all new values
    for j = 1:size(currentPool,1)
        currentPool(j,(2*N) + 2) = ViscoErrFuncIncDist(currentPool(j,1:(2*N) + 1), AllData);
    end
    [~, idx]=sort(currentPool(:,(2*N) + 2));
    currentPool = currentPool(idx,:);
    top = currentPool(1,:);
    
    %take out duplicate results based on tolerances
    currentPool = uniquetol(currentPool,0.001,'ByRows',true);
    currentPool = [top;currentPool];
    errorIt(i,1) = top(1,(2*N) + 2);
    bestParam(i,1:(2*N) + 1) =  top(1,1:(2*N) + 1);
end
[~, idx]=sort(currentPool(:,(2*N) + 2));
currentPool = currentPool(idx,:);
errorIt(i+1,1) = currentPool(1,(2*N) + 2);
bestParam(i+1,1:(2*N) + 1) = currentPool(1,1:(2*N) + 1);