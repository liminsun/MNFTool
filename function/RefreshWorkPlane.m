%%% subfunction of drawing the data
function handles = RefreshWorkPlane(handles,data)

% [handles.chans,xlen] = size(data);
DrawMode = 0;
[r,c] = size(data);

if r > c
   DrawMode = 1;
   handles.chans = c;
   xlen = r;
else
   handles.chans = r;
   xlen = c;
end
% handles.space = CalSpace(data);

for i=1:handles.chans
    YLabels(i,:) = sprintf('%6d',i);
end
YLabels = flipud(str2mat(YLabels,' '));

% meandata = mean(data(:,1:floor(end/20)),2); 

if DrawMode
    meandata = mean(data(1:floor(end/20),:),1); 
else
    meandata = mean(data(:,1:floor(end/20)),2); 
end


handles.pval = handles.space * (handles.chans+1);
handles.yscale = handles.pval * handles.ydiv;

handles.yscale = IntScale(handles.yscale);
handles.pval = handles.yscale/handles.ydiv;
handles.space = handles.pval / (handles.chans+1);


set(handles.ax,'YLim',[0 handles.pval],...
    'YTick',[0:handles.space:handles.chans*handles.space],'YTickLabel', YLabels);

for i = 1:handles.chans
   if DrawMode
        TMP = data(:,handles.chans-i+1) - meandata(1,handles.chans-i+1) + i*handles.space;
   else
        TMP = data(handles.chans-i+1,:) - meandata(handles.chans-i+1,1) + i*handles.space;
   end
   set(handles.hline(i),'YData',TMP,'Color','b');
end

set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
set(handles.ed_v_yscale,'string',num2str(handles.yscale));

return;