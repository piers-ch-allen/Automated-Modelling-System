outputData = cell(1,10);
for i = 1:10
    try
        data = output{:,:,1,i};
        x = data(:,1)'; disp = data(:,2)'; force = data(:,3)';
        %find location of end of step 1 and its force to define ramp data
        idx = find(x==1,1,'first');
        curForScal = 1255000 / force(1,idx);
        rampData = [x(1,1:idx);curForScal*disp(1,1:idx);curForScal*force(1,1:idx)];
        
        %find min and max of cyclic data to normalise values
        siz = size(data,1);
        cycData = [x(1,idx:siz);curForScal*disp(1,idx:siz);curForScal*force(1,idx:siz)];
        Maxidx = find(cycData(3,:)==max(cycData(3,:)),1,'first');
        Minidx = find(cycData(3,:)==min(cycData(3,:)),1,'first');
        cycData = cycData(:,Maxidx:Minidx);
        
        %normalise the displacement
        cycData(2,:) = cycData(2,:) - min(cycData(2,:));
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