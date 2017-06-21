%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unstructured reduction data script

% We will unpack the information from the degree two reduction into a
% simple list for comparison of location, without the full invertible
% information.  This new list will contain the information from the
% collapsed trees as well, from the degree one reduction.  The degree 1
% unstructured information has the bus locations in the degree 1 reduction
% alone.  I repeat
%
% THE DEGREE 2 UNSTRUCTURED REDUCTION HAS ALL THE BUS/ REDUCTION LOCATIONS
% IN THE DEGREE 2 REDUCED NETWORK FOR EASY COMPARIONS.  THIS IS NOT THE
% CASE FOR THE DEGREE 2 *STRUCTURED* REDUCTION.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Opening Lines
clear all;
clc;
addpath('./functions')
load('./processed_data/d1_d1_tree_edge_data_structs.mat', ...
     'd2_reduction','d1_reduction')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create the unstructured tree information

% create the unstructured struct
names = fieldnames(d1_reduction);
len = length(names);

trees_unstructured = struct;

% we need to perform a deep search into each value in the struct, unpacking
% the data and appending, possibly over several layers with the deep_unpack
for i = 1:len
    field_i = d1_reduction.(names{i});
    list = [];
    list = deep_unpack(list,field_i);
    trees_unstructured.(names{i}) = list;
end

d1_reduc_unstructured = trees_unstructured;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create the unstructured degree two reduction list

names = fieldnames(d2_reduction);
len = length(names);

d2_reduc_unstructured = struct;

% we need to perform a deep search into each value in the struct, unpacking
% the data and appending, possibly over several layers with the deep_unpack
for i = 1:len
    field_i = d2_reduction.(names{i});
    list = [];
    list = deep_unpack(list,field_i);
    if names{i}(1) == 'e'
        buses = strsplit(names{i},'_');
        b2 = str2double(buses{2});
        b3 = str2double(buses{3});
        temp = [b2,b3];
        list = setdiff(list,temp);
    end
    d2_reduc_unstructured.(names{i}) = list;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sweep through the unstructured data, append tree information

% We will append bus numbers to the lists in the usntructured degree two
% reduction data by searching for matching bus numbers in the unstructured
% data, and appending the trees from the degree one reduction to the
% the list of buses where there is a match.

names1 = fieldnames(d2_reduc_unstructured);
len1 = length(names1);

for ii = 1:len1
    ii/len1
    bus_list = d2_reduc_unstructured.(names1{ii});
    names2 = fieldnames(trees_unstructured);
    len2 = length(names2);
    delete_list = {};
    for jj = 1:len2
        temp = str2double(names2{jj}(2:end));
        idx = temp == bus_list;
        if sum(idx)
            new_bus_list = deep_unpack(d2_reduc_unstructured.(names1{ii}), ...
                                       trees_unstructured.(names2{jj}));
            
            d2_reduc_unstructured.(names1{ii}) = new_bus_list;
            delete_list = [delete_list, names2{jj}];
        end
    end
    for kk = 1:length(delete_list)
        trees_unstructured = rmfield(trees_unstructured,delete_list{kk});
    end
end


% append the trees that aren't found in the edges
names = fieldnames(trees_unstructured);
len = length(names);
for ii = 1:len
    ii/len
    d2_reduc_unstructured.(names{ii}) = trees_unstructured.(names{ii});
end

save('./processed_data/d1_d2_unstructured_reduction_data_structs.mat', ...
     'd2_reduc_unstructured','d1_reduc_unstructured')

