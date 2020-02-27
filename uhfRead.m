

%------clear the variable£¬and define the parameter in init_val.m
clear;
INIT_PAR = init_val();
g_stepLength = INIT_PAR.timeStep * 1000;
g_interNum = INIT_PAR.timeStep * INIT_PAR.frequency;

%------read the orgin data 
fileID = fopen(INIT_PAR.fileName);
data = textscan(fileID,'%s %d %n %f %s %f','Delimiter',',');
fclose(fileID);


%------classify the daya according to the label name---------%
dataLength = max(size(data{1}));
labelMap = containers.Map;
%------Store each data into a map, where the Key is label name and a n*3 matrix is set to the value
% in the matrix, each row is like [time rssi hug_status].
for i=1:dataLength   
    tempKey = data{1}{i};
    if (labelMap.isKey(tempKey))
        tempMatrix = labelMap(tempKey);
        labelMap(tempKey) = [tempMatrix ; data{3}(i), data{4}(i), data{6}(i) ] ;
    else
        tempMatrix = [ data{3}(i), data{4}(i), data{6}(i)];
       
        labelMap = [labelMap; containers.Map(tempKey,tempMatrix)];
    end
end    

%-----analysis every label from the map
mapSize = max(size(labelMap));  %---number of labels
nameStr = labelMap.keys;    %----set of keys 
matrixSet = labelMap.values;    %----set of values
realCount = 0;

for i=1:mapSize
    sprintf('soving the label of %d....',i)
    tempSize = size( matrixSet{i},1);
    if tempSize < 500 % ----ignore the sample which has a length less than 500 
        continue;
    end 
    if ~exist(nameStr{i},'dir')
        mkdir (nameStr{i});
    else
        rmdir(nameStr{i},'s');
        mkdir (nameStr{i});
    end   
    realCount = realCount + 1;
    
    %----sort the n*3 matrix according to the time, that is the first column
    [rel , pos] = sort(matrixSet{i}(:,1));
    matrixSet{i}(:,1) = matrixSet{i}(pos,1) ;
    matrixSet{i}(:,2) = matrixSet{i}(pos,2) ;
    matrixSet{i}(:,3) = matrixSet{i}(pos,3) ;
    xTime =  matrixSet{i}(:,1) - matrixSet{i}(1,1);
    yRssi = matrixSet{i}(:,2);
    yHug = matrixSet{i}(:,3);
    
    
    if ~strcmp(INIT_PAR.targetLabel,nameStr{i})
        % -----for the labels not in studied,only collect the point accoding to
        % --time step despite the hug status
        pointer1 = 1;
        pointer2 = 1;
        normalCount = 0;
        while ( pointer1 < tempSize || pointer2 <= tempSize)
            if pointer1 < tempSize     
                pointer2 = pointer1;
                while   pointer2 < tempSize  &&  xTime(pointer2) - xTime(pointer1) < g_stepLength 
                    pointer2 = pointer2 + 1;
                end
                
                %interpolation between the zone
                if pointer1 ~= pointer2 
                    normalCount = normalCount + 1;
                    tempX = xTime(pointer1:pointer2)   - xTime(pointer1);
                    tempY = yRssi(pointer1:pointer2);
                    tempSmallSize = size(tempX,1);
                    dx = (tempX(tempSmallSize) - tempX(1))  / (g_interNum - 1);
                    tempXi =  (tempX(1):dx:tempX(tempSmallSize))';
                    tempYi = interp1(tempX,tempY,tempXi);
                    rssiFile = sprintf('%s_%d.txt','num',normalCount);
                    save(rssiFile,'tempYi','-ascii');
                    movefile(rssiFile,nameStr{i});
                    sprintf('the %d normal data of the %d label complished....',normalCount,i)
                end
                pointer1 = pointer2 + 1;
            else
                pointer1 = pointer1 + 1; 
                pointer2 = pointer1;
            end
        
        end
        
        
    else
        % -----for the target label, it shoud be analysised base on the hug status
        % -----for the positive data, according the hug status of 1
        pointer1 = 1;
        pointer2 = 1;
        postitiveCount = 0;
        while ( pointer1 < tempSize || pointer2 <= tempSize)
            if pointer1 < tempSize   &&  yHug(pointer1) == 1    
                pointer2 = pointer1;
                while   pointer2 < tempSize  &&  yHug(pointer2) ~= 0 
                    pointer2 = pointer2 + 1;
                end
                
                
                %---if the length of hugging box zone is less than defined
                %length, it should be added external point aroud this zone
                if xTime(pointer2) - xTime(pointer1) < g_stepLength 
                    preEnd = 0;
                    backEnd = 0;
                    preCount = 1;
                    backCount = 1;
                    
                    while (~preEnd || ~backEnd  )
                        if pointer1 - preCount > 0 && yHug(pointer1-preCount) == 0
                            preCount = preCount + 1;
                            pointer1 = pointer1 - preCount;
                        else
                            preEnd = 1;
                        end    
                
                        if pointer2 + backCount <= tempSize && yHug(pointer2+backCount) == 0
                            backCount = backCount + 1;
                            pointer2 = pointer2 + backCount;
                        else
                            backEnd = 1;
                        end
                
                        if xTime(pointer2) - xTime(pointer1) < g_stepLength 
                            break;
                        end    
                
                    end
                    
                end
            
                %interpolation between the zone
                if pointer1 ~= pointer2 
                    postitiveCount = postitiveCount + 1;
                    tempX = xTime(pointer1:pointer2) - xTime(pointer1);
                    tempY = yRssi(pointer1:pointer2);
                    tempSmallSize = max(size(tempX));
                    dx = (tempX(tempSmallSize) - tempX(1))  / (g_interNum - 1);
                    tempXi =  (tempX(1):dx:tempX(tempSmallSize))';
                    tempYi = interp1(tempX,tempY,tempXi);
                    rssiFile = sprintf('%s_%d.txt','pos',postitiveCount);
                    save(rssiFile,'tempYi','-ascii');
                    movefile(rssiFile,nameStr{i});
                    sprintf('the %d positive data of the target label complished....',postitiveCount)
                end
                pointer1 = pointer2 + 1;
                
            else
                pointer1 = pointer1 + 1; 
                pointer2 = pointer1;
            end
        
        end
        
        % -----for the negative data, according the hug status of 0
        pointer1 = 1;
        pointer2 = 1;
        negativeCount = 0;
        while ( pointer1 < tempSize || pointer2 <= tempSize)
            if pointer1 < tempSize     &&  yHug(pointer1) == 0
                pointer2 = pointer1;
                while ( pointer2 < tempSize  &&  yHug(pointer2) ~= 1  && ...
                        xTime(pointer2) - xTime(pointer1) < g_stepLength )
                    pointer2 = pointer2 + 1;
                end
                
                %interpolation between the zone
                if pointer1 ~= pointer2 
                    negativeCount = negativeCount + 1;
                    tempX = xTime(pointer1:pointer2) - xTime(pointer1);
                    tempY = yRssi(pointer1:pointer2);
                    tempSmallSize = max(size(tempX));
                    dx = (tempX(tempSmallSize) - tempX(1))  / (g_interNum - 1);
                    tempXi =  (tempX(1):dx:tempX(tempSmallSize))';
                    tempYi = interp1(tempX,tempY,tempXi);
                    rssiFile = sprintf('%s_%d.txt','neg',negativeCount);
                    save(rssiFile,'tempYi','-ascii');
                    movefile(rssiFile,nameStr{i});
                    sprintf('the %d negative data of the target label complished....',negativeCount)
                end
                pointer1 = pointer2 + 1;
            else
                pointer1 = pointer1 + 1; 
                pointer2 = pointer1;
            end
        
        end
        
        
    end
    
        
    
   
       
        
        
   
    
%     figure(realCount);
%     plot(xTime,yRssi);
%     xlabel('Ê±¼ä');
%     ylabel('RSSI');
%     title(nameStr{i});
    
end    



