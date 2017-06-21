function dist = degree_dist(mat)
    % this function returns a 1x(size of network) array with the degree of
    % each node in the network
    bus_list = unique(mat);
    dist = [];
    for j = 1:length(bus_list)
        % we store the degree of every node in the reduced network
        temp_deg = sum(mat(:,1) == bus_list(j));
        dist = [dist, temp_deg];
    end
end