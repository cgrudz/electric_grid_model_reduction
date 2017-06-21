function mat = addline(mat,bus_0,bus_1,bus_2)
    % Arguments are an array of line information, with dimensions
    % "number of lines" X 2, bus_0, an entry of mat to be removed, and 
    % bus_1 and bus_2 which are entries of mat to have a line connected, ie
    % entries (bus_1,bus_2) and (bus_2,bus_1) are added to mat, conforming
    % to the ascending ordering of bus numbering in mat. If the line
    % already exists, we only delete the instances of bus_0 in the line
    % information.
    
    % delete the instances of bus_0
    temp = mat(:,1) == bus_0;
    mat(temp,:) = [];
    temp = mat(:,2) == bus_0;
    mat(temp,:) = [];
    
    next_bus = true;
            
    % search for bus_1 in the ordered list of buses
    for j = 1:length(mat(:,1))
        if mat(j,1) == bus_1
            % if the line we wish to add already exists, break the for loop
            if mat(j,2) == bus_2
                % no need to search for bus_2, next_bus set to false so we
                % skip the next for loop
                next_bus = false;
                break
            
            % add the line to the list, ordered ascending in both columns
            % of the list, with precedence to first column
            elseif mat(j,2)> bus_2
                % we keep the ordering in the second column
                mat = [mat(1:j-1,:);bus_1,bus_2; mat(j:end,:)];
                break
            end
        elseif mat(j,1)>bus_1
            % here we have reached the end of the list of existing lines
            % connecting bus_1, so we add the row here
            mat = [mat(1:j-1,:);bus_1,bus_2;mat(j:end,:)];
            break
        end
    end
    % add the symmetric value for the above loop, if the line didn't
    % already exist, using the same algorithm as above
    % notice that we can continue from j+1 because bus_2>bus_1
    if next_bus
        for l = j+1:length(mat(:,1))
            if mat(l,1) == bus_2
                if mat(l,2)> bus_1
                    mat = [mat(1:l-1,:);bus_2,bus_1;mat(l:end,:)];
                    break
                end
            elseif mat(l,1)>bus_2
                mat = [mat(1:l-1,:);bus_2,bus_1;mat(l:end,:)];
                break
            end
        end
    end