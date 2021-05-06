function currentPool = GeneticIterator(currentPool, N, numIts, numInGen, minError, AllData)
errorIt = zeros(numIts + 1, 1);
ovSiz = size(currentPool,2) - 1;
N = (ovSiz - 1) / 2;

for i = 1:numIts
%     if (mod(i, 20) == 0)
%         disp(strcat(int2str(i), ' genetic iteration'));
%     end
    
    %add a check for current minimum error once rance of errors defined.
    if (currentPool(1,(2*N) + 2) < minError)
        %break;
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
    randoSet = DataSetTool(currentPool(1,1:(2*N)+1), 100, 0);
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
        currentPool(j,1:(2*N) + 1) = GChecker(currentPool(j,1:(2*N) + 1));
        currentPool(j,(2*N) + 2) = ViscoErrFuncIncDist(currentPool(j,1:(2*N) + 1), AllData);
    end
    [~, idx]=sort(currentPool(:,(2*N) + 2));
    currentPool = currentPool(idx,:);
    top = currentPool(1,:);
    
    %take out duplicate results based on tolerances
    errorIt(i,1) = top(1,(2*N) + 2);
end
[~, idx]=sort(currentPool(:,(2*N) + 2));
currentPool = currentPool(idx,:);