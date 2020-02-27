function [ eigenMatrix ] = cal_eigen(data,baseline)
%----cal_eigen, to calculate the eigenvalue of input data-----%


    
    
    g_dx = 0.02;  % define the spce of interpolation
    g_num_eigen = 12; % define the number of eigen value
    
    function [ changePos] = find_solution(curve)
    %---find_solution,  find the solution of curve----%  
        valSign = diff(curve > 0);         % obtain the positive and negative sign of data
        changePos.p_to_n = find(valSign == -1) ;    % the position that sign changes from + to -
        changePos.n_to_p = find(valSign == 1) ;     % the position that sign changes from - to +
        
        changePos.p_size = length(changePos.p_to_n);
        changePos.n_size = length(changePos.n_to_p);
    end
    
    
    
%---Interpolation solving of origin data to find more accurate position    
    g_dataLength = length(data);
    xCount = (1:g_dataLength)';
    xi = (1:g_dx:g_dataLength)';
    g_xLength = length(xi);
    inter_dat = interp1(xCount,data,xi);
    

%---Eigen 1 , calculate the nodes,or the numbers of intersetion between data curve and baseline 
   
    node_result = find_solution(inter_dat - baseline);
    node_p = node_result.p_to_n;
    node_n = node_result.n_to_p;
    ei_node = node_result.p_size + node_result.n_size;
    if ei_node == 0
        eigenMatrix = zeros(1,g_num_eigen );
        return
    end
    
%---Eigen 2 , calculate the extreMum values of data, among them, find the
%---greatest one, in other word, to find the peak of curve  
    der_val = diff(inter_dat) / g_dx;   % calculate the derivative of curve
    der_result = find_solution(der_val);
    
    if der_result.p_size == 0 && der_result.n_size == 0
        eigenMatrix = zeros(1,g_num_eigen );
        return
    end
    
    extremumSet = [ inter_dat(der_result.p_to_n) ; inter_dat(der_result.n_to_p) ];
    extremumPosSet = [der_result.p_to_n ; der_result.n_to_p];
      
           
%     ei_peak =    max(extremumSet) ;
%     if (ei_peak < baseline)
        ei_peak = max(inter_dat);
%     end     
    peak_pos = g_xLength - 1;
    peak_pos_rel =     find( inter_dat == ei_peak);
    if ~isempty(peak_pos_rel)
        peak_pos = peak_pos_rel(1);
    end    
    if peak_pos - 1 <= 5 || g_xLength - peak_pos <= 5
        eigenMatrix = zeros(1,g_num_eigen );
        return
    end    
    
    
    
    %find the integral border accodring to the node or extremum point
    border_left = 1;
    border_right = g_xLength - 1;
    extremumPosSize = length(extremumPosSet);
    
    
    
    sort(node_p,'descend');
    sort(node_n);
    
    if node_result.n_size > 0 &&  node_result.p_size == 0
        for left_pos = 1:node_result.n_size 
            if node_n(left_pos) < peak_pos
                border_left = node_n(left_pos);
            end
        end    
        sort(extremumPosSet,'descend');
        for pos = 1:extremumPosSize
            if extremumPosSet(pos) > peak_pos
               border_right =  extremumPosSet(pos);
               break;
            end   
        end    
    elseif node_result.n_size == 0 &&  node_result.p_size > 0
        for right_pos = 1:node_result.p_size 
            if node_p(right_pos) > peak_pos
                border_right = node_p(right_pos);
                break;
            end
        end   
        sort(extremumPosSet);
        for pos = 1:extremumPosSize
            if extremumPosSet(pos) < peak_pos
               border_left =  extremumPosSet(pos);
            end   
        end 
    elseif  node_result.n_size > 0 &&  node_result.p_size > 0
        for left_pos = 1:node_result.n_size 
            if node_n(left_pos) < peak_pos
                border_left = node_n(left_pos);
            end
        end
        for right_pos = 1:node_result.p_size 
            if node_p(right_pos) > peak_pos
                border_right = node_p(right_pos);
                break;
            end
        end   
         
    end 
    

%---Eigen 3 store the peak position
    ei_peak_pos = peak_pos * g_dx;
        
        
%---Eigen 4 and 5 , calculate the gradient ,both positive and negative
%     border_left
%     peak_pos
%     border_right
%     g_xLength
%     length(der_val)
%     length(inter_dat)
%     extremumPosSet
%     nodePosSet
    
    ei_gradPos = max(der_val(border_left:peak_pos));
    ei_gradNeg = min(der_val(peak_pos:border_right));
    
    
    
    

%---Eigen 6, calculate the area formed of the peak part of curve;
    
   
    %calculete the intergral
    areaZone = inter_dat(border_left:border_right) - baseline;
    ei_area = trapz(areaZone);
    
    
%---Eigen 7, calculate the peak width;
    ei_peak_width = (border_right - border_left) * g_dx;
    
%---Eigen 8, calculate the left slope; 
    ei_left_slope = (inter_dat(peak_pos) - inter_dat(border_left))  / (peak_pos - border_left);
    
%---Eigen 9, calculate the right slope; 
    ei_right_slope = (inter_dat(border_right) - inter_dat(peak_pos))  / (border_right - peak_pos);
    
%---Eigen 10, calculate the kurtosis;   
    ei_kurtosis = kurtosis(inter_dat(border_left:border_right));

%---Eigen 11, calculate the average;
    ei_average = mean(inter_dat);

%---Eigen 12, calculate the mean square;
    ei_square = var(inter_dat);
    
    eigenMatrix = [ ei_node, ei_peak, ei_peak_pos, ei_gradPos, ei_gradNeg, ei_area ,...
                   ei_peak_width, ei_left_slope, ei_right_slope, ei_kurtosis,...
                   ei_average, ei_square];
    return
    
    
    
    
end

