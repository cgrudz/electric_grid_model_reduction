%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Triangle random reduction driver
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script will perform the triangular reduction across the d2 reduced 
% thresholded network and map this reduction back to the d2 reduced network
% collapsing the triangular configurations of similar nominal voltages.
% This utilizes random searching by permuting the list of nodes on each 
% loop of reduce_triangle_recursive_rand.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

addpath('./functions')

load('./processed_data/full_network_connected_component_bus_nums_map.mat',...
     'raw_bus_data','gen_nums')
load('./processed_data/d1_d2_unstructured_reduction_data_structs.mat',...
     'd2_reduc_unstructured')
load('./processed_data/d1_d2_tree_edge_data.mat','d2_reduced_mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define parameters and reduce to the thresholded network

% voltage threshold for the network
volt_thresh = 1000

% degree threshold
deg_thresh = 8;

% list of removed buses
removed_list = [];

% keep a full connection list for the last step and keeping track of the
% reductions
full_list = d2_reduced_mat;

% this will be the operating matrix for the reduction
mat = d2_reduced_mat;

ens_len = 5;

%%
% remove trees with any node in the reduction above the threshold
r_s = d2_reduc_unstructured;
r_names = fieldnames(r_s);

for i = 1:length(r_names)
    max_volt = 0;
    r_name = r_names(i);
    reduc = r_s.(char(r_name));
    %find the max voltage in the tree
    for j = 1:length(reduc)
        b_name = strcat('b',num2str(reduc(j)));
        if max_volt < raw_bus_data.(char(b_name)){1}
            max_volt = raw_bus_data.(char(b_name)){1};
        end
    end
    if max_volt > volt_thresh
        if r_name{1}(1) == 't'
            % if this is a tree reduction
            bus = str2double(r_name{1}(2:end));
            removed_list = [removed_list, bus];
        
            % remove the bus from the working connection list
            mat(mat(:,1) == bus,:) = [];
            mat(mat(:,2) == bus,:) = [];
            
        elseif r_name{1}(1) == 'e'
            % if the reduction is an edge containing reduced buses above
            % the threshold
            temp = strsplit(r_name{1},'_');
            
            b_1 = str2double(temp(2));
            removed_list = [removed_list, b_1];
            
            % remove the bus from the working connection list
            mat(mat(:,1) == b_1,:) = [];
            mat(mat(:,2) == b_1,:) = [];
            
            b_2 = str2double(temp(3));
            removed_list = [removed_list, b_2];
            
            % remove the bus from the working connection list
            mat(mat(:,1) == b_2,:) = [];
            mat(mat(:,2) == b_2,:) = [];
            
        end
    end
end

%%
% now remove any remaining buses above the voltage threshold

bus_list = unique(mat);
count = 0;
while count < length(bus_list)
    count = count + 1;
    bus = bus_list(count);
    b_name = strcat('b',num2str(bus));
    
    if raw_bus_data.(char(b_name)){1} > volt_thresh    
        % remove the bus from the working connection list
        mat(mat(:,1) == bus,:) = [];
        mat(mat(:,2) == bus,:) = [];
        
        removed_list = [removed_list, bus];
    end     
end

thresh_mat = mat;
min_net = length(unique(full_list));
size_rd_dist = [];
tr_deg_dist = [];


for k = 1:ens_len
    k
    
    % make the greedy triangular reduction on the threshold network
    [tr_red_temp, mat] = reduce_triangle_recursive_rand(thresh_mat, ...
                                        full_list,removed_list,deg_thresh);
    
    % and map this collapse back into the full network
    tr_matrix_temp = triangle_map_up(full_list,tr_red_temp);
    tr_deg_dist = [tr_deg_dist, degree_dist(tr_matrix_temp)];
    
    
    % store the number of nodes in the reduced network in a list
    size_rd = length(unique(tr_matrix_temp));
    size_rd_dist(k) = size_rd;
    
    % if this is the smallest network in the ensemble, save the matrix and
    % the reduction struct
    if size_rd < min_net
        min_net = size_rd;
        triangle_reduced_matrix = tr_matrix_temp;
        tr_red = tr_red_temp;
    end
end
%%
tr_un = tr_unstructured_reduction(tr_red,d2_reduc_unstructured);
%%
tr_gens = tr_generator_mapping(tr_un,gen_nums);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save the data
name = strcat('./processed_data/tr_reduction_ensembles/tr_kv_',num2str(volt_thresh),'_ens_',num2str(ens_len),'_deg_',num2str(deg_thresh));

save(name,'tr_red','triangle_reduced_matrix','tr_un','tr_gens',...
          'size_rd_dist','tr_deg_dist')

