%%Function to find a suitable set of Prony parameters
function ErrorSet = PronySolverScriptChange(dat, N)
% script will run a user defined number of random interations to get the
% optimal set of paramters
NumIterations = 20;
%set number of prony parameters
%create a result cell of result sets to work with of a defined number of
%overall runs of the optimisation step
AllSolutions = cell(1,3);
Solutions = zeros(NumIterations, 2+(N*2));
%Initialise the loop to find optimal solution.
warning('off','MATLAB:nearlySingularMatrix')
randArr1 = rand(1,NumIterations);
pause(1);
randArr2 = rand(1,NumIterations);
pause(1);
randArr3 = rand(1,NumIterations);
for i = 1 : NumIterations
    fun = @(x)ViscoErrFuncIncDist(x,dat);
    rng('default');
    rng(sum(100*clock));
    RandSeed = floor(1000 * randArr1(i) * randArr2(i));
    %Define the initialisation components.
    seedArray = ones(1,N);
    seed2Array = ones(1,N);
    for j = 1:N
        seedArray(1,j) = mod(RandSeed*randArr3(i) / 100,1);
        a = 0;
        while a <= 1
            if (RandSeed > 100)                
                a =  RandSeed*rand(1) / 100;
            elseif RandSeed <= 1 
                a = 2* rand(1);
            elseif (RandSeed <= 13)
                a =  RandSeed*rand(1);
            else
                a =  RandSeed*rand(1) / 10;
            end
        end
        seed2Array(1,j) = a;
    end
    seed2Array = sort(seed2Array);
    x0 = [RandSeed,seedArray,seed2Array];
    
    
    A = zeros(N,size(x0,2));
    A(1,2:N+1) = ones(1,N);
    B = zeros(N,1);
    B(1,1) = 1;
    if(N > 1)
        for d = 1:N-1
            A(d+1,N+d+1) = 1*ceil(rand(1) * 2)+1;
            A(d+1,N+d+2) = -1;
            B(d+1,1) = 0;
        end
    end
    options = optimoptions('fmincon', 'Algorithm', 'interior-point','Display', 'none',  'MaxFunEvals', 500);
    lb = zeros(1,size(x0,2));
    lb(1,N+2:size(lb,2)) = ones(1,size(lb,2)-(N+1));
    [a, dist] = fmincon(fun, x0, A, B,[],[], lb, [], [], options);
    Solutions(i,:) = [dist,a];
%     if (mod(i,25) == 0)
%         a = strcat('iteration ',{' '}, num2str(i), ' complete');
%         disp(a);
%     end
end
warning('on','MATLAB:nearlySingularMatrix')
AllSolutions{1,1} = Solutions;
[a,b] = min(Solutions(:,1));
AllSolutions{1,2} = a;
AllSolutions{1,3} = Solutions(b,2:size(Solutions,2));
% disp(strcat('Parent Iteration', {' '}, num2str(Iterator), {' '}, 'Has been completed'));
ErrorSet = AllSolutions;
temp = ErrorSet{1,1}(:,1);
ErrorSet{1,1}(:,1:(2*N)+2) = [ErrorSet{1,1}(:,2:(2*N)+2),temp];
