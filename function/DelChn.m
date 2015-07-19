function ExChn = DelChn(ExChn,NoChn)
%%%delete one sigle channel from the channel array

Delflag = 0;
for i=1:length(ExChn)
    if ExChn(i) == NoChn
        Delflag = 1;
        break;
    end
end
if Delflag
if i > 1 && i < length(ExChn)
    ExChn = [ExChn(1:i-1) ExChn(i+1:end)];
else
    if i==1
        ExChn = ExChn(2:end);
    else
        if i== length(ExChn)
            ExChn = ExChn(1:end-1);
        end
    end
end
end


