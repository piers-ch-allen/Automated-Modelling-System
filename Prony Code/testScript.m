addpath('Prony Code')
load('dataStart.mat');
bestCount = 1; genCount = 1; maxGens = 100; convergence = false;
numInGen = 10; minErr = 0; inErr = 10000; iterCount = 1; N = 3;
initError = PronySolverScriptChange(AllData, N);
[~, idx]=sort(initError{1,1}(:,(2*N) + 2));
initError{1,1} = initError{1,1}(idx,:);
% [best1, err1] = GeneticSolver(200, 10000, 10000, 0, initError{1,3});
% a = 1
[best2, err2, curr] = GeneticSolver(10, 10000, 10000, 0, initError{1,3});
a = 2
[best3, err3] = GeneticSolver(20, 10000, 10000, 0, initError{1,3});
a = 3
[best4, err4] = GeneticSolver(20, 10000, 10000, 0, errOut{1,4});
a = 4
[best5, err5] = GeneticSolver(20, 10000, 10000, 0, errOut{1,5});

    
numIts = 100;
numInGen = 10000;
numInitGuess = 10000;
minError = 0;
inErr = errOut{1,2};
