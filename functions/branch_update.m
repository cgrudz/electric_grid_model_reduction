function tree_structure = branch_update(tree_structure,leaf_name,term_name)
    % For leaf, a terminal node of a previous branch, we update the
    % tree struct so that the branch indexed by term contains all
    % sub-branches indexed by the sub-tree leaf and remove the subtree leaf
    
    % unpack the bus numbers from the strings
    leaf_node = str2num(leaf_name(2:end));
    term_node = str2num(term_name(2:end));
    
    % determine the number of branches in the old tree, and the number of
    % existing branches in the tree to be updated
    len_1 = length(tree_structure.(leaf_name));
    len_2 = length(tree_structure.(term_name));
    
    for kk = 1:len_1
        % append the terminal node to all branches that ended with 
        % the collapsed leaf
        tree_structure.(leaf_name){kk} = cat(2, ...
                               tree_structure.(leaf_name){kk},[term_node]);
                           
        tree_structure.(term_name){len_2+kk}=tree_structure.(leaf_name){kk};
    end
    tree_structure = rmfield(tree_structure,leaf_name);
end              