function tree_structure = treetrack(tree_structure,leaf_node,terminal_node)
    % The tree structure is a struc of cell arrays with fields given by the
    % terminal node of the tree organized in the cell array.  Cells are
    % given by arrays that describe individual branches, with leaves first
    % until the end of the branch at the end value of the array.

    % Field names given by t followed by bus_number
    leaf = strcat('t',num2str(leaf_node));
    term = strcat('t',num2str(terminal_node));
    
    if isfield(tree_structure,term)
        % This condition corresponds to the leaf collapsing to an 
        % existing branch in the tree, with terminal node term.
        if isfield(tree_structure,leaf)
            % here we have leaf as a terminal node for a previous branch
            % we attach this branch to the index in the struct, term, 
            % and append all sub-branches which end with leaf to end 
            % with term.
            tree_structure=branch_update(tree_structure,leaf,term);
        else
            % otherwise simply add this as a new branch to the tree ending
            % in term
            len = length(tree_structure.(term));
            tree_structure.(term){len+1} = [leaf_node,terminal_node];
        end        
    else 
        % we must add the terminal node to the field names and check
        % for a branch in the struct that ended with the leaf
        tree_structure.(term) = {};
        if isfield(tree_structure,leaf)
            tree_structure=branch_update(tree_structure,leaf,term);
        else
            tree_structure.(term){1} = [leaf_node,terminal_node];
        end
    end
end

