clear;
%train the model
tot_dat = load('samples.dat');
g_col = size(tot_dat,2);
train_dat = tot_dat(:,1:g_col-1);
train_rel = tot_dat(:,g_col);
% mdl_dac = ClassificationDiscriminant.fit(train_dat ,train_rel); 
mdl_ens = fitensemble(train_dat ,train_rel,'AdaBoostM1' ,100,'tree','type','classification');  

%define the initial parameter
g_options = weboptions('CharacterEncoding','utf-8','Timeout',3);
g_count_file = 'label_count.txt';
g_read_file = 'realResult.txt';
fclose('all');
if exist(g_count_file,'file')
    delete(g_count_file);
end 
if exist(g_read_file,'file')
    delete(g_read_file);
end 
g_loop = 1;
% INIT_PAR = init_val();
g_stepLength = 3000;
g_stepMax = 5000;
g_interNum = 30;
g_baseline = -60;
g_testNum = 10; 
g_url = 'http://www.chaussure-gros.com/android/getjson.php';




g_labelMap = containers.Map;
%foreach time ,otbain the json data from url
while g_loop
    json_dat = [];
    try 
        json_dat = webread(g_url);
    catch
        continue;
    end
    
    if strcmp('file is empty',json_dat) ||  strcmp('Unable to open file!',json_dat)
        continue;
    else
        output = parse_json(json_dat);
        if ~isempty(output.uhfdata)
            if strcmp('read end',output.uhfdata{1}.label)
                break;
            end  
            outputCell = output.uhfdata{1};
            tempKey = outputCell.label;
            tempTime = str2double(outputCell.time);
            tempRssi = str2double(outputCell.rssi);
            fileCount=fopen(g_count_file ,'at+');
            fprintf(fileCount,'%s\t%8.2f\t%8.2f\n',tempKey,tempTime,tempRssi);
            fclose('all');
            if (g_labelMap.isKey(tempKey))
                tempStruct = g_labelMap(tempKey);
                if (tempTime < tempStruct.startTime); tempStruct.startTime = tempTime; end
                tempStruct.matrix = [tempStruct.matrix; [tempTime, tempRssi]];
                g_labelMap(tempKey) = tempStruct;
                tempSmallSize = length(tempStruct.matrix);
                
                % if the data is enough, then analysis this small part
                % data, to judge if the box is hugging
                if ( tempTime - tempStruct.startTime  >= g_stepLength && ...
                    tempTime - tempStruct.startTime  <= g_stepMax    && ...  
                     tempSmallSize >= g_testNum)
                
                    
                    %sort the data according time
                    [rel , pos] = sort(tempStruct.matrix(:,1));
                    tempStruct.matrix(:,1) = tempStruct.matrix(pos,1) ;
                    tempStruct.matrix(:,2) = tempStruct.matrix(pos,2) ;
                    xTime =  tempStruct.matrix(:,1) - tempStruct.matrix(1,1);
                    yRssi = tempStruct.matrix(:,2);
                    dx = (xTime(tempSmallSize) - xTime(1))  / (g_interNum - 1);
                    tempXi =  (xTime(1):dx:xTime(tempSmallSize))';
                    % tempYi is the solved data of first stage, which is used to obatin eigenvalue 
                    tempYi = interp1(xTime,yRssi,tempXi);
                    tempEigen = cal_eigen(tempYi,g_baseline);
                    predict_rel = 0;
                    if (length(tempEigen==0) == 12)
                        predict_rel = 0;
                    else
                        predict_rel = predict(mdl_ens,tempEigen);
                    end
                    if predict_rel == 1.0
                        fid=fopen(g_read_file,'at+');
                        fprintf(fid,'%s\t%8.2f\t%d\n',tempKey,tempTime,predict_rel);
                        fclose('all');
                        sprintf('the label %s is read',tempKey)
                        remove(g_labelMap,tempKey);
                    else
                        tempStruct.matrix(1,:) = [];
                        g_labelMap(tempKey) = tempStruct;
                    end    
                end    
                
            else
                tempStruct.startTime = tempTime;
                tempStruct.matrix =  [tempTime, tempRssi];
                g_labelMap = [g_labelMap; containers.Map(tempKey,tempStruct)];
            end
        end    
    end    
    
end



