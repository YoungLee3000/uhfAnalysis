function [ parameter ] = init_val( )
%---init_val, define the init data ----%

    parameter.fileName = 'origin_data_1.csv';   %---data file name
    
    parameter.targetLabel = 'E20000197812013320104799'; %---target label name
%     parameter.targetLabel = 'E200001978120176201047FF'; %---target label name
%     parameter.targetLabel = 'E2000019781202762010489A'; %---target label name

    parameter.timeStep = 3;   %---the time step of each zone, unit : seconds 
    parameter.frequency = 10; %---the label receives in 1 second
    parameter.baseline = -60; %---the center line of positive data of targetLabel
end

