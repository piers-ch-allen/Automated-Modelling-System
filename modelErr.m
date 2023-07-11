function [modelErrors] = modelErr(modelData, rampData, hystData)
%calculates and orders the errors of the possible solutions.
numSol = size(modelData, 2);

%% Calculate the ramp error for all sample data
%use percentage difference of each solution to make it more comparable with
%the hysteresis difference calculations.
rampErrors = zeros(1,numSol);
for i = 1:numSol
    currRampData = modelData{1,i};
    percErrArr = zeros(1,size(currRampData, 2));
    %calculate the closest value in the ramp data for force and then
    %determine the percentage difference in the solution.
    for j = 1:size(currRampData, 2)
        currVal = currRampData(1,j);
        [~,idx]=min(abs(rampData(:,1)-currVal));
        percDiff = abs(currRampData(2,j) - rampData(idx,8)) / rampData(idx, 8);
        percErrArr(1,j) = percDiff;
    end
    %calculate avg percentage difference and return to model data file
    avgEr = mean(percErrArr);
    if isnan(avgEr)
       rampErrors(1,i) = 1000000;
    else
       rampErrors(1,i) = avgEr; 
    end
end


%% Calculate the sinusoidal error for all the sample data
hystErrUp = zeros(1,numSol);
hystErrDown = zeros(1,numSol);
%calculate lower half error
for i = 1:numSol
    %gather the data components for the lower half
    if ~isempty(modelData{2,i})
        currDataX = modelData{2,i}(1,:);
        currDataY = 100*modelData{2,i}(2,:);
        hystValforX = hystData{1,3}(currDataX);
        percErrArr = zeros(1,size(currRampData, 2));
        
        %determine the percentage difference in the solution.
        for j = 1:size(currDataX, 2)
            percDiff = abs(abs(currDataY(1,j) - hystValforX(1,j)) / hystValforX(1, j));
            percErrArr(1,j) = percDiff;
        end
        t = isoutlier(percErrArr, 'mean');
        percErrArr(t) = []; 
        %calculate avg percentage difference and return to model data file
        avgEr = mean(percErrArr);
        if isnan(avgEr)
            hystErrUp(1,i) = 10000;
        else
            hystErrUp(1,i) = avgEr;
        end
        
        %gather the data components for the upper half
        currDataX = modelData{3,i}(1,:);
        currDataY = 100*modelData{3,i}(2,:);
        hystValforX = hystData{2,3}(currDataX);
        percErrArr = zeros(1,size(currRampData, 2));
        
        %determine the percentage difference in the solution.
        for j = 1:size(currDataX, 2)
            percDiff = abs(abs(currDataY(1,j) - hystValforX(1,j)) / hystValforX(1, j));
            percErrArr(1,j) = percDiff;
        end
        %calculate avg percentage difference and return to model data file
        t = isoutlier(percErrArr, 'mean');
        percErrArr(t) = []; 
        avgEr = mean(percErrArr);
        if isnan(avgEr)
            hystErrDown(1,i) = 10000;
        else
            hystErrDown(1,i) = avgEr;
        end
    else
        hystErrDown(1,i) = 10000;
        hystErrUp(1,i) = 10000;
    end
    
end
modelErrors = {rampErrors, hystErrDown, hystErrUp};