function mat = triangle_map_up(mat,tr_reduc)
    % this function will take the full network conection information,
    % without removing voltages or making the triangle reduction, and map
    % the reductions of the triangular configurations back up

    tr_names = fieldnames(tr_reduc);
    for i = 1:length(tr_names)
        % find all the nodes which are collapsed into the triangle, and
        % the union of their associateed connections
        tr = tr_reduc.(char(tr_names{i}));
        
        bus_list = [];
        for j = 1:length(tr)
            bus_list = [bus_list,tr{j,1}];
        end
        a = bus_list(1);
        
        % if the list is size 1 we terminate the collapse process
        while length(bus_list) > 1           
            % give a all of a and b's connections except a and b
            b = bus_list(2);
            new_lines = mat(mat(:,1)==b,2);
            new_lines = reshape(new_lines,length(new_lines),1);
        
            % we connect a to all the new lines
            a_indx = find((mat(:,1) == a));
            a_cons = mat(a_indx,2);
            a_cons = unique([a_cons;new_lines]);
            a_cons = setdiff(a_cons,[a,b]);
            a_cons = reshape(a_cons,length(a_cons),1);
            
            a_mat = cat(2,ones(length(a_cons),1)*a,a_cons); 
          
            if isempty(a_indx)
                a
            end
            a_0 = a_indx(1);
            a_1 = a_indx(end);

            % enter the sorted list according to the ascending list of
            % connections
            if a_0 == 1
                mat = cat(1,a_mat,mat(a_1+1:end,:));
            elseif a_1 == length(mat(:,1))
                mat = cat(1,mat(1:a_0-1,:),a_mat);
            else
                mat = cat(1,mat(1:a_0-1,:),a_mat,mat(a_1+1:end,:));
            end

            % for each of bus a's connections we update their connections
            % removing b and including a
            for j = 1:length(a_cons)
                con_bus = a_cons(j);
                con_indx = find(mat(:,1) == con_bus);

                c_0 = con_indx(1);
                c_1 = con_indx(end);
            
                new_lines = union(a,mat(con_indx,2));
                new_lines = setdiff(new_lines,b);
                new_lines = reshape(new_lines,length(new_lines),1);
                cons = cat(2,ones(length(new_lines),1)*con_bus,new_lines);
                               
                if c_0 == 1
                    mat = cat(1,cons,mat(c_1+1:end,:));
                elseif c_1 == length(mat(:,1))
                    mat = cat(1,mat(1:c_0-1,:),cons);
                else
                    mat = cat(1,mat(1:c_0-1,:),cons,mat(c_1+1:end,:));
                end
            
            end
            
            % remove the second bus from the list and repeat
            mat(mat(:,1) == b,:) = [];
            bus_list(2) = [];
        end
    end
end
