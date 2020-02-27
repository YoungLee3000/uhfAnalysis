clear;
%train the model
tot_dat = load('samples.dat');
g_col = size(tot_dat,2);
train_dat = tot_dat(:,1:g_col-1);
train_rel = tot_dat(:,g_col);
mdl_dac = ClassificationDiscriminant.fit(train_dat ,train_rel); 
SVMStruct = svmtrain(train_dat ,train_rel); 

tt_dat = load('test.txt');
test_dat = tt_dat(:,1:g_col-1);
tLength = size(tt_dat,1);
tResult = [];
tEigen = [];
count = 1;

% tResult = svmclassify(SVMStruct, test_dat(1:6,:));

for i=1:tLength
    predict_rel = 0;
    tempEigen = [ test_dat(i,:)];
%     if (length(tempEigen==0) == 12)
%         predict_rel = 0;
%     else
        predict_rel = predict(mdl_dac,tempEigen);
%         predict_rel = svmclassify(SVMStruct, tempEigen);
%     end
    tResult = [tResult; predict_rel];
end    


% for i=1:tLength-1
%     for j=i+1:tLength
%         if tt_dat(j,1) - tt_dat(i,1) > 3000
%             xTime = tt_dat(i:j,1) - tt_dat(i,1);
%             tSize = size(xTime,1);
%             yRssi = tt_dat(i:j,2) ;
%             dx = (xTime(tSize) - xTime(1))  / (30 - 1);
%             tempXi =  (xTime(1):dx:xTime(tSize))';
%             tempYi = interp1(xTime,yRssi,tempXi);
%             if (count < 1200)
%                 figure(count);
%                 plot (tempXi,tempYi);
%                 count = count + 30;
%             end    
%             
%             tempEigen = cal_eigen(tempYi,-60);
%             tEigen = [tEigen;tempEigen];
%             predict_rel = 0;
%             if (length(tempEigen==0) == 12)
%                 predict_rel = 0;
%             else
%                 predict_rel = predict(mdl_dac,tempEigen);
%             end
%             tResult = [tResult; predict_rel];
%             sprintf('the result is %d ',predict_rel)
%             break;
%         end    
%     end    
% end    



% fid=fopen('test.txt','w');
% for i=1:size(tEigen,1)
%     fprintf(fid,'%d\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%d\n',...
%         tEigen(i,1),tEigen(i,2),...
%         tEigen(i,3),tEigen(i,4),tEigen(i,5),tEigen(i,6),tEigen(i,7),...
%         tEigen(i,8),tEigen(i,9),tEigen(i,10),tEigen(i,11),tEigen(i,12),0);
% end
% fclose('all');


