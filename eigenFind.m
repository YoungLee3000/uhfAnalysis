% Extremum ,Area,gradient,node,baseline

%---clear data and obtain the initial parameter;
clear;
INIT_PAR = init_val();
fileDir = [INIT_PAR.targetLabel,'/'];


posCount = 1;
negCount = 1;
plotEnd = 0;
samples = [];

while ~plotEnd
    tempPosFile = [fileDir,'pos_',int2str(posCount),'.txt'];
    tempNegFile = [fileDir,'neg_',int2str(negCount),'.txt'];
    if exist(tempPosFile,'file')
        posData = load(tempPosFile);
        tempEigen = cal_eigen(posData,INIT_PAR.baseline);
        if tempEigen(1) ~= 0
            tempSample = [tempEigen,1];
            samples = [samples;tempSample];
            sprintf('the %d  data complished , in file %s ....',length(samples),tempPosFile )
        end    
        
        posCount = posCount + 1;
    end    
    
    if exist(tempNegFile,'file')
%         negData = load(tempNegFile);
%         tempEigen = cal_eigen(negData,INIT_PAR.baseline);
%         if tempEigen(1) ~= 0
%             tempSample = [tempEigen,0];
%             samples = [samples;tempSample];
%         sprintf('the %d  data complished , in file %s ....',length(samples),tempNegFile )
%         end 
%         

        negCount = negCount + 1;
    end  
    
    if ( ~exist(tempPosFile,'file') && ~exist(tempNegFile,'file'))
        plotEnd = 1;
    end
    
end


dirSet = dir('./');
dirSetSize = length(dirSet);
for i=3:dirSetSize
    if   dirSet(i).isdir &&   ~strcmp(dirSet(i).name,INIT_PAR.targetLabel) 
        numCount = 1;
        plotEnd = 0;
        while ~plotEnd
            tempNumFile = [dirSet(i).name,'/num_',int2str(numCount),'.txt'];
            if exist(tempNumFile,'file')
                numData = load(tempNumFile);
                tempEigen = cal_eigen(numData,INIT_PAR.baseline);
                if tempEigen(1) ~= 0
                    tempSample = [tempEigen,0];
                    samples = [samples;tempSample];
                    sprintf('the %d  data complished , in file %s ....',length(samples),tempNumFile )
                end    
                
                numCount = numCount + 1;
            end
    
            if ( ~exist(tempNumFile,'file'))
                plotEnd = 1;
            end
    
        end
       
    end
   
end    




% col_1 : nodes,  col_2 : peak , col_3 peak_pos,  col_4 : biggest gradient, col_5 : smallest gradient
% col_6 : area,  col_7 : peak width, col_8 left slope, col_9 right slope
% col_10 : kurtosis, col_11 : average
% col_12 : mean square   % col_13 hug status
fid=fopen('samples.txt','w');
for i=1:size(samples,1)
    fprintf(fid,'%d\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%d\n',...
        samples(i,1),samples(i,2),...
        samples(i,3),samples(i,4),samples(i,5),samples(i,6),samples(i,7),...
        samples(i,8),samples(i,9),samples(i,10),samples(i,11),samples(i,12),samples(i,13));
end
fclose('all');





