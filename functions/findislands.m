function [islandsidx] = findislands(C)

    addpath('./SpathFEX05')

    bi=1:length(C);
    bitemp=bi;
    i=0;

    while ~isempty(bitemp)
        i = i+1;
        
        [p, D, iter] = BFMSpathOT(C,bitemp(1));
        islandsidx{i} = find(~isinf(D));
        deleteidx=[];
        
        for j=1:length(islandsidx)
            deleteidx=[deleteidx;islandsidx{j}];
        end
        
        bitemp=bi;
        bitemp(deleteidx)=[];
        
    end
     
end