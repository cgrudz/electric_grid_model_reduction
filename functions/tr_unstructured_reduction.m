function tr_un = tr_unstructured_reduction(tr_red,d2_struc)
    % this function will return the unstructured data associated with the
    % triangular reduction giving a list of bus and generator locations
    
    tr_un = struct();
    tr_names = fieldnames(tr_red);
    d2_struc = orderfields(d2_struc);
    d2_names = fieldnames(d2_struc);
    tr_search_stop =length(tr_names);
    
    for i = 1:tr_search_stop
        i/tr_search_stop
        % find all the nodes which are collapsed into the triangle
        tr_n = char(tr_names{i});
        tr = tr_red.(tr_n);
        
        bus_list = [];
        for j = 1:length(tr)
            bus_list = [bus_list,tr{j,1}];
        end
        
        tr_un.(tr_n) = bus_list;
        
        % search the previous reductions for associated buses
        count = 0;
        stop_point = length(d2_names);
        while count < stop_point
            count = count + 1;
            
            % for the current reduction check if an edge or tree
            red = d2_names{count};
            if red(1) == 'e'
                % if edge
                temp = strsplit(red,'_');
                b1 = str2double(temp(2));
                b2 = str2double(temp(3));
                              
                % see if both endpoints lie in the triangular reduction
                if sum(ismember([b1,b2],bus_list)) == 2
                    % append all edge information if so, remove the name
                    tr_un.(tr_n) = union(tr_un.(tr_n),d2_struc.(red));
                    
                    % reset the list of d2 reductions
                    d2_struc = orderfields(rmfield(d2_struc,red));
                    d2_names = fieldnames(d2_struc);
                    
                    % start the search from the current position with the
                    % field removed
                    stop_point = length(d2_names);
                    count = count - 1;
                    
                end
                
            elseif red(1) == 't'
                % if tree find if the endpoint lies in the triangular
                % reduction
                b1 = str2double(red(2:end));
                if ismember(b1,bus_list)
                    tr_un.(tr_n) = union(tr_un.(tr_n),d2_struc.(red));
                    
                    % reset the list of d2 reductions
                    d2_struc = orderfields(rmfield(d2_struc,red));
                    d2_names = fieldnames(d2_struc);
                    
                    % start the search from the current position with the
                    % field removed
                    stop_point = length(d2_names);
                    count = count - 1;
                    
                end
            end
        end
    end
    
    % copy the remaining reductions to this updated reduction
    d2_names = fieldnames(d2_struc);
    
    for i = 1:length(d2_names)
        red = d2_names{i};
        tr_un.(red) = d2_struc.(red);
    end
end
    
