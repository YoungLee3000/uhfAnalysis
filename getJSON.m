clear;
g_url = 'http://www.chaussure-gros.com/android/getjson.php';
json_dat = webread(g_url);
output = parse_json(json_dat);
% tt = [1,2,3,4,5];   tt(1) = [] is pop() operation of a queue,
%then tt = [2,3,4,5].
labelStruct.startTime = str2double(output.uhfdata{1}.time);
labelStruct.endTime = str2double(output.uhfdata{1}.time);
labelStruct.rssi = str2double(output.uhfdata{1}.time);
labelMap = containers.Map(output.uhfdata{1}.label,labelStruct);