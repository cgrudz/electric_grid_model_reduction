%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reduced Model Generator Mapping

% This script maps the generator locations to the reduced network, with 
% collapsed trees and collapsed buses of degree two. We use the
% unstructured location information for all collapsed buses after the 
% degree two reductions and the locations of generators in the random bus
% numbering to associate generators with their locations in the reduced
% network

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Opening Lines
clear all;
clc;
addpath('./functions')
load('./processed_data/d1_d2_unstructured_reduction_data_structs.mat', ...
                                             'd2_reduc_unstructured', ...
                                             'd1_reduc_unstructured')
load('./processed_data/full_network_toy_data.mat','gen_nums')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sweep through tree data

% In this step, we will begin collecting the generator data into a struct
% that contains lists of generators associated to a single bus.  We sweep
% through the collapsed trees and store a list of all such generator buses.

names = fieldnames(d1_reduc_unstructured);
len1 = length(names);

d1_gen_struct = struct;

for i = 1:len1
    i/len1
    % sweep through all trees in the struct, unpacking the values into temp
    len2 = length(d1_reduc_unstructured.(names{i}));
    branches = d1_reduc_unstructured.(names{i});
    % create a cell array for storage of the generator numbers in the
    % mega-bus... :P
    gens = {};
    for k = 1: length(branches)
        idx = (branches(k) == gen_nums);
        if sum(idx)
            % if we find a generator in the tree, remove from the list of
            % generators and pack into the storage cell array
            gen_nums(idx) = [];
            gens = [gens, branches(k)];
        end
    end
    if ~isempty(gens)
        % the storage cell array is non-empty, so we index all generators
        % in the collapsed tree by the terminal node for the reduction
        gen_i = strcat('g',names{i}(2:end));
        d1_gen_struct.(gen_i) = gens;
    end
end

% We fill the struct with the remaining generators, that are not found in
% the trees from the reduction
for l = 1 : length(gen_nums)
    gen_l = strcat('g',num2str(gen_nums(l)));
    d1_gen_struct.(gen_l) = {gen_nums(l)}; 
end

% Save the tree reduction generator mapping separately, we use this in the
% subsequent step
gen_struct = d1_gen_struct

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Map the generators to the degree two reduced model

% Here we process the gen_struct and map the generators to the
% collapsed trees, and generalized trees, and to the edges they are
% contained in, for the degree two reduction.  We utilize the unstructured
% location data, contained in unstruc_reduc_data, sweeping through each
% fieldnames' values and append all generators contained in the reduction
% to a cell array in the gen_struc

d2_gen_struct = struct;
names1 = fieldnames(d2_reduc_unstructured);
len1 = length(names1);

for ii = 1:len1
    ii/len1
    % we loop over all the d2 reductions
    bus_list = d2_reduc_unstructured.(names1{ii});
    % starting with a new list of the remaining generators in each loop
    names2 = fieldnames(gen_struct);
    len2 = length(names2);
    % we create a list of generators to remove from the list as we find
    % their location in the d2 reductions
    delete_list = {};
    % we use a dummy empty list in deep unpack to take the the final union
    new_gen_list = [];
    for jj = 1:len2
        % the jjth generator bus number
        temp = str2double(names2{jj}(2:end));
        % logical array, if any bus in list matches the generator
        idx = temp == bus_list;
        if sum(idx)
            % we take the union of all entries in the gen struct and the
            % new list of generators
            new_gen_list = deep_unpack(new_gen_list,gen_struct.(names2{jj}));
            % and we append these as an entry in the d2 gen struct
            d2_gen_struct.(names1{ii}) = new_gen_list;
            % we create a delete list to remove all generators already
            % mapped
            delete_list = [delete_list, names2{jj}];
        end
    end
    for kk = 1:length(delete_list)
        gen_struct = rmfield(gen_struct,delete_list{kk});
    end
end

names = fieldnames(gen_struct);
len = length(names);
for ii = 1:len
    ii/len
    % we append all leftover generators not previously mapped to a d2
    % reduction
    gen_name = strcat('g',names{ii}(2:end));
    d2_gen_struct.(gen_name) = deep_unpack([],gen_struct.(names{ii}));
end

d2_gen_struct

save('./processed_data/d1_d2_generator_locs.mat', ...
     'd2_gen_struct','d1_gen_struct')

