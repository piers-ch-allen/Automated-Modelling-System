load('dataStart.mat');
[best1, err1] = GeneticSolver(20, 10000, 10000, 0, errOut{1,1});
a = 1
[best2, err2] = GeneticSolver(20, 10000, 10000, 0, errOut{1,2});
a = 2
[best3, err3] = GeneticSolver(20, 10000, 10000, 0, errOut{1,3});
a = 3
[best4, err4] = GeneticSolver(20, 10000, 10000, 0, errOut{1,4});
a = 4
[best5, err5] = GeneticSolver(20, 10000, 10000, 0, errOut{1,5});

    
numIts = 100;
numInGen = 10000;
numInitGuess = 10000;
minError = 0;
inErr = errOut{1,2};
