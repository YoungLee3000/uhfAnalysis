% posdat = load('E20000197812013320104799/pos_2.txt');
% eigen = cal_eigen(posdat,-60);
%save the samples data
% fid=fopen('myfile.txt','w');
% for i=1:size(samples,1)
%     fprintf(fid,'%d\t%8.2f\t%8.2f\t%8.2f\t%8.2f\t%d\n',samples(i,1),samples(i,2),...
%         samples(i,3),samples(i,4),samples(i,5),samples(i,6));
% end
posdat = load('E20000197812013320104799/pos_2.txt');
figure(1);
plot(posdat);
set(gcf, 'PaperPosition', [-0.75 0.2 26.5 26]);%设置图的位置
set(gcf, 'PaperSize', [25 25]); %Keep the same paper size，设置pdf纸张的大小，
saveas(gcf,['pos_',int2str(1)],'pdf');


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
        figure(posCount);
        plot(posData);
        set(gcf, 'PaperPosition', [-0.75 0.2 26.5 26]);%设置图的位置
        set(gcf, 'PaperSize', [25 25]); %Keep the same paper size，设置pdf纸张的大小，
        saveas(gcf,['pos_',int2str(posCount)],'pdf');
        movefile(['pos_',int2str(posCount),'.pdf'],'uhf-figure');
        sprintf('the %d positive data of the target label complished....',posCount)
        posCount = posCount + 1;
    end    
    
    if exist(tempNegFile,'file')
        negData = load(tempNegFile);
        figure(negCount);
        plot(negData);
        set(gcf, 'PaperPosition', [-0.75 0.2 26.5 26]);%设置图的位置
        set(gcf, 'PaperSize', [25 25]); %Keep the same paper size，设置pdf纸张的大小，
        saveas(gcf,['neg_',int2str(negCount)],'pdf');
        movefile(['neg_',int2str(negCount),'.pdf'],'uhf-figure');
        
        sprintf('the %d negative data of the target label complished....',negCount)
        negCount = negCount + 1;
    end  
    
    if ( ~exist(tempPosFile,'file') && ~exist(tempNegFile,'file'))
        plotEnd = 1;
    end
    
end
close all;