function  handles = ChgColorLine(handles)


LColor = ['b','g','k','r','m'];

for i = 1:handles.chans
   if handles.LineColor == 0
       set(handles.hline(i),'Color','b');
   else
       n = mod(i-1,5)+1;
       set(handles.hline(i),'Color',LColor(n));
   end
end