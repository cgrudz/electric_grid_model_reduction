function deg = degree_check(node,mat,full_list,rmd_list,tr_red)
    % This function will check the node to see if it passes below the
    % degree threshold for the reduction.  We search over all connections
    % introduced from the triangular reduction that exist over the voltage
    % threshold, all original connections which existed over the voltage
    % threshold, and finally the degree number of the node in the current
    % reduction step.
    
    n_cons = [];
    
    % We begin by checking the connections which are produced by the
    % reduced nodes in the mapped up network.  These are all connections
    % which will be attached to the threshold network once we map the
    % reduction to the network with all voltages
    key = strcat('tri',num2str(node));
    if isfield(tr_red, key)
        % we form a list of all nodes which are connected to every node in
        % the reduction, in the d2 reduced network
        tr_cons = tr_red.(key)(:,2);
        for i = 1:length(tr_cons)
            n_cons = union(n_cons,tr_cons{i});        
        end 
    end
    
    % even if the is no reduction, we form a list with all d2_network
    % connections of the node
    n_cons = union(full_list(full_list(:,1) == node, 2), n_cons);
    % and intersect this list with the nodes only above the threshold 
    % voltage 
    n_cons = intersect(n_cons, rmd_list);
    % finally we take this list and find its union with the active list of
    % connections in the triangular reduced, thresholded network 
    n_cons = union(mat(mat(:,1) == node, 2), n_cons);
    
    deg = length(n_cons);
end
