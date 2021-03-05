function output = GChecker(input)
N = (size(input,2) - 1) / 2;
values2check = abs(input(1,2:N+1));
minVal = min(values2check);

%generate random seed
rng('default');
rng(sum(100*clock));
randSeed = mod(abs(randn(1)),1);

%check if values are unreasonable
for i = 1:size(values2check,2)
    if values2check(1,i) >= (10 * minVal) && sum(values2check) > 1
        randPerm = mod(abs(randn(1)),1) * randSeed;
        if mod(randi(10),2) == 0
            values2check(1,i) = minVal + randPerm;
        else
            
            values2check(1,i) = minVal - randPerm;
        end
    end
end

%check the values:
if sum(values2check) > 1
    values2check = values2check / sum(values2check);
end

output = input;
output(1,2:N+1) = values2check;