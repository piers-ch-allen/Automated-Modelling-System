function [err] = modelErr(modelData, rampData, hystData)
%calculates and orders the errors of the possible solutions.
numSol = size(modelData, 2);

%% Calculate the ramp error for all sample data
%use percentage difference of each solution to make it more comparable with
%the hysteresis difference calculations.
for i = 1:numSol
    currRampData = modelData{1,i};
    percErrArr = zeros(1,size(currRampData, 2));
    %calculate the closest value in the ramp data for force and then
    %determine the percentage difference in the solution.
    try
        for j = 1:size(currRampData, 2)
            currVal = currRampData(1,j);
            [~,idx]=min(abs(rampData(:,1)-currVal));
            percDiff = abs(currRampData(2,j) - rampData(idx,8)) / rampData(idx, 8);
            percErrArr(1,j) = percDiff;
        end
        %calculate avg percentage difference and return to model data file
        modelData{3,i} = mean(perrErrArr);
    catch       
        modelData{3,i} = [];
    end
end


%% Calculate the sinusoidal error for all the sample data


