function tr_reduc = triangle_append(tr_reduc,full_list,a,b,c)
    % This function will handle the triangle reduction struct to store the
    % bus information.  tr_reduc will be a struct with fieldnames of the
    % form 'tri___' where the blank is a bus number.  Each field is
    % associated with a cell array of two dimensions.  The first is column
    % contains buses in the reduction, the second column is the associated
    % connections to this bus in the full network.
              
    a_name = strcat('tri',num2str(a));
    b_name = strcat('tri',num2str(b));
    c_name = strcat('tri',num2str(c));
    
    % create cell arrays storing the bus and connection information for b
    if isfield(tr_reduc,b_name)
        % we unpack the b_cell and all associated buses in the previous
        % reduction
        b_cell = tr_reduc.(b_name);
        tr_reduc = rmfield(tr_reduc,b_name);
    else
        % if b isn't already a reduction, we store b and all of its
        % connections in a cell array
        b_con = find(full_list(:,1) == b);
        b_con = full_list(b_con,2);
        b_cell = {b, b_con};        
    end
    % same for c
    if isfield(tr_reduc,c_name)
        c_cell = tr_reduc.(c_name);
        tr_reduc = rmfield(tr_reduc,c_name);
    else
        c_con = find(full_list(:,1) == c);
        c_con = full_list(c_con,2);
        c_cell = {c, c_con};
    end
    
    % store all cells in the struct under the terminal node a
    if isfield(tr_reduc,a_name)
       a_cell = tr_reduc.(a_name);
       tr_reduc.(a_name) = [a_cell; b_cell; c_cell];
    else
        a_con = find(full_list(:,1) == a);
        a_con = full_list(a_con,2);
        a_cell = {a, a_con};
        
        tr_reduc.(a_name) = [a_cell; b_cell; c_cell];
    end
end