outputData = cell(1,10);
for i = 1:10
    try
        data = output{:,:,1,i};
        x = data(:,1)'; disp = data(:,2)'; force = data(:,3)';
        %find location of end of step 1 and its force to define ramp data
        idx = find(x==1.05,1,'first');
        a = 1255000;
        rampData = [a*(x(1,3:idx)-0.05); 10000*disp(1,3:idx)];
        
        %find min and max of cyclic data to normalise values
        siz = size(data,1);
        cycData = [a*(x(1,idx+1:siz)-0.05);10000*disp(1,idx+1:siz)];
        sizC = size(cycData,2);
        %min displacement
        minD = min(cycData(2,:));
        cycData(2,:) = cycData(2,:) - minD;
        
        %define loading profile
        t = linspace(1,2,sizC); 
        funcs=1.225+0.493*sin(6.28*(t));
        cycData(1,:) = funcs;
        Maxidx = find(funcs(1,:)==max(funcs(1,:)));
        Minidx = find(funcs(1,:)==min(funcs(1,:)));
        cycDataUpper = [cycData(:,Minidx+1:sizC),cycData(:,1:Maxidx)];
        cycDataLower = cycData(:,Maxidx+1:Minidx);
    catch
    
    end
    outputData{1,i} = {rampData;cycData};
end

for i = 1:10
        subplot(2,10,(2*i)-1)
        plot(outputData{1,i}{1,1}(3,:),outputData{1,i}{1,1}(2,:));        
        subplot(2,10,(2*i));
        plot(outputData{1,i}{2,1}(3,:),outputData{1,i}{2,1}(2,:));
end    

for i = 1:10
    subplot(2,10,(2*i)-1);
    try
        output1 = output{:,:,1,i};
        plot(output1(:,1),output1(:,2));
        
        subplot(2,10,(2*i));
        plot(output1(:,1),output1(:,3));
    catch
    
    end
end