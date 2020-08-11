function [Allresults] = MainMultiple(iteration)
%%Script to run abaqus with predefined values.
%output is displacement data by time.
%% Variables Definition
AbacusVariables = ImportScripts(pwd, 1);
mo='noGUI';
%mo='script';

%Make python file with variables
fid = fopen('Var.py', 'w');
fprintf(fid,'GridSpaceX1 = %0.8f\n',AbacusVariables{1,2});
fprintf(fid,'GridSpaceX2 = %0.8f\n',AbacusVariables{2,2});
fprintf(fid,'XOrigin = %0.8f\n',AbacusVariables{3,2});
fprintf(fid,'maxWidth = %0.8f\n',AbacusVariables{4,2});
fprintf(fid,'GridSpaceY1 = %0.8f\n',AbacusVariables{5,2});
fprintf(fid,'GridSpaceY2 = %0.8f\n',AbacusVariables{6,2});
fprintf(fid,'YOrigin = %0.8f\n',AbacusVariables{7,2});
fprintf(fid,'maxHeight = %0.8f\n',AbacusVariables{8,2});
fprintf(fid,'ElasticMod = %0.8f\n',AbacusVariables{9,2});
fprintf(fid,'PoisonRatio = %0.8f\n',AbacusVariables{10,2});
%Add in Z parameters
clearvars ans fid

% Loop variables
fid2 = fopen('LoopVar.py', 'w');
% Load array of load magnitues
abVars = size(AbacusVariables,1);
load = AbacusVariables(11,:); load = load(1,2:size(load,2));
mesh = AbacusVariables(12,:); mesh = mesh(1,2:size(mesh,2));
ogden = AbacusVariables(13:abVars,:); ogden = ogden(1:size(ogden,1),2:size(ogden,2));
for i = 1:size(load,2)
    if strcmp(load{1,i},"")
        load = load(1,1:i-1); break;
    end
end
load = cell2mat(load);
for i = 1:size(mesh,2)
    if strcmp(mesh{1,i},"")
        mesh = mesh(1,1:i-1); break;
    end
end
mesh = cell2mat(mesh);
for i = 1:size(ogden,2)
    if strcmp(ogden{1,i},"")
        ogden = ogden(1,1:i-1); break;
    end
end
ogden = cell2mat(ogden);

%load array of loading parameters
fprintf(fid2,'LoadMagnitudesArray = [');
for i = 1:(size(load,2)-1)
    fprintf(fid2,'%0.2f,', load(1,i));
end
fprintf(fid2,'%0.2f', load(1,size(load,2)));
fprintf(fid2,']\n');
% Load array of Mesh densities
fprintf(fid2,'MeshDensityArray = [');
for i = 1:(size(mesh,2)-1)
    fprintf(fid2,'%0.8f,', mesh(1,i));
end
fprintf(fid2,'%0.8f', mesh(1,size(mesh,2)));
fprintf(fid2,']\n');

% Load array of Odgen parameters
name = strcat('OgdenParams = [');
fprintf(fid2,name);
for i = 1:size(ogden, 1)
    fprintf(fid2,'['); 
    for j = 1:(size(ogden,2)-1)
        fprintf(fid2,'%0.8f,', ogden(i,j));
    end
    fprintf(fid2,'%0.8f', ogden(1,size(ogden,2)));
    fprintf(fid2,']'); 
    if(i ~= size(ogden,1))
        fprintf(fid2,','); 
    end
end
fprintf(fid2,']\n'); 

% Load array of Viscoelastic parameters
viscoP = ImportScripts(pwd, 3);
for numOg = 1:size(viscoP,2)
    name = strcat('Visco', int2str(numOg) ,' = [');
    fprintf(fid2,name);
    vis = viscoP{1,numOg};
    for i = 1:(size(vis,1))
        fprintf(fid2,'['); 
        for j = 1:(size(vis,2))
            fprintf(fid2,'%0.8f', vis(i,j));
            if(j ~= size(vis,2))
                fprintf(fid2,','); 
            end
        end
        fprintf(fid2,']');
        if(i ~= size(vis,1))
            fprintf(fid2,','); 
        end
    end
    fprintf(fid2,']\n'); 
end
fprintf(fid2,'NumVis = %0.8f\n',size(viscoP,2));

%Make models and gather loading results files.
system(['abaqus cae ',mo,'=MultipleRunsMain.py']);
%Clear up leftover variables
clearvars ans fid2 i mo ans AbacusVariables numOg name

%% Output handeler
%access displacement data within the output files.
Allresults = cell(size(load,2), size(mesh,2), size(ogden,1), size(viscoP,2));
newDir = pwd + "\Iteration_" + iteration;
if ~exist(newDir, 'dir')
   mkdir(newDir)
end
for i = 1 : size(load,2)
    for j = 1 : size(mesh, 2)
        for k = 1 : size(ogden,1)
            for v = 1 : size(viscoP,2)
                dir = pwd + "\Cart_Load_Practice_Load" + i + "_Mesh" + j + "_Ogden" + k + "_Visco" + v;
                Allresults{i,j,k,v} = ImportScripts(dir,2);
                %Move previously rounds data into folder structure for safe keeping.
                movefile(dir,newDir);
            end
        end
    end
end
movefile(pwd+"\trialModels.cae", newDir);
copyfile(pwd+"\AbacusVariables.xlsx", newDir);
clearvars i j k dir load mesh ogden name abVars;