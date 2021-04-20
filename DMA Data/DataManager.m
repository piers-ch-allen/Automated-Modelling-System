%% If files need to be separated into the correct folder structure, run this section
%move the files into the corret folder structure
% for i = 3:10
%     fstruct = dir(append('*Sub',int2str(i),'*.dat'));
%     folder = append(pwd, '\Sub', int2str(i), 'data');
%     if ~exist(folder)
%         mkdir (folder);
%         for j = 1:size(fstruct,1)
%             movefile(append(pwd,'\',fstruct(j).name),folder);
%         end
%     end
% end

%% Runs the data analysis on the data and creates the hysteresis loops to be used as validation data
%perform the hysteresis calcs on all the data
LoopsMat= {};
for i = 3:10
    folder = append(pwd, '\Sub', int2str(i), 'data');
    fstruct = dir(folder); count = 1;
    for j = 1:size(fstruct,1)
        if fstruct(j).bytes ~= 0
            currFile = append(folder,'\',fstruct(j).name)
            [GraphAreaAv, GraphAreaSD, MathArea,Loops] = HysteresisCalc(currFile, 1);
            LoopsMat{count,i} = Loops;
            count = count + 1;
        end
    end
end

%calculate the averages for each of the loops for each of the samples
[leng,wid] = size(LoopsMat);
LoopsMatAvg = cell(leng, wid);
for i = 1:leng
    for j = 1:wid
        CurrentData = LoopsMat{i,j};
        [leng1,wid1] = size(CurrentData);
        currentxy = cell(leng1,wid1);
        for k = 1:2
            currentx = zeros(leng1,20);
            currenty = zeros(leng1,20);
            for h = 1:leng1
                %fit the hysteresis arch to a curve
                x = CurrentData{h,k}(1,:);
                y = CurrentData{h,k}(2,:);
                f = fit(x', y', 'poly3');
                x = linspace(0,max(x),20);
                y = f(x);
                currentx(h,1:20) = x;
                currenty(h,1:20) = y';
            end
            if(leng1 > 1)
                LoopsMatAvg{i,j}{1,k} = mean(currentx);
                LoopsMatAvg{i,j}{2,k} = mean(currenty);
            else
                LoopsMatAvg{i,j}{1,k} = currentx;
                LoopsMatAvg{i,j}{2,k} = currenty;
            end
        end
    end
end


%Calcuate aveage of all the data accross each frequency band
avHysLoops = cell(4,wid +1);
avHysLoops{1,1} = 'X Upper'; avHysLoops{3,1} = 'X Lower';
avHysLoops{2,1} = 'Y Upper'; avHysLoops{4,1} = 'Y Lower';
for i = 1:wid
    allXU = zeros(leng, 20);
    allXL = zeros(leng, 20);
    allYU = zeros(leng, 20);
    allYL = zeros(leng, 20);
    for j = 1:leng
        if size(LoopsMatAvg{j,i}{1,1},1) == 0
            allXU(j,1:20) = ones(1,20) * NaN;
            allXL(j,1:20) = ones(1,20) * NaN;
            allYU(j,1:20) = ones(1,20) * NaN;
            allYL(j,1:20) = ones(1,20) * NaN;
        else
            allXU(j,1:20) = LoopsMatAvg{j,i}{1,1};
            allXL(j,1:20) = LoopsMatAvg{j,i}{1,2};
            allYU(j,1:20) = LoopsMatAvg{j,i}{2,1};
            allYL(j,1:20) = LoopsMatAvg{j,i}{2,2};
        end
    end
    avHysLoops{1,i+1} = nanmean(allXU); avHysLoops{3,i+1} = nanmean(allXL);
    avHysLoops{2,i+1} = nanmean(allYU); avHysLoops{4,i+1} = nanmean(allYL);
end

%convert mm scale to micrometer
for i = 2:9
    avHysLoops{1,i} = avHysLoops{1,i} * 1000;
    avHysLoops{3,i} = avHysLoops{3,i} * 1000;
end

%Convert to pressure scale and correct orrientation
pressureXdispYAverages = avHysLoops;
for i = 2:9
    pressureXdispYAverages{1,i} = 0.75 + (avHysLoops{2,i}/50);
    pressureXdispYAverages{2,i} = avHysLoops{1,i};
    pressureXdispYAverages{3,i} = 0.75 + (avHysLoops{4,i}/50);
    pressureXdispYAverages{4,i} = avHysLoops{3,i};
end

%plot all the figures
for i = 2:5
    subplot(2,2,i-1);
    plot(pressureXdispYAverages{1,i}, pressureXdispYAverages{2,i});
    xlim([0.5,2])
    ylabel('Displacement / um')
    xlabel('Pressure / MPa')
    hold on
    plot(pressureXdispYAverages{3,i}, pressureXdispYAverages{4,i});
    hold on
end

%plot graph of averages of all hysteresis loops
XUAll = []; XDAll = []; YUAll = []; YDAll = [];
for i = 2:9
    XUAll = [XUAll;pressureXdispYAverages{1,i}];
    XDAll = [XDAll;pressureXdispYAverages{3,i}];
    YUAll = [YUAll;pressureXdispYAverages{2,i}];
    YDAll = [YDAll;pressureXdispYAverages{4,i}];
end
figure;
hystCompAverage = {mean(XUAll),mean(YUAll);mean(XDAll), mean(YDAll)};
plot(hystCompAverage{1,1}, hystCompAverage{1,2});
xlim([0.5,2])
ylabel('Displacement / um')
xlabel('Pressure / MPa')
hold on
plot(hystCompAverage{2,1}, hystCompAverage{2,2});
hold on


