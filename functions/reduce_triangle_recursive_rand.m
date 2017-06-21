function [tr_red, mat] = reduce_triangle_recursive_rand(mat,full_list, ...
                                                        rmd_list,bus_thresh)
    % This function will sweep through the matrix of connections and
    % determine if there are triangular configurations.  If one is found 
    % the triangular configuration is stored and the nodes are removed from
    % the network.  We will loop back over the reduced list until the last
    % entry is reached and then quit.  Each iteration, we randomly permute
    % the list of the unique buses in the connectivity matrix.
     
    count = 0;
    tr_red = struct();
    node_list = unique(mat);
    node_len = length(node_list);
    node_list = node_list(randperm(node_len));
    
            
    while count < node_len
        % iterate one index forward in the list
        count = count + 1;
        
        % store the current entry and its connections
        a = node_list(count);
        
        % don't reduce too heavily connected buses
        
        if  bus_thresh < degree_check(a,mat,full_list,rmd_list,tr_red)
            continue
        end

        i = 0;
        a_con = mat(mat(:,1) == a, 2);
        
        while i< length(a_con)
            i = i + 1;
            
            % we search for a base node and collapse triangles into this
            % node until it grows beyond the threshold
            if degree_check(a,mat,full_list,rmd_list,tr_red) > bus_thresh
                break
            end

            % for each connection
            b = a_con(i);
            
            % don't reduce too heavily connected buses
            if bus_thresh < degree_check(b,mat,full_list,rmd_list,tr_red)
                continue
            end
            
            % we check the intersection for a triangle
            b_con = mat(mat(:,1) == b, 2);        
            cons = intersect(a_con,b_con);
            
            if ~isempty(cons)
               % search the triangular configurations for ones of adequate
               % degree
               for k = 1:length(cons)
                   c = cons(k);
                   
                   if degree_check(c,mat,full_list,rmd_list,tr_red) <= bus_thresh
                       % if we find one, we reduce the triangle and start
                       % over
                       tr_red = triangle_append(tr_red,full_list,a,b,c);
                       mat = tmat_red(mat,a,b,c);
                       
                       % reset the list of a's connections and loop back
                       % through from the beginning
                       a_con = mat(mat(:,1) == a, 2);
                           
                       i = 0;
                       count = 0;
                       
                       % reset the node list and randomize
                       node_list = unique(mat);
                       node_len = length(node_list);
                       node_list = node_list(randperm(node_len));
                       break                       
                   end
               end
            end

        end                       
    end
end
