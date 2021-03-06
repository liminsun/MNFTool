%%% calculate the space between lines
function space = CalSpace(data)

DrawMode = 0;
[r,c] = size(data);

if r > c
   DrawMode = 1;
   chans = c;
   frames = r;
else
   chans = r;
   frames = c;
end

space = 0;
if space == 0
    maxindex = min(1000, frames); 
    if DrawMode
    	stds = std(data(1:maxindex,:),[],2);
    else
        stds = std(data(:,1:maxindex),[],2);
    end
	stds = sort(stds);
	if length(stds) > 2
		stds = mean(stds(2:end-1));
	else
		stds = mean(stds);
	end;	
    space = stds*3;  
    if space > 10
      space = round(space);
    end
    if space  == 0 | isnan(space)
        space = 1;
    end;
end
return;