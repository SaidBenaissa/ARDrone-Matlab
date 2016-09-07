function [value,min_dist,winner_time] = soiam_prediction(...
    soinn,...
    signal,...
    key_step_length,...
    interval_length) %#codegen

one_block_length=key_step_length+interval_length+1;
min_dist = Inf;
nodes=soinn.nodes;
data_dim = soinn.dimension;
value=zeros(1,data_dim);
winner_time=-1;
if isempty(nodes)==false
    for index=data_dim:-1:1
        for i=interval_length+1:-1:1
            nodes(:,(index-1)*one_block_length+key_step_length+i)=[];
        end
    end   
    D = sqrt(sum(((nodes-repmat(signal,size(nodes,1),1)).^2),2));
    winner_time=0;
    min_dist=0;
    while winner_time<1 && min_dist~=Inf
        [min_dist,min_index]=min(D);
        winner_time=soinn.winTimes(min_index(1));
        D(min_index(1)) = inf;
    end
    % winner_time=soinn.winTimes(min_index);
    for index=0:data_dim-1
        current_soinn_index=index*(key_step_length+interval_length+1);
        value(index+1)=soinn.nodes(min_index,current_soinn_index+key_step_length+1);
    end
end

end

