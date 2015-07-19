function handles = waitdlg(handles)

set(0,'UNITS','pixels');
scn = get(0,'screensize');
scn(3) = floor(scn(3)/2);
scn(4) = floor(scn(4)/2);
if scn(1) < 1,  scn(1) = 10; end;
if scn(2) < 1,  scn(2) = 10; end;

DEFAULT_UNIT ='normalized';
FONTSIZE = 11;

fig = findobj('tag','F_Wait');
if ~isempty(fig)
    close(fig);
end

DEFAULT_F_WAIT_POSITION = [scn(3) scn(4) scn(3)/4 scn(4)/8];
handles.hwaitdlg = figure('name', '',...
      'MenuBar','none','tag', 'F_Wait' ,'Position',DEFAULT_F_WAIT_POSITION, ...
      'ToolBar','none','numbertitle', 'off', 'visible', 'on' );

BACKCOLOR = get(handles.hwaitdlg,'color');

DEFAULT_Message_POSITION = [0.1 0.2 0.8 0.6];
uicontrol('Parent',handles.hwaitdlg, ...
	'Units', DEFAULT_UNIT, ...
	'Position',DEFAULT_Message_POSITION, ...
	'Tag','samplerate',...
    'style','text',...
	'string','Waiting...',...
    'HorizontalAlignment','Center',...
    'FontSize',FONTSIZE,...
    'backgroundcolor',BACKCOLOR);



