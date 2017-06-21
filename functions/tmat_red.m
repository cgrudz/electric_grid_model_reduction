function mat = tmat_red(mat,a,b,c)
    % This function will take the matrix of line information and the
    % current triangular configuration and returns the connection matrix 
    % with the triangular configuration collapsed.
        
    % create a sorted array of all of the connections, minus self lines
    a_cons = mat(mat(:,1) == a, 2);
    b_cons = mat(mat(:,1) == b,2);
    c_cons = mat(mat(:,1) == c,2);
        
    t_cons = union(a_cons,b_cons);
    t_cons = union(t_cons,c_cons);
    t_cons = reshape(t_cons,length(t_cons),1);
        
    t_cons = setdiff(t_cons,[a,b,c]);
        
    % remove bus b and c from the first column in the network
    mat(mat(:,1) == b,:) = [];
    mat(mat(:,1) == c,:) = [];
        
    % replace the connections of bus a with the triangular list
    rm_indx = find(mat(:,1) == a);

    a_0 = rm_indx(1);
    a_1 = rm_indx(end);
        
    % enter the sorted list according to the ascending list of
    % connections
    if a_0 == 1
        t_mat = cat(2,ones(length(t_cons),1)*a,t_cons);
        mat = cat(1,t_mat,mat(a_1+1:end,:));
    elseif a_1 == length(mat(:,1))
        t_mat = cat(2,ones(length(t_cons),1)*a,t_cons);
        mat = cat(1,mat(1:a_0-1,:),t_mat);
    else
        t_mat = cat(2,ones(length(t_cons),1)*a,t_cons);
        mat = cat(1,mat(1:a_0-1,:),t_mat,mat(a_1+1:end,:));
    end

    % for each of bus a's connections we insert a into its connection
    % list sorted and avoiding double lines
    for j = 1:length(t_cons)
        con_bus = t_cons(j);
        con_indx = find(mat(:,1) == con_bus);
                
        % we insert a if necessary, else do nothing
        a_0 = con_indx(1);
        a_1 = con_indx(end);
            
        new_lines = union([a],mat(con_indx,2));
        new_lines = setdiff(new_lines,[b,c]);
        new_lines = reshape(new_lines,length(new_lines),1);
            
        if a_0 == 1
            cons = cat(2,ones(length(new_lines),1)*con_bus,new_lines);
            mat = cat(1,cons,mat(a_1+1:end,:));
        elseif a_1 == length(mat(:,1))
            cons = cat(2,ones(length(new_lines),1)*con_bus,new_lines);
            mat = cat(1,mat(1:a_0-1,:),cons);
        else
            cons = cat(2,ones(length(new_lines),1)*con_bus,new_lines);
            mat = cat(1,mat(1:a_0-1,:),cons,mat(a_1+1:end,:));
        end
    end
end
   