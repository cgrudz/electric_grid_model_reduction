function tr_gens = tr_generator_mapping(tr_un,gen_nums)
    % This script is to map the generator locations to the triangle reduced
    % network


    % We utilize the unstructured location data, contained in tr_un, 
    % sweeping through each fieldnames' values and append all generators 
    % contained in the reduction to a cell array in the gen_struc

    tr_gens = struct;
    names = fieldnames(tr_un);
    len1 = length(names);

    for i = 1:len1
        name = names{i};
        bus_list = tr_un.(name);
        gen_list = intersect(bus_list,gen_nums);
        if ~isempty(gen_list)
            tr_gens.(name) = gen_list;
            gen_nums = setdiff(gen_nums,gen_list);
        end
    end
    
    len2 = length(gen_nums);
    
    for j = 1:len2
        gen_name = strcat('g',num2str(gen_nums(j)));
        tr_gens.(gen_name) = gen_nums(j);    
    end
    
end
