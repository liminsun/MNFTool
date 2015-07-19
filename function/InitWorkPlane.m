function handles = InitWorkPlane(handles,data)

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
    
for i=1:handles.chans
    YLabels(i,:) = sprintf('%6d',i);
end
YLabels = flipud(str2mat(YLabels,' '));

if DrawMode
    meandata = mean(data(1:floor(end/20),:),1); 
else
    meandata = mean(data(:,1:floor(end/20)),2); 
end
handles.pval = handles.space * (handles.chans+1);
handles.yscale = handles.pval * handles.ydiv;
handles.xscale = ceil(xlen*handles.xdiv);

handles.xscale = IntScale(handles.xscale);
if handles.xscaletype == 2
    handles.xscale = (handles.xscale)/(handles.fs);
end

handles.yscale = IntScale(handles.yscale);
handles.pval = handles.yscale/handles.ydiv;
handles.space = handles.pval / (handles.chans+1);

set(handles.ax,'YLim',[0 handles.pval],...
    'YTick',[0:handles.space:handles.chans*handles.space],'YTickLabel', YLabels,...
    'XGrid','on','TickLength',[0 0],'visible','on');
axes(handles.ax);
cla;
hold on

for i = 1:handles.chans
    if DrawMode
       handles.hline(i) = plot(data(:,handles.chans-i+1) - meandata(1,handles.chans-i+1) + i*handles.space,...
          'clipping','on','parent',handles.ax);

    else
       handles.hline(i) = plot(data(handles.chans-i+1,:) - meandata(handles.chans-i+1,1) + i*handles.space,...
          'clipping','on','parent',handles.ax);
    end
end
hold off
if handles.xscaletype == 2
    set(handles.ax,'XLim',[0 handles.xscale*handles.fs/handles.xdiv]);
    set(handles.ax,'XTick',[0:handles.xscale*handles.fs:handles.xscale*handles.fs/handles.xdiv],'XTickLabel',[0:handles.xscale:handles.xscale/handles.xdiv]);
    set(get(handles.ax,'xlabel'),'string','Time [second]');
else
    set(handles.ax,'XLim',[0 handles.xscale/handles.xdiv]);
    set(get(handles.ax,'xlabel'),'string','samples');
end

set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);
set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
set(handles.ed_v_yscale,'string',num2str(handles.yscale));
set(handles.ed_v_xscale,'string',num2str(handles.xscale));


handles.scrpages = 1;
handles.curscrpg = 1;

set(handles.bn_begin,'enable','off');
set(handles.bn_prev,'enable','off');
set(handles.bn_next,'enable','off');
set(handles.bn_end,'enable','off');

return;