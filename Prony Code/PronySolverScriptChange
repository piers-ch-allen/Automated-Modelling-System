%%Function to find a suitable set of Prony parameters
function ErrorSet = PronySolverScriptChange(dat, N)
% script will run a user defined number of random interations to get the
% optimal set of paramters
NumIterations = 1000;
%set number of prony parameters
%create a result cell of result sets to work with of a defined number of
%overall runs of the optimisation step
numSteps = 10;
AllSolutions = cell(numSteps,3);
for Iterator = 1:numSteps
    Solutions = zeros(NumIterations, 2+(N*2));
    RandSeed = floor(1000 * rand(1) * rand(1));
    %Initialise the loop to find optimal solution.
    for i = 1 : NumIterations
        fun = @(x)ViscoErrFuncIncDist(x,dat);
        
        %Define the initialisation components.
        seedArray = ones(1,N);
        seed2Array = ones(1,N);
        for j = 1:N
            seedArray(1,j) = RandSeed*rand(1) / 1000;
            seed2Array(1,j) = RandSeed*rand(1) / 100;
        end
        seed2Array = sort(seed2Array);
        x0 = [RandSeed,seedArray,seed2Array];
        
        
        A = zeros(N,size(x0,2));
        A(1,2:N+1) = ones(1,N);
        B = zeros(N,1);
        B(1,1) = 1;
        if(N > 1)
            for d = 1:N-1
                A(d+1,N+d+1) = 1;
                A(d+1,N+d+2) = -1;
                B(d+1,1) = 0;            
            end
        end
        options = optimoptions('fmincon', 'Algorithm', 'interior-point','Display', 'none',  'MaxFunEvals', 10000);
        lb = zeros(1,size(x0,2));
        [a, dist] = fmincon(fun, x0, A, B,[],[], lb, [], [], options);
        Solutions(i,:) = [dist,a];
        if (mod(i,50) == 0)
            a = strcat('iteration ',{' '}, num2str(i), ' complete');  
            disp(a);
        end
    end
    AllSolutions{Iterator,1} = Solutions;
    [a,b] = min(Solutions(:,1));
    AllSolutions{Iterator,2} = a;
    AllSolutions{Iterator,3} = Solutions(b,2:size(Solutions,2));
    disp(strcat('Parent Iteration', {' '}, num2str(Iterator), {' '}, 'Has been completed'));
end
ErrorSet = AllSolutions;
