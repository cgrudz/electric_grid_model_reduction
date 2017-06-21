function bus_type = threshold_map(buses,raw_bus_data,thresholds,label_type)

    % this function determines the nominal voltage of each bus in the array
    % buses, given in the raw bus data, and returns a string giving the
    % category to place the bus/reduction into given the set thresholds
    
    % thresholds is to be an array of voltage thresholds, the minimum
    % value for each window for the sorting
    
    num_thresholds = length(thresholds);
    num_buses = length(buses);
    
    % create a cell array of possible strings to return, including the case
    % the voltage is above the maximum, minimum voltage    
    level = cell([1,num_thresholds+1]);
    for i = 1:num_thresholds+1
        level{i} = strcat(label_type,num2str(i));
    end
        
    % determine the max voltage of the buses
    volt = 0;
    for i = 1:num_buses
        bus0 = strcat('b',num2str(buses(i)));
        volt = max(volt,raw_bus_data.(bus0){1});
    end 

    % find the first threshold with min that is greater than the voltage,
    % if not, return the max level
    max_level = true;
    for i = 1:num_thresholds
        if volt < thresholds(i)
            max_level = false;
            break
        end
    end
    if max_level
        i = num_thresholds+1;
    end
    
    bus_type = level{i};
    
end
