function InChn = InsertChn(InChn, NoChn)
%%%% Insert one channel into a series of channels

Insertflag = 1;
for i=1:length(InChn)
    if InChn(i) == NoChn
        Insertflag  = 0;
        break;
    end
end
if Insertflag
    InChn = sort([InChn NoChn]);
end
return;