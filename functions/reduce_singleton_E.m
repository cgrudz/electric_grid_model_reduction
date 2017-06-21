function [mat,edges] = reduce_singleton_E(mat,edges,bus1,bus2)
    % In the special case where we have produced a degree one node from the
    % reduction of a node to an edge, in the reduce_double_W algorithm,
    % this occurs iff the nodes bus0, bus1, and bus2 were connected in a
    % triangular configuration.  As a result, we may collapse a tree that
    % terminated with a triangle, and as such, we collect the structure
    % information all together.

    % truth value for the while loop is initiated
    reduction_incomplete = true;
    trees = struct;
    
    % last collapsed edge name is saved for collecting possible tree info
    edge = strcat('e_',num2str(bus1),'_',num2str(bus2));
    
    while reduction_incomplete
        % sanity check in case the network has been reduced to a single
        % node
        if isempty(mat)
            break
        end

        % data is ordered sequentially so check singletons in the indices 
        % starting with the first and last elements, where the for loop 
        % doesn't apply
        if mat(1,1)<mat(2,1)
            del_val = mat(1,1);
            deleting = find(mat(:,2) == del_val);
            % we keep track of the tree as it is collapsed in the struc
            % trees
            trees = treetrack(trees,del_val,mat(1,2));
            mat(deleting,:) = [];
            mat(1,:) = [];
            continue
        elseif mat(end,1) > mat(end-1,1)
            del_val = mat(end,1);
            deleting = find(mat(:,2) == del_val);
            trees = treetrack(trees,del_val,mat(end,2));
            mat(deleting,:) = [];
            mat(end,:) = [];
            continue 
        else
            %continue through the rest of the elements
            for i = 2: length(mat(:,1))
                % reduction_incomplete temporarily set to false, but if 
                % another instance of reduction occurs reduction_incomplete
                % is reset to true
                reduction_incomplete = false;
                if mat(i,1)>mat(i-1,1) && mat(i+1,1)>mat(i,1)
                    del_val = mat(i,1);
                    deleting = find(mat(:,2) == del_val);
                    trees = treetrack(trees,del_val,mat(i,2));
                    reduction_incomplete = true;
                    if deleting > i
                        mat(deleting,:) = [];
                        mat(i,:) = [];
                    else
                        mat(deleting,:) = [];
                        mat(i-1,:) = [];
                    end
                    break
                end
            end
        end
    end
    names = fieldnames(trees);
    if ~isempty(names)
        % we have identified a tree collapse after the d2 reduction, and
        % therefore a lasso
        temp = names{1,1};
        % we unpack the tree name and assign the edge to its own struct
        e_struc = struct();
        e_struc.(edge) = edges.(edge);
        % we assign the tree to the edge structure with one cell
        % corresponding to the reduced edges that led to the collapsed
        % lasso which is followed by the tree reductions
        edges.(temp) = {trees.(temp),e_struc};
        % we then remove the edge struct as we have collapsed this into the
        % tree
        edges = rmfield(edges,edge);
    end
