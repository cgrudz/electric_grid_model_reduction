%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Map to js for visualization

%  This script will generate a sparse connectivity matrix and map it to the
%  bus and edge data format readable by vis.js for visualization purposes.
%  This is loaded directly into the html page as a javascript defining the
%  position and plot variables.

%  NOTE: the raw_bus_data and raw_gen_data is NOT INCLUDED in the toy data.
%  THis is simply an example, and can be modified to reflect the per-unit
%  voltage included in the toy data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Opening Lines
clear all;
clc;

addpath('./functions')

load('./processed_data/full_network_connected_component_bus_nums_map.mat',...
    'raw_gen_data', 'raw_bus_data')
load('./processed_data/tr_reduction_ensembles/tr_kv_1000_ens_1000_deg_8.mat')
unstruc = tr_un;
gen_loc = tr_gens;
reindx_mat = triangle_reduced_matrix;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% generate a sparse connectivity matrix

% temp stores the original bus number
temp = 0;
    
% bus_count counts the number of unique buses
bus_count = 0;
    
% storage to keep track of the reduced network and the buses in the
% processed network
sparse_numbering = [];

for i = 1:length(reindx_mat(:,1))
    if reindx_mat(i,1) > temp
        bus_count = bus_count + 1;
        
        % if the bus number is greater than the last
        temp = reindx_mat(i,1);
        
        % store the mapping information
        sparse_numbering = [sparse_numbering; bus_count, temp];
        
        % find all instances of this bus number and reset them to the 
        % unique reduced bus number
        id = reindx_mat(:,1) == temp;
        reindx_mat(id,1) = bus_count;
        id = reindx_mat(:,2) == temp;
        reindx_mat(id,2) = bus_count;
    end
end

