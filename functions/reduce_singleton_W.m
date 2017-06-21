function [mat,trees] = reduce_singleton_W(mat)
    % This function takes an array "mat" of line information, dimension 
    % "number of connections" X 2. The lines have ascending bus number
    % with precedence in the first entry, and ascending thereafter in the
    % second entry, and returns a reduced array where all degree one buses
    % have been collapsed onto other buses, with the same format. 
    % This routine runs recursively so that if a reduction is made, the 
    % routine will begin over again from the begining of the script.


    % truth value for the while loop is initiated
    reduction_incomplete = true;
    trees = struct;
    count = 0
    
    while reduction_incomplete
        % sanity check in case the network has been reduced to a single
        % node
        count = count+1
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
end
