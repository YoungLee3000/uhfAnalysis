
clear;

nNeighbours = 10;
nTree = 5;

% Load the samples data
tot_dat = load('samples.txt');
g_col = size(tot_dat,2);
g_length = size(tot_dat,1);
g_space_num = 5; 
g_dir = 'model-result';

% Classify the positive data and negative data
pos_dat_pos = find(tot_dat(:,g_col) == 1);
neg_dat_pos = find(tot_dat(:,g_col) == 0);

posData = tot_dat(pos_dat_pos,:);
negData = tot_dat(neg_dat_pos,:);

posLength = size(posData,1);
negLength = size(negData,1);

% -----Classify the train data and test data,for each classifaction, do
% various kinds of model predict, and calculate the accuracy of each model
if ~exist(g_dir,'dir')
    mkdir (g_dir);
end   

pos_space = round(posLength / g_space_num) - 1;
neg_space = round(negLength / g_space_num) - 1;

if (pos_space < 2 || neg_space < 2)
    spintf('did not have enough number')
else
    for i = 1:g_space_num
        %---obtain the test data, and the raise is train data
        i_train_dat = [];
        i_test_dat = [];
        i_train_rel = [];
        i_test_rel = [];
        
        
        %add the positive data
        pos_left = pos_space * (i-1) + 1;
        pos_right = pos_space * i;
    
        i_test_dat = [i_test_dat; posData(pos_left:pos_right,1:g_col-1)];
        i_test_rel = [i_test_rel; posData(pos_left:pos_right,g_col)];
        pos_train_zone = [];
        if pos_left == 1 
            pos_train_zone = [pos_train_zone,pos_right+1:posLength ];
        else
            if pos_right == posLength
                pos_train_zone = [pos_train_zone,1:pos_left-1 ];
            else
                pos_train_zone = [pos_train_zone,1:pos_left-1 ];
                pos_train_zone = [pos_train_zone,pos_right+1:posLength ];
            end
        end    
        i_train_dat = [i_train_dat; posData(pos_train_zone,1:g_col-1)];
        i_train_rel = [i_train_rel; posData(pos_train_zone,g_col)];
    
        % add the negative data
        neg_left = neg_space * (i-1) + 1;
        neg_right = neg_space * i;
        
        i_test_dat = [i_test_dat; negData(neg_left:neg_right,1:g_col-1)];
        i_test_rel = [i_test_rel; negData(neg_left:neg_right,g_col)];
        neg_train_zone = [];
        if neg_left == 1 
            neg_train_zone = [neg_train_zone,neg_right+1:negLength ];
        else
            if neg_right == negLength
                neg_train_zone = [neg_train_zone,1:neg_left-1 ];
            else
                neg_train_zone = [neg_train_zone,1:neg_left-1 ];
                neg_train_zone = [neg_train_zone,neg_right+1:negLength ];
            end
        end    
        i_train_dat = [i_train_dat; negData(neg_train_zone,1:g_col-1)];
        i_train_rel = [i_train_rel; negData(neg_train_zone,g_col)];
        
        
        %---train the first model,KNN
        mdl_knn = ClassificationKNN.fit(i_train_dat,i_train_rel,'NumNeighbors',nNeighbours); 
        predict_rel   =  [i_test_rel, predict(mdl_knn, i_test_dat)]; 
        
        %---train the second model, Random Forest
        mdl_rf = TreeBagger(nTree,i_train_dat,i_train_rel);  
        predict_rel = [predict_rel, str2num(cell2mat(predict(mdl_rf,i_test_dat)))]; 
        
        %---train the third model, Naive Bayes
        mdl_nb = NaiveBayes.fit(i_train_dat,i_train_rel);  
        predict_rel   = [predict_rel, predict(mdl_nb,i_test_dat)];         
        
        %---train the forth model, Ensembles
        mdl_ens = fitensemble(i_train_dat,i_train_rel,'AdaBoostM1' ,100,'tree','type','classification');    
        predict_rel   = [predict_rel, predict(mdl_ens,i_test_dat)];  
        
        
        %---train the fifth model, discriminant analysis classifier
        mdl_dac = ClassificationDiscriminant.fit(i_train_dat,i_train_rel);    
        predict_rel   =  [predict_rel, predict(mdl_ens,i_test_dat)];  
        
        
        %---train the sixth model, Support Vector Machine
        SVMStruct = svmtrain(i_train_dat,i_train_rel);  
        predict_rel  =  [predict_rel, svmclassify(SVMStruct, i_test_dat)];  
        
        
        %----save the data
        nRelTot = size(predict_rel,1);
        tempFile = ['predict_result_',int2str(i),'.txt'];
        fid=fopen(tempFile,'w');
        for row=1:nRelTot
            fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\n',...
            predict_rel(row,1),predict_rel(row,2),...
            predict_rel(row,3),predict_rel(row,4),predict_rel(row,5),...
            predict_rel(row,6),predict_rel(row,7));
        end
        fclose('all');
        
        movefile(tempFile,g_dir);
        
        
        %---calculate the Precision and Recall
        p_and_r = [];
        
        for k= 2:7
            n_TP = 0;
            n_FP = 0;
            n_TN = 0;
            n_FN = 0;
            for row = 1:nRelTot
                if predict_rel(row,1) == 1 && predict_rel(row,k) == 1
                    n_TP = n_TP + 1;
                elseif predict_rel(row,1) == 0 && predict_rel(row,k) == 1
                    n_FP = n_FP + 1;
                elseif predict_rel(row,1) == 0 && predict_rel(row,k) == 0
                    n_TN = n_TN + 1;
                elseif predict_rel(row,1) == 1 && predict_rel(row,k) == 0  
                    n_FN = n_FN + 1;
                end    
            end 
            presision = n_TP / (n_TP + n_FP);
            recall = n_TP / (n_TP + n_FN);
            n_F1 = 2 * presision * recall / (recall + presision );
            p_and_r = [ p_and_r ; [ presision ,recall , n_F1]];
        end    
        
        
        evaFile = ['accuracy_',int2str(i),'.txt'];
        fid=fopen(evaFile,'w');
        for row=1:6
            fprintf(fid,'%8.2f\t%8.2f\t%8.2f\n',...
            p_and_r(row,1),p_and_r(row,2),p_and_r(row,3));
        end
        
        fclose('all');
        
        movefile( evaFile,g_dir);
        
    end
    
end