lines_count = length(reindx_mat(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Organize connetivity information

% bus numbers for the visualization script come from the renamed matrix,
% while the labels will correspond to the original sanitized data set
bus_nums = sparse_numbering(:,1);
label_nums = sparse_numbering(:,2);

% connectivity struct
C_struct = struct;

% and store the line information with one incidence of each line
for i = 1:length(bus_nums)
    bus0 = bus_nums(i);
    label = label_nums(i);
    
    % define key for the struct
    b0 = strcat('b_',num2str(bus0),'_',num2str(label));
    C_struct.(b0) = [];
    
    % and find the connections corresponding to this bus
    indx = reindx_mat(:,1) == bus0;
    connections = reindx_mat(indx,2);
    
    for j = 1:length(connections)
        % bus numbers in the sparse matrix are in ascending order, in the 
        % first column so that we add line information on a first come
        % first serve basis. If bus0 is connected to a bus that was already
        % encountered, we need not add the line information 
        if bus0 < connections(j)
            C_struct.(b0) = [C_struct.(b0); ...
                             connections(j),label_nums(connections(j))];
        end
    end
    if isempty(C_struct.(b0))
        C_struct = rmfield(C_struct,b0);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Write the bus and edge data to file

fid = fopen('./visualizations/1000_kv_deg_8.js','w+');
fprintf(fid,'var nodes = [\n');
thresholds = [115,138,230,345,500];

% Buses are sorted by trees and triangles, and sub-categorized in the cases
% they contain generators or not. Reductions sorted into voltage threshold
% groups based on the maxiumum voltage bus in the reduction, and those with
% generators are always sorted into generator groups, and labeled with the
% sum of MW values for all generators in the reduction.
for i = 1:(length(bus_nums))
    s1 = strcat('t',num2str(label_nums(i)));
    s2 = strcat('tri',num2str(label_nums(i)));
    gs = strcat('g',num2str(label_nums(i)));
  
    if isfield(unstruc,s1)
        % if a tree, see if it holds generators
        if isfield(gen_loc,s1)
            gens = gen_loc.(s1);
            MW = [];
            for j = 1:length(gens)
                temp = strcat('g',num2str(gens(j)));
                MW = [MW, raw_gen_data.(temp){2}];
            end
            MW = sum(MW);
            fprintf(fid, ...
            '    {id: %d, "label": "%d - B%d, G%d %dMW", group: ''gTree'' },\n', ...
              bus_nums(i),label_nums(i),sum(length(unstruc.(s1))), ...
              sum(length(gen_loc.(s1))),MW);
        % otherwise check the max voltage of a bus in the reduction
        else
            group = threshold_map(unstruc.(s1),raw_bus_data,thresholds,'tree');
            fprintf(fid, ...
              '    {id: %d, "label": "%d - B%d", group: ''%s'' },\n', ...
              bus_nums(i),label_nums(i),sum(length(unstruc.(s1))),group);
        end
    % if a triangle    
    elseif isfield(unstruc,s2)
        % check for generators
        if isfield(gen_loc,s2)
            gens = gen_loc.(s2);
            MW = [];
            for j = 1:length(gens)
                temp = strcat('g',num2str(gens(j)));
                MW = [MW, raw_gen_data.(temp){2}];
            end
            MW = sum(MW);
            fprintf(fid, ...
              '    {id: %d, "label": "%d - B%d, G%d %dMW", group: ''gtri'' },\n', ...
              bus_nums(i),label_nums(i),sum(length(unstruc.(s2))), ...
              sum(length(gen_loc.(s2))),MW);
        % otherwise find the max voltage of all busses in the reduction
        else
            group = threshold_map(unstruc.(s2),raw_bus_data,thresholds,'tri');
            fprintf(fid, ...
              '    {id: %d, "label": "%d - B%d", group: ''%s'' },\n', ...
              bus_nums(i),label_nums(i),sum(length(unstruc.(s2))),group);
        end
    else
        % just a single bus, check if it's a generator
        if isfield(gen_loc,gs)
            MW = raw_gen_data.(gs){2};
            fprintf(fid,'    {id: %d, "label": "%d - G%d %dMW", group: ''gen''},\n', ...
            bus_nums(i),label_nums(i),sum(length(gen_loc.(gs))),MW);        
        else
            group = threshold_map(label_nums(i),raw_bus_data,thresholds,'bus');
            fprintf(fid,'    {id: %d, "label": "%d", group:''%s''},\n', ...
                bus_nums(i),label_nums(i), group);
        end
    end
end
fprintf(fid,'];\n');
fprintf(fid,'var edges = [\n');

% Edges are sorted by whether they contain a reduction or not, and further
% if these reductions contain generators
names = fieldnames(C_struct);
for i = 1:(length(names))
    % unpack the connection information for the bus names{i}
    connects = C_struct.(names{i});
    temp = strsplit(names{i},'_');
    bus0 = str2double(temp{2});
    label0 = temp{3};
    
    for j = 1:length(connects(:,1))
        % we take each of the values listed in the connection information
        % for this bus and determine if the edge formed is a reduction
        bus1 = connects(j,1);
        bus2 = connects(j,2);
        edge = strcat('e_',label0,'_',num2str(bus2));
        if isfield(unstruc,edge)
            if isfield(gen_loc,edge)
                % collapsed edge with generators
                gens = gen_loc.(edge);
                MW = [];
                for k = 1:length(gens)
                    temp = strcat('g',num2str(gens(k)));
                    MW = [MW,raw_gen_data.(temp){2}];
                end
                MW = sum(MW);
                fprintf(fid, ...
                '    {from: %d, to: %d, color:{color:''#800000''}, arrows:{middle:{scaleFactor:60}}, label:"E[B%d,G%d %dMW]", font: {size: 100} },\n', ...      
                        bus0,bus1, sum(length(unstruc.(edge))),...
                        sum(length(gen_loc.(edge))),MW);
            else
                % collapsed edge w/o generators
                % NOTE: THE VISUALIZATION DOESN'T HAVE A GROUP OPTION FOR
                % EDGES AND THUS WE SET THE VARIABLE PLOT SETTINGS HERE
                group = threshold_map(label_nums(i),raw_bus_data,thresholds,'edge');
                switch group
                    case 'edge1'                 
                        arrow = 'color:{color:''#00FFFF''}, arrows: {middle:{scaleFactor:15}},';
                    case 'edge2'
                        arrow = 'color:{color:''#FF00FF''}, arrows: {middle:{scaleFactor:15}},';
                    case 'edge3'
                        arrow = 'color:{color:''#000080''}, arrows: {middle:{scaleFactor:20}},';
                    case 'edge4'
                        arrow = 'color:{color:''#00B200''}, arrows: {middle:{scaleFactor:25}},';
                    case 'edge5'
                        arrow = 'color:{color:''#FF8C00''}, arrows: {middle:{scaleFactor:30}},';
                    case'edge6'
                        arrow = 'color:{color:''#FF0000''}, arrows: {middle:{scaleFactor:40}},';
                end
                fprintf(fid,'    {from: %d, to: %d, %s label:"E[B%d]", font: {size: 100}},\n', ...
                        bus0,bus1,arrow,sum(length(unstruc.(edge))));
            end
        else
            % regular edge
            fprintf(fid,'    {from: %d, to: %d, color:{inherit: ''both''}},\n',bus0,bus1);
        end
    end
end
fprintf(fid,'];');

fclose(fid);