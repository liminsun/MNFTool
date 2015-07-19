function scale = IntScale(scale)

if scale > 10000
    scale = floor(scale/10000)*10000;
else
    if scale > 1000
        scale = floor(scale/1000)*1000;
    else
        if scale > 100
            scale = floor(scale/100)*100;
        else
            if scale > 10
                scale = floor(scale/10)*10;
            else
                if scale > 5
                    scale = 10;
                end
            end
        end
    end
end


return;