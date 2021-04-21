function [AbacusVariables] = ImportScripts(dir, N, importType)
%% Import the data variables (Type 1)
if importType == 1
    DataFile = strcat(dir, '\AbacusVariables.xlsx');
    [~, ~, AbacusVariablesMain] = xlsread(DataFile,'Sheet1');
    AbacusVariables10_0 =  AbacusVariablesMain(2:9,:);
    AbacusVariables11_0 =  AbacusVariablesMain(12:13,:);
    AbacusVariables12_0 =  AbacusVariablesMain(14,:);
    AbacusVariables13_0 =  AbacusVariablesMain(17,:);
    AbacusVariables14_0 =  AbacusVariablesMain(20:size(AbacusVariablesMain,1),:);

    AbacusVariables = [AbacusVariables10_0;AbacusVariables11_0;AbacusVariables12_0;AbacusVariables13_0;AbacusVariables14_0];
    AbacusVariables(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),AbacusVariables)) = {''};

    idx = cellfun(@ischar, AbacusVariables);
    AbacusVariables(idx) = cellfun(@(x) string(x), AbacusVariables(idx), 'UniformOutput', false);

    % Clear temporary variables
    clearvars AbacusVariables10_0 AbacusVariables11_0 AbacusVariables12_0 AbacusVariables13_0 AbacusVariablesMain idx DataFile;

%% Import output data files (Type 2)
elseif importType == 2 
    opts = delimitedTextImportOptions("NumVariables", 2);
    % Specify range and delimiter
    opts.DataLines = [4, Inf];
    opts.Delimiter = " ";

    % Specify column names and types
    opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4"];
    opts.VariableTypes = ["double", "double", "double","double"];

    % Specify file level properties
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts.LeadingDelimitersRule = "ignore";

    % Import the data
    filename = strcat(dir, '\abaqus.rpt');
    try
        abaqus = readtable(filename, opts);
        temp = table2array(abaqus);
        while isnan(temp(1,1))
            temp(1,:) = [];
        end
    catch
        temp = 1;
    end
    %% Convert to output type
    AbacusVariables = temp;
    AbacusVariables(sum(isnan(AbacusVariables), 2) >= 1, :) = [];

    %% Clear temporary variables
    clear opts
elseif importType == 3
    AbacusVariablesVisco = readcell(dir + "\Prony Code\AbacusVariablesVisco.xlsx");
    siz = size(AbacusVariablesVisco,1);
    ViscoVariables = cell(1,siz/N);
    viscoCount = 1;
    for i = 1:siz/N
        ViscoVariables{1,viscoCount} = cell2mat(AbacusVariablesVisco(N*(i-1)+1:N*(i-1)+N,2:4));
        viscoCount = viscoCount + 1;
    end
    %% Clear temporary variables
    clear opts i viscoCount AbacusVariablesVisco
    AbacusVariables = ViscoVariables;
end