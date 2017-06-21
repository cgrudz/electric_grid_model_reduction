%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% D1/D2 Reduced Network Data Driver
%
% Run me on a big connected component.This script makes the first reduction
% of collapsing the degree one nodes in the network given a sparse
% connectivity matrix.  This must be done before the connectivity matrix is
% fed to the degree two reduction script - it assumes there are no degree
% one buses in the algorithm. The function reduce_singleton_W takes the
% sparse matrix and returns a matrix of edges with all singleton
% buses/edges removed, and a struct of the form:
% d1_reduction.tfoo where foo is a bus number in the returned matrix of 
% edges. The value for the fieldname d1_reduction.tfoo is a cell array with
% individual cells equal to an array, the sequence read left to right
% giving the description of a branch which terminates at bus foo.
% 
% Note: the branches include redundancies, so that if foo_1 is connected to
% foo_4 through foo_3, and foo_2 likewise, 
%  
% d1_reduction.tfoo_4 = {[foo_1, foo_3, foo_4] [foo_2, foo_3, foo_4]}
% 
% In this way, the field name tfoo organizes all branches in the network
% which terminate at foo in the reduced network. 
%
% Also note, that the degree two bus reduction which follows the tree
% reduction assumes no self loops or parallel edges are present in the
% network.
%
% Subsequently the degree two reduction will take place with the function 
% reduce_double_W.  This returns the processed connectivity matrix
% and the d2_reduction struct.  Fields in the d2_reduction struct are
% of the form e_foo1_foo2 for edge reductions and in the same style as for
% the trees for the lassos (generalized trees). Edges are stored in the
% following convention -- foo1 is always less than foo2 and 
%
% d2_reduction_struct.e_foo1_foo2 = {[foo1,foo0,foo2]}
%
% where foo0 is the bus that has been reduced between foo1 and foo2.  If
% multiple reductions have been made, the subsequent reductions are
% appended as new cells in the cell array.  See node_to_edge for more
% details.
%
% Optionally the script will rename the network from bus 1 to the last, for
% convenience in using a sparse connectivity matrix.  Note, the sparse
% numbering arrays include the correspondence between bus numbers in the
% raw_bus_data struct, but *not* back to the OKPG numbering.  This
% correspondence is layered 
%
% NOTE: d2_reduction does not include the reduction information generated
% by the degree 1 reduction. *HOWEVER* when we store the unstructued data
% on the reductions, we will store all the unstructured bus locations,
% after the degree two reduction, in a single list.  This is convenient for
% comparison on bus data, but for reconstruction of the network, I isolated
% the lassos by only including the generalized trees in the struct produced
% by this script.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Opening Lines
clear all;
clc;
addpath('./functions')
load('./processed_data/full_network_toy_data.mat',...
     'connectivity_mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine the buses of degree 1 and collapse these lines/buses

% unpack the connectivity matrix
[row,col] = find(connectivity_mat);

% and format the data so that it is ordered ascending in bus number, with
% precedence to the first column
mat = [col,row];

% begin the search and reduce routine
[d1_reduced_mat, d1_reduction] = reduce_singleton_W(mat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine the buses of degree 2 and collapse these lines/buses

% begin the search and reduce routine
[d2_reduced_mat,d2_reduction] = reduce_double_W(d1_reduced_mat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rename the buses in the d1 reduced network

% optionally renumber the buses in the network so that they start with 
% bus #1 and end with the number of buses in the network 
rename_buses = false;

if rename_buses
    % temp stores the original bus number
    temp = 0;
    % bus_count counts the number of unique buses
    bus_count = 1;
    % storage to keep track of the reduced network and the buses in the
    % processed network
    d1_sparse_numbering = [];
    for i = 1:length(d1_reduced_mat(:,1))
        if d1_reduced_mat(i,1) > temp
            % if the bus number is greater than the last
            temp = d1_reduced_mat(i,1);
            % store the mapping information
            d1_sparse_numbering = [d1_sparse_numbering; bus_count, temp];
            % find all instances of this bus number and reset them to the 
            % unique reduced bus number
            id = d1_reduced_mat(:,1) == temp;
            d1_reduced_mat(id,1) = bus_count;
            id = d1_reduced_mat(:,2) == temp;
            d1_reduced_mat(id,2) = bus_count;
            % update the bus count for the next
            bus_count = bus_count +1;
        end
    end
    bus_count = bus_count - 1;
    lines_count = length(d1_reduced_mat(:,1));

    d1_renamed_sparse = sparse(d1_reduced_mat(:,1),d1_reduced_mat(:,2), ...
                                 ones(lines_count,1),bus_count,bus_count)
       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rename the buses in the d2 reduced network

% optionally renumber the buses in the network so that they start with 
% bus #1 and end with the number of buses in the network 
rename_buses = false;

if rename_buses
    % temp stores the original bus number
    temp = 0;
    % bus_count counts the number of unique buses
    bus_count = 1;
    % storage to keep track of the reduced network and the buses in the
    % processed network
    d2_sparse_numbering = [];
    for i = 1:length(d2_reduced_mat(:,1))
        if d2_reduced_mat(i,1) > temp
            % if the bus number is greater than the last
            temp = d2_reduced_mat(i,1);
            % store the mapping information
            d2_sparse_numbering = [d1_sparse_numbering; bus_count, temp];
            % find all instances of this bus number and reset them to the 
            % unique reduced bus number
            id = d2_reduced_mat(:,1) == temp;
            d2_reduced_mat(id,1) = bus_count;
            id = d2_reduced_mat(:,2) == temp;
            d2_reduced_mat(id,2) = bus_count;
            % update the bus count for the next
            bus_count = bus_count +1;
        end
    end
    bus_count = bus_count - 1;
    lines_count = length(d2_reduced_mat(:,1));

    d2_renamed_sparse = sparse(d2_reduced_mat(:,1),d2_reduced_mat(:,2), ...
                                 ones(lines_count,1),bus_count,bus_count)
       
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save Data
save('./processed_data/d1_d2_tree_edge_data.mat', ...
     'd2_reduced_mat','d2_reduction','d1_reduced_mat','d1_reduction')%, ...
     %'d1_renamed_sparse','d1_sparse_numbering','d2_renamed_sparse','d2_sparse_numbering')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
