function output = GChecker(input)
N = (size(input,2) - 1) / 2;
values2check = abs(input(1,2:N+1));
total =  sum(values2check);

%check the values:
if total > 1 
    values2check = values2check / total;
end
    
output = input;
output(1,2:N+1) = values2check; 
