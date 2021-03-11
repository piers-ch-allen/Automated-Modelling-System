function viscoVariableWriteToFile(dataManip, numInGen, N)
%%A Tool to save the visco parameters into a excel; file for use and
%%management.
%Gather data into writeable format
data = zeros(numInGen * N, 3);
names = cell(numInGen * N, 1);
siz = size(dataManip,2);
for i = 0:numInGen - 1
    data((i*N)+1:(i*N)+N,1) = dataManip(i+1,2:1+N)';
    data((i*N)+1:(i*N)+N,3) = dataManip(i+1,N+2:siz)';
end

%define name of each set of values
for  i = 0:numInGen - 1
   names{(i*N)+1,1} = strcat('Visco',int2str(i + 1)); 
end

%create and save values to the visco parameter files.
files = strcat(pwd, '\Prony Code\AbacusVariablesVisco.xlsx');
if isfile(files)
    delete (files);
end
filename = strcat(pwd, '\Prony Code\AbacusVariablesVisco.xlsx');
writecell(names, filename,'Sheet',1,'Range','A1');
writematrix(data, filename,'Sheet',1,'Range','B1');