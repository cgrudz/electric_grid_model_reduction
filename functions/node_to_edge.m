function edge_struct = node_to_edge(edge_struct,bus0,bus1,bus2)
    % The arguments are edge_struct (struct tracking the reductions of
    % degree two buses to edges), bus_0 (the bus to be reduced), and the
    % two buses which define the edge bus_0 is mapped to in the reduced
    % network.  The convention will be that edges are all indexed with the
    % form e_bus1_bus2; bus1<bus2 by convention in reduce_double_W so this
    % yields a consistent indexing for the terminal edges.
    
    % create the strings for possible fieldnames in edge_struct 
    b_1 = num2str(bus1);
    b_2 = num2str(bus2);
    
    a_11 = num2str(min(bus0,bus1));
    a_12 = num2str(max(bus0,bus1));
    a_21 = num2str(min(bus0,bus2));
    a_22 = num2str(max(bus0,bus2));
    
    % the edge we map bus0 to
    e1 = strcat('e_',b_1,'_',b_2);
    % edge between bus0 and bus1
    e2 = strcat('e_',a_11,'_',a_12);
    % edge between bus0 and bus2
    e3 = strcat('e_',a_21,'_',a_22);
    
    % we first check if b_0 was the endpoint of a former reduction
    if (isfield(edge_struct,e2) || isfield(edge_struct,e3))
        % this corresponds to bus0 being the endpoint of an existing edge
        % in the struct, and thus we combine the existing map data when we
        % collapse bus0 into the edge (bus1,bus2)
        if (isfield(edge_struct,e2) && isfield(edge_struct,e3))
            % bus0 connects two existing edges and we combine their data
            if isfield(edge_struct,e1)
                % the edge (bus1,bus2) exists in the struct and we add  
                % all additional buses to data in this edge
                edge_struct.(e1) = [edge_struct.(e1),edge_struct.(e2),...
                    edge_struct.(e3),{[bus1,bus0,bus2]}];
                edge_struct = rmfield(edge_struct,e2);
                edge_struct = rmfield(edge_struct,e3);
            else
                edge_struct.(e1) = [edge_struct.(e2),edge_struct.(e3), ...
                                 {[bus1,bus0,bus2]}];
                edge_struct = rmfield(edge_struct,e2);
                edge_struct = rmfield(edge_struct,e3);
            end
        elseif isfield(edge_struct,e2)
            if isfield(edge_struct,e1)
                % the edge (bus1,bus2) exists in the struct and we add  
                % all additional buses to data in this edge
                edge_struct.(e1) = [edge_struct.(e1),...
                    edge_struct.(e2),{[bus1,bus0,bus2]}];
                edge_struct = rmfield(edge_struct,e2);
            else
                edge_struct.(e1) = [edge_struct.(e2),{[bus1,bus0,bus2]}]; 
                edge_struct = rmfield(edge_struct,e2);
            end
        elseif isfield(edge_struct,e3)
            if isfield(edge_struct,e1)
                % the edge (bus1,bus2) exists in the struct and we add  
                % all additional buses to data in this edge
                edge_struct.(e1) = [edge_struct.(e1),...
                    edge_struct.(e3),{[bus1,bus0,bus2]}];
                edge_struct = rmfield(edge_struct,e3);
            else
                edge_struct.(e1) = [edge_struct.(e3),{[bus1,bus0,bus2]}];
                edge_struct = rmfield(edge_struct,e3);
            end
        end
    else
        if isfield(edge_struct,e1)
            % the edge (bus1,bus2) exists in the struct and we add  
            % all additional buses to data in this edge
            edge_struct.(e1) = [edge_struct.(e1),{[bus1,bus0,bus2]}];
        else
                edge_struct.(e1) = {[bus1,bus0,bus2]};
        end
    end
end