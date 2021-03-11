function data = DataSetTool(initProny, numInitGuess, start)
%Generate a random seed
rng('default');
rng(sum(100*clock));
randSeed = mod(abs(randn(1)),1);
N = (size(initProny,2) - 1) / 2;
order = linspace(1,N,N);

%generate the data set for complete randomness
if(start == 0)
    data = zeros(numInitGuess,(2*N)+1); 
    for i = 1:numInitGuess
        %current guess x0, G, g & t series
        order = order(randperm(length(order)));
        x0 = zeros(1,(2*N) + 1);
        %set first value
        x0(1,1) = mod(abs(randn(1)),1) * randSeed * 100;
        
        %define g values for 1 to N ensuring summation to 1
        x0(1,order(1,1)+1) = mod(abs(randn(1)),1) * randSeed;
        totalOrd = x0(1,order(1,1)+1);
        if N > 1
            for j = 2:N
                x0(1,order(1,j)+1) = N * (1 - totalOrd) * (randSeed * mod(abs(randn(1)),1));
                totalOrd = totalOrd + x0(1,order(2)+1);
            end
        end
        
        %define time values for 1 to N ensuring ordering is correct
        temp = zeros(1,N);
        for j = 1:N
            a = 0;
            count = 1;
            while a < 1                
                a = randSeed * rand(1) * 10;
                count = count + 1;
                if count == 100
                    randSeed = randSeed * 10;
                    count = 1;
                end
            end
            temp(1,j) = a;
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
    randNum2 = rand(numInitGuess,(2*N) + 1);
    
    %find degree of each variable
    degs = initProny;
    for i = 1:size(initProny,2)
        count = 0;
        a = degs(1,i);
        while a < 1
            a = a * 10; count = count - 1;
        end
        if count == 0 
            count = 1;
        end
        degs(1,i) = count;    
    end
    
    %create new solutions based of their deg of solution
    for i = 2:numInitGuess + 1
        %current guess x0, G, g & t series
        x0 = initProny;
        for j = 1:size(initProny,2)
            change = 1;
            if(randNum(i-1,j) > 0.5) 
                change = -1; 
            end
            degChange = 1;
            if(randNum2(i-1,j) > 0.5) 
                degChange = degChange * 0.1;
            end
            if rand > 0.5
                degChange = degChange * 0.1;
            end
            if i > N + 1
                degChange = degChange * 0.1;
            end
            x0(1,j) = x0(1,j) + (change * degChange * degs(1,j) * mod(abs(randn(1)),1));
        end
        x0(1,N+2:(2*N)+1) = sort(x0(1,N+2:(2*N)+1));
        data(i,:) = x0;
    end
    for i = 2:numInitGuess + 1
        data(i,:) = GChecker(data(i,:));
    end
end

