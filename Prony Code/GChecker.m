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
            change = minVal + randPerm;
        else
            change = minVal - randPerm;
        end
        values2check(1,i) = abs(change);
    end
end

%check the values:
if sum(values2check) >= 1
    values2check = values2check / sum(values2check);
    if sum(values2check) == 1
       [~,b] = max(values2check); 
       values2check(b) = values2check(b) - 0.01;
    end
end


%check the time values.
values2check2 = abs(input(1,N+2:N+N+1));
for i = 1:N
    if values2check2(1,i) < 1
        values2check2(1,i) = 1;
    end
end
if N > 1
    for i = 2:N
        if (values2check2(1,i) - 2 * values2check2(1,i-1)) < 0
            values2check2(1,i) = (2 *values2check2(1,i-1)) + rand(1);
        end
    end
end
values2check2=sort(values2check2);

output = input;
output = [output(1,1),values2check,values2check2];