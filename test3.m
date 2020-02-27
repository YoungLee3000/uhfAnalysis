clear;
%train the model
tot_dat = load('samples.dat');
g_col = size(tot_dat,2);
train_dat = tot_dat(:,1:g_col-1);
train_rel = tot_dat(:,g_col);
mdl_dac = ClassificationDiscriminant.fit(train_dat ,train_rel); 
% mdl_ens = fitensemble(train_dat ,train_rel,'AdaBoostM1' ,100,'tree','type','classification');  

%define the initial parameter
g_count_file = 'label_count.txt';
g_read_file = 'realResult.csv';
fclose('all');
if exist(g_count_file,'file')
    delete(g_count_file);
end 
if exist(g_read_file,'file')
    delete(g_read_file);
end 

INIT_PAR = init_val();
g_stepLength = INIT_PAR.timeStep * 1000 + 1000;
g_interNum = INIT_PAR.timeStep * INIT_PAR.frequency;
g_baseline = INIT_PAR.baseline;
g_stepMax = 5000;
g_testNum = 10; 



%------read the orgin data 
fileID = fopen(INIT_PAR.fileName);
data = textscan(fileID,'%s %d %n %f %s %f','Delimiter',',');
fclose(fileID);

dataLength = size(data{1},1);
g_labelMap = containers.Map;
tot_rel = [];
%foreach time ,otbain the json data from url
for i=1:dataLength
    
    
    
           
            
            tempKey = data{1}{i};
            tempTime = data{3}(i);
            tempRssi = data{4}(i);
            
            if (g_labelMap.isKey(tempKey))
                tempStruct = g_labelMap(tempKey);
                if (tempTime < tempStruct.startTime); tempStruct.startTime = tempTime; end
                
                
                tempStruct.matrix = [tempStruct.matrix; [tempTime, tempRssi]];
                
                g_labelMap(tempKey) = tempStruct;
                tempSmallSize = length(tempStruct.matrix);
                
                % if the data is enough, then analysis this small part
                % data, to judge if the box is hugging
                if ( tempTime - tempStruct.startTime  >= g_stepLength && ... 
                     tempSmallSize >= g_testNum)
                
                    
                    %sort the data according time
                    [rel , pos] = sort(tempStruct.matrix(:,1));
                    tempStruct.matrix(:,1) = tempStruct.matrix(pos,1) ;
                    tempStruct.matrix(:,2) = tempStruct.matrix(pos,2) ;
                    xTime =  tempStruct.matrix(:,1);
                    yRssi = tempStruct.matrix(:,2);
                    dx = (xTime(tempSmallSize) - xTime(1))  / (g_interNum - 1);
                    tempXi =  (xTime(1):dx:xTime(tempSmallSize))';
                    % tempYi is the solved data of first stage, which is used to obatin eigenvalue 
                    tempYi = interp1(xTime,yRssi,tempXi);
                    tempEigen = cal_eigen(tempYi,g_baseline);
                    predict_rel = 0;
                    if (length(find(tempEigen==0)) == 12)
                        predict_rel = 0;
                    else
                        predict_rel= predict(mdl_dac,tempEigen );        
                    end
                    if predict_rel == 1.0
                        fid=fopen(g_read_file,'at+');
                        fprintf(fid,'%s,%8.2f,%d\n',tempKey,tempTime,predict_rel);
                        fclose('all');
                        sprintf('the label %s is read',tempKey)
                        remove(g_labelMap,tempKey);
                    else
                        if tempTime - tempStruct.startTime  >= g_stepMax
%                             tempStruct.matrix(1,:) = [];
%                             tempStruct.startTime = tempStruct.matrix(1,1);
%                             g_labelMap(tempKey) = tempStruct;
                            tempStruct.matrix = [tempTime, tempRssi];
                            tempStruct.startTime = tempTime;
                            g_labelMap(tempKey) = tempStruct;
                        end    
                    end 
                    tot_rel =[tot_rel;predict_rel];
                end    
                
            else
                tempStruct.startTime = tempTime;
                tempStruct.matrix =  [tempTime, tempRssi];
                g_labelMap = [g_labelMap; containers.Map(tempKey,tempStruct)];
            end
       
     
    
end



