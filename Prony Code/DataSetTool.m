function data = DataSetTool(initProny, numInitGuess, start)
%Generate a random seed
rng('default');
rng(sum(100*clock));
randSeed = mod(abs(randn(1)),1);
N = (size(initProny,2) - 1) / 2;
order = linspace(1,N,N);

%generate the data set for complete randomness
if(start == 0)
    data = zeros(numInitGuess + 1,(2*N)+1); 
    for i = 1:numInitGuess
        %current guess x0, G, g & t series
        order = order(randperm(length(order)));
        x0 = zeros(1,(2*N) + 1);
        %set first value
        x0(1,1) = mod(mod(abs(randn(1)),1) * randSeed, 0.01);
        
        %define g values for 1 to N ensuring summation to 1
        x0(1,order(1)+1) = mod(abs(randn(1)),1) * randSeed;
        totalOrd = x0(1,order(1));
        if N > 1
            for j = 1:N
                x0(1,order(2)+1) = (1 - totalOrd) * (randSeed * mod(abs(randn(1)),1));
                totalOrd = totalOrd + x0(1,order(2)+1);
            end
        end
        
        %define time values for 1 to N ensuring ordering is correct
        temp = zeros(1,N);
        for j = 1:N
            temp(1,j) = 1000 * randSeed * rand(1) * 10^(-1 * j);
        end
        x0(1,(N+2):(2*N)+1) = sort(temp);
        data(i,:) = x0;
    end
    for i = 1:numInitGuess
        data(i,:) = GChecker(data(i,:));
    end
    
%generate the data set using start values
else
    data = zeros(numInitGuess + 1,(2*N)+1); 
    %perform dataset check 
    initProny = GChecker(initProny);
    data(1,:) = initProny;
    rng(sum(100*clock));
    randNum = rand(numInitGuess,(2*N) + 1);
    
    for i = 2:numInitGuess + 1
        %current guess x0, G, g & t series
        x0 = initProny;
        for j = 1:size(initProny,2)
            if(randNum(i-1,j) > 0.5)
                x0(1,j) = x0(1,j) + mod(abs(randn(1)),1);
            else
                x0(1,j) = x0(1,j) - mod(abs(randn(1)),1);
            end
        end
        x0(1,N+2:(2*N)+1) = sort(x0(1,N+2:(2*N)+1));
        data(i,:) = x0;
    end
    for i = 2:numInitGuess + 1
        data(i,:) = GChecker(data(i,:));
    end
end

