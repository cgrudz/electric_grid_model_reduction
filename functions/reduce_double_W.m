function [mat,d2_reduction] = reduce_double_W(mat)
    % This function takes an array "mat" of line information, dimension 
    % "number of connections" X 2. The lines have ascending bus number
    % with precedence in the first entry, and ascending thereafter in the
    % second entry, and returns a reduced array where all degree two buses
    % have been collapsed, replacing them with lines between their two
    % connections, and returning an array with the same format.  It is
    % assumed that the array mat has already had the degree one buses and
    % associated lines removed, if not use reduce_singletons_driver to
    % process the data. We begin a search for buses of degree two and turn
    % every such bus into a line, if a line connecting the other two buses 
    % doesn't exist.  Following this step, all lines with instances of the 
    % found degree two bus are deleted. Singletons are deleted thereafter
    % for self consistency and the process continues recursively.  When no
    % reduction has been made on an interation of the while loop, the
    % process ends.

    reduction_incomplete = true;
    d2_reduction = struct;
    count = 0
    
    while reduction_incomplete
        count = count + 1
        % sanity check in case the network has been reduced down to a
        % single node

        if isempty(mat)
            break
        end
        
        % reduction_incomplete set to false temporarily
        % if this searches through without making reduction, the process
        % terminates
        reduction_incomplete = false;
        
        % an initial check to first and last blocks is performed
        if mat(1,1) < mat(3,1)
            bus_1 = mat(1,2);
            bus_2 = mat(2,2);
            bus_0 = mat(1,1);
            
            % add line to connect bus_1 and bus_2, and delete instances of
            % bus_0 found in mat, and track the map of the reduced node to
            % the edge in the system
            mat = addline(mat,bus_0,bus_1,bus_2);
            d2_reduction = node_to_edge(d2_reduction,bus_0,bus_1,bus_2);
            
            reduction_incomplete = true;

        elseif mat(end-1,1) > mat(end-2,1)
            bus_1 = mat(end-1,2);
            bus_2 = mat(end,2);
            bus_0 = mat(end,1);
            
            mat = addline(mat,bus_0,bus_1,bus_2);
            d2_reduction = node_to_edge(d2_reduction,bus_0,bus_1,bus_2);
            
            reduction_incomplete = true;
            
        else
            for i = 3:length(mat(2:end-3,1))
                if mat(i,1)>mat(i-1,1) && mat(i+2,1)>mat(i,1)
                    bus_1 = mat(i,2);
                    bus_2 = mat(i+1,2);
                    bus_0 = mat(i,1);
                    
                    mat = addline(mat,bus_0,bus_1,bus_2);
                    d2_reduction = node_to_edge(d2_reduction, ...
                                                bus_0,bus_1,bus_2);
            
                    reduction_incomplete = true;
                    
                    % this step potentially yields singletons, so the for 
                    % loop is broken for consistency of the algorithm.   
                    % we reduce the singletons with once again, track the
                    % reduced edges and start over
                    break
                    
                end
            end
        end
        
        % check for tree value in the struct attached to the node bus_0
        % and map this tree struct to a cell in the edge value
        tree = strcat('t',num2str(bus_0));
        if isfield(d2_reduction,tree)
            % we have found a tree collapsed to bus_0
            e1 = strcat('e_',num2str(bus_1),'_',num2str(bus_2));
            % we assign this tree reduction to a struct with one field
            tree_struc = struct();
            tree_struc.(tree) = d2_reduction.(tree);
            % we include this as the final cell in the reduction
            d2_reduction.(e1){end+1} = tree_struc;
            d2_reduction = rmfield(d2_reduction,tree);
        end
        
        % reduce singletons step
        [mat,d2_reduction] = reduce_singleton_E(mat,d2_reduction, ...
                                                bus_1,bus_2); 
    end
end
