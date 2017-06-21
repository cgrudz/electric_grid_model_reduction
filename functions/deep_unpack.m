function list = deep_unpack(list,data_structure)
    % This function unpacks the structured data in a matlab struct of cell
    % arrays, where each cell contains either a struct, cell array or
    % array - the unpacked data is assumed to be of the class double, so
    % that the recursion terminates by returning the union of the array 
    % values at the end of all cells and structs contained in the data
    % structure.

    % an initial check is done if the object is a structure or a cell
    % array, and the recursive call is performed on the associated cells or
    % field names
    if isstruct(data_structure)
        % find the fieldnames for the struct and recursively call the
        % deep_unpack on each value
        names = fieldnames(data_structure);
        len = length(names);
        for i = 1:len
            list = deep_unpack(list,data_structure.(names{i}));
        end
    elseif iscell(data_structure)
        len = length(data_structure);
        for i = 1:len
            list = deep_unpack(list,data_structure{i});
        end
    else
       list = union(list,data_structure);
    end
    
end
    
    
