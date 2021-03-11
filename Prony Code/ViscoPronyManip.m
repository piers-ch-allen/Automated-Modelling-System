function dataSet = ViscoPronyManip(top100, numInGen)
%50:50 split on crossover and mutations
[num,siz] = size(top100);
N = (siz - 1) / 2;
quartile = floor(numInGen / 4);
if(mod(quartile,2) ~= 0) 
    quartile = quartile + 1;
end
%perform the crossover half using top6 values.
%half singlepoint, half k point

%% Single point crossover
rng('default');
rng(sum(100*clock));
randNum = rand(quartile, 3);    
singleDataSet = zeros(quartile, siz);
i = 1;
while i < quartile
    %Generate random seeds for crossover
    crossOverPoint = ceil(mod(randNum(i,1),1) * siz);
    Parent1 = 0; Parent2 = 0;
    while(Parent1 == 0 || Parent2 == 0) 
        Parent1 = ceil(mod(randNum(i,2),1) * num);
        Parent2 = ceil(mod(randNum(i,3),1) * num);
        if (Parent1 == Parent2)
            Parent2 = abs(num - Parent2);
            if Parent2 == 0
                if Parent1 == num
                    Parent2 = Parent1 - 1;
                else
                    Parent2 = Parent1 + 1;
                end
            end
        end
    end
    Parent1 = top100(Parent1,1:siz);
    Parent2 = top100(Parent2,1:siz);
    
    %perform the crossover, 2 children per crossover
    singleDataSet(i,:) = [Parent1(1,1:crossOverPoint), Parent2(1,crossOverPoint+1:siz)];
    i = i + 1;
    singleDataSet(i,:) = [Parent2(1,1:crossOverPoint), Parent1(1,crossOverPoint+1:siz)];
    
    %perform check on time values
    if(crossOverPoint > (N + 2))
        %ensure time are ordered correctly
        singleDataSet(i-1,:) = [singleDataSet(i-1,1:N + 1),sort(singleDataSet(i-1,N+2:siz))];
        singleDataSet(i,:) = [singleDataSet(i-1,1:N + 1),sort(singleDataSet(i,N+2:siz))];
    end
    
    %perform check on g values

    singleDataSet(i-1,1:siz) = GChecker(singleDataSet(i-1,1:siz));
    singleDataSet(i,1:siz) = GChecker(singleDataSet(i,1:siz));
    i = i + 1;
end

%% K point crossover
rng('default');
rng(sum(100*clock));
randNum = rand(quartile, N + 4);  
kDataSet = zeros(quartile, siz);

i = 1;
while i < quartile
    % generate the k points of crossover
    k = ceil(mod(abs(randn(1)),1) * (N-1));
    while k >= (2*N) + 1
        k = k - 1;
    end
    points = zeros(1,k);
    count = 2;
    for j = 1:k
        temp = ceil(mod(randNum(i,j+count),1) * siz);
        while(ismember(temp, points))
            count = count + 1;
            temp = ceil(mod(randNum(i,j+count),1) * siz);
        end
        points(1,j) = temp;
        count = 2;
    end
    
    %generate the parents    
    Parent1 = 0; Parent2 = 0;
    while(Parent1 == 0 || Parent2 == 0) 
        Parent1 = ceil(mod(randNum(i,1),1) * num);
        Parent2 = ceil(mod(randNum(i,2),1) * num);
        if (Parent1 == Parent2)
            Parent2 = abs(num - Parent2);
            if Parent2 == 0
                if Parent1 == num
                    Parent2 = Parent1 - 1;
                else
                    Parent2 = Parent1 + 1;
                end
            end
        end
    end
    Parent1 = top100(Parent1,1:siz);
    Parent2 = top100(Parent2,1:siz);
    
    
    %perform the k crossover
    points = sort(points);
    temp1 = zeros(1,siz);
    temp2 = zeros(1,siz);
    prevVal = 1;
    for j = 1:k
        a = (-1) ^ j;
        if(a > 0)
            temp1(1,prevVal:points(1,j)) = Parent1(1,prevVal:points(1,j));
            temp2(1,prevVal:points(1,j)) = Parent2(1,prevVal:points(1,j));
        else
            temp1(1,prevVal:points(1,j)) = Parent2(1,prevVal:points(1,j));
            temp2(1,prevVal:points(1,j)) = Parent1(1,prevVal:points(1,j));           
        end
        prevVal = points(1,j) + 1;
    end
    %perform the final crossover of each set.
    if(size(points,2) == 1 || points(1,k) < siz)
        a = (-1) ^ (k + 1);
        if(a > 0)
            temp1(1,prevVal:siz) = Parent1(1,prevVal:siz);
            temp2(1,prevVal:siz) = Parent2(1,prevVal:siz);
        else
            temp1(1,prevVal:siz) = Parent2(1,prevVal:siz);
            temp2(1,prevVal:siz) = Parent1(1,prevVal:siz);           
        end
    end
    
    %ensure time are ordered correctly
    temp1 = [temp1(1,1:N + 1),sort(temp1(1,N+2:siz))];
    temp2 = [temp2(1,1:N + 1),sort(temp2(1,N+2:siz))];
    
    %assign values and check g components
    kDataSet(i,:) = GChecker(temp1);
    kDataSet(i+1,:) = GChecker(temp2);
    i = i+2;
end

%% Perform mutations on top 100 values
rng('default');
rng(sum(100*clock));
mutationDataSet = zeros(quartile*2, siz);

%Gaussian mutation on g values
%set up distribution variables
MU_G_g_Nt = [mean(top100(:,1)),mean(mean(top100(:,2:(N+1)))),mean(top100(:,(N+2):siz))];
gvals = top100(:,2:(N+1));
STD_G_g_Nt = [std(top100(:,1)), std(reshape(gvals, 1, N*num)), std(top100(:,(N+2):siz))];
pDs = cell(1,size(MU_G_g_Nt,2));
for i = 1:size(MU_G_g_Nt,2)
    pDs{1,i} = makedist('Normal','mu',MU_G_g_Nt(1,i),'sigma',STD_G_g_Nt(1,i));
end
i = siz;
while i > N+1
    pDs{1,i} = pDs{1,(i - N + 1)}; 
    pDs{1,(i - N + 1)} = pDs{1,2};
    i = i - 1;
end

%perform the mutations
for i = 1:quartile*2
    %Choose parent
    Parent = top100(ceil(mod(abs(randn(1)),1) * num),:);
    for j = 1:siz
        %Chance of mutation is 1/length of array
        mutChance = ceil(mod(abs(randn(1)),1)*siz);
        if(mutChance == 1)
            r = random(pDs{1,j}) - pDs{1,j}.mu;
            Parent(1,j) = Parent(1,j) + r;
        end
    end
    %check time values are correct order
    Parent(1,N+2:siz) = sort(abs(Parent(1,N+2:siz)));
    
    %check g values and assign value
    mutationDataSet(i,:) = GChecker(Parent);
end

dataSet = [singleDataSet;kDataSet;mutationDataSet];