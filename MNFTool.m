function MNFTool(varargin)
%%% function: to show the original data, indenpendent components, and the
%%% reconstructed data.
%%% Date   : 06.02.2009
%%% Author : Limin Sun
%%% First Release Date : 17.02.2009

%%% Second version
%%% Add the scales of x,y axis
%%% varied scaling and spacing

%%% Second release date : 11.03.09

%%% Welcome to send any suggestion to sunlimin_98@yahoo.com
%%% tested in windows 2000 professional, matlab 7.1

%%% New version 2.0
%%% Date   : 29.08.09
%%% Author : Limin Sun
%%% The new version changes the user's interface completely. The EEG
%%% channels can be choosed if taking part in the calculation of MNF with
%%% the toggle buttons pressed or unpressed. The ICs are also choosed as
%%% artifacts by the pressed toggle buttons. 
%%% At the moment, the scale of x axis can be switched from samples to
%%% second each other. the scale of y axis can be 'uV' or others. 
%%% Note : I suggest you should exclude the zero value channels (Press the
%%% related toggle buttons).

%%% Third release Date : 10.09.09  

%%% New version 3.0 (additional function)  modified at 30.11.09
%%% Support the large block data processing.
%%% add the two button of page down and page up. The whole data are
%%% separated into different page. Each page is about 5000 samples
%%% (default). Save to one temporally directionary.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Support *.data format.
% % ############################################################
% % # The data file contains ASCII data with one line for each
% % # latency. The first column contains the latency in s, the
% % # following columns (channel groups) contain channel amplitudes.
% % ############################################################
% % CHANNEL GROUPS:
% % 274 channels
% % 248 MEG       channels, group 1
% %  23 REFERENCE channels, group 3
% %   2 TRIGGER   channels, group 6
% %   1 UTILITY   channels, group 7
% % ############################################################
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Fourth release Date : 13.12.09



if nargin > 0 
    cmd = varargin{1};
    fig = findobj('tag','F_MNF');
    if ~isempty(fig)
        handles = get(fig,'userdata');
    else
        return;
    end
    switch cmd
        case 'bn_load'
            %%Load data
            [handles] = LoadData(handles);
            if isempty(handles.X), disp('no data is loaded.'); return; end
            handles.tX = handles.X;
            %%% initialization of controls
            handles = InitControls(handles);       
            %%% call the gui of display
            handles.space_d = CalSpace(handles.X);
            handles.space = handles.space_d ;
            handles = InitWorkPlane(handles,handles.X); 
            handles = ChgColorLine(handles);
            if handles.PageMode
                PageInfo = [num2str(handles.CurPage)  ' Page / '  num2str(handles.nPage) ' Pages'];
                set(handles.text_page,'string', PageInfo);
                
                handles.Page{handles.CurPage}.space_d = handles.space;
            else
                set(handles.text_page,'string', '');
                set(handles.bn_pageprev,'enable','off');
                set(handles.bn_pagenext,'enable','off');
            end
        case 'bn_pagenext'

            handles.CurPage = handles.CurPage + 1;
            if handles.CurPage == 2
                set(handles.bn_pageprev,'enable','on');
            end
            if handles.CurPage > handles.nPage
                handles.CurPage = handles.nPage;
                set(handles.bn_pagenext,'enable','off');
            else

                handles = waitdlg(handles); %%% display the waiting GUI
                pause(0.5);
                
                handles.X = loadMEGPage(handles.MEG_fname,handles.CurPage);
                Info = 'Please specify the unuseful channels before running MNF if existed.';
                set(handles.text_info,'string',Info);
                set(handles.bn_choose_channel,'value',1);
                set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{2});
                set(handles.panel_mark_channel,'visible','on');
                set(handles.panel_mark_IC,'visible','off');
                
                %%%restore the reading page's channel mark
                if length(handles.Page{handles.CurPage}.chn_mark) > 0
                    for i = 1:length(handles.tbn_chn)
                        if find(i==handles.Page{handles.CurPage}.chn_mark)
                            set(handles.tbn_chn{i},'Value',1);
                        else
                            set(handles.tbn_chn{i},'Value',0);
                        end
                    end
                        
                end
                
                if handles.Page{handles.CurPage}.Proc == 0 
                    handles.space_d = CalSpace(handles.X);
                    handles.space = handles.space_d ;
                    handles.Page{handles.CurPage}.Proc = 1;
                    handles.Page{handles.CurPage}.space_d = handles.space;
                    set(handles.view_data,'Enable','on');
                    set(handles.bn_crtmnf,'Enable','on');
                    set(handles.view_IC,'Enable','off');
                    set(handles.bn_ReStruc,'Enable','off');
                    set(handles.view_Construted,'Enable','off');
                    
                else
                    handles.space = handles.Page{handles.CurPage}.space_d;
                    if handles.Page{handles.CurPage}.sflag == 1
                        %%% if the current page's data has been calculated
                        %%% by MNF, the handles.tS can be directly replaced.
                        handles.tS = loadMEGData(handles.Page{handles.CurPage}.sfile);
                        set(handles.view_IC,'Enable','on');
                        %%%restore the reading page's IC mark
                        if length(handles.Page{handles.CurPage}.ic_mark) > 0
                            for i = 1:length(handles.tbn_ic)
                                if find(i==handles.Page{handles.CurPage}.ic_mark)
                                    set(handles.tbn_ic{i},'Value',1);
                                else
                                    set(handles.tbn_ic{i},'Value',0);
                                end
                            end

                        end
                    else
                        set(handles.view_IC,'Enable','off');
                    end
                    if handles.Page{handles.CurPage}.rflag == 1
                        %%% directly load handles.IX from file. 
                        handles.IX = loadMEGData(handles.Page{handles.CurPage}.rfile);
                        set(handles.view_Construted,'Enable','on');
                    else
                        set(handles.view_Construted,'Enable','off');
                    end
                end
                
                handles.tX = handles.X;
                handles = RefreshWorkPlane(handles,handles.tX);
                       
                if handles.PageMode
                    PageInfo = [num2str(handles.CurPage)  ' Page / '  num2str(handles.nPage) ' Pages'];
                    set(handles.text_page,'string', PageInfo);
                end
                set(handles.MNFTool,'name','MNF Tool : Raw Data');
                
                %%%% close the waiting GUI
                close(handles.hwaitdlg);
            end

        case 'bn_pageprev'
            handles.CurPage = handles.CurPage - 1;
            if handles.CurPage < handles.nPage
                set(handles.bn_pagenext,'enable','on');
            end
            if handles.CurPage < 1
                handles.CurPage = 1;
                set(handles.bn_pageprev,'enable','off');
            else

                handles = waitdlg(handles); %%% display the waiting GUI
                pause(0.5);
                
                if handles.CurPage == 1
                    set(handles.bn_pageprev,'enable','off');
                end
                handles.X = loadMEGPage(handles.MEG_fname,handles.CurPage);
                
                Info = 'Please specify the unuseful channels before running MNF if existed.';
                set(handles.text_info,'string',Info);
                set(handles.bn_choose_channel,'value',1);
                set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{2});
                set(handles.panel_mark_channel,'visible','on');
                set(handles.panel_mark_IC,'visible','off');
                
                %%%restore the reading page's channel mark
                if length(handles.Page{handles.CurPage}.chn_mark) > 0
                    for i = 1:length(handles.tbn_chn)
                        if find(i==handles.Page{handles.CurPage}.chn_mark)
                            set(handles.tbn_chn{i},'Value',1);
                        else
                            set(handles.tbn_chn{i},'Value',0);
                        end
                    end
                end
                
                if handles.Page{handles.CurPage}.Proc == 0 
                    handles.Page{handles.CurPage}.Proc = 1;
                    handles.space_d = CalSpace(handles.X);
                    handles.space = handles.space_d ;
                    handles.Page{handles.CurPage}.space_d = handles.space;
                    set(handles.view_data,'Enable','on');
                    set(handles.bn_crtmnf,'Enable','on');
                    set(handles.view_IC,'Enable','off');
                    set(handles.bn_ReStruc,'Enable','off');
                    set(handles.view_Construted,'Enable','off');
                else
                    handles.space = handles.Page{handles.CurPage}.space_d;
                    if handles.Page{handles.CurPage}.sflag == 1
                        %%% if the current page's data has been calculated
                        %%% by MNF, the handles.tS can be directly replaced.
                        handles.tS = loadMEGData(handles.Page{handles.CurPage}.sfile);
                        set(handles.view_IC,'Enable','on');
                                               
                        %%%restore the reading page's IC mark
                        if length(handles.Page{handles.CurPage}.ic_mark) > 0
                            for i = 1:length(handles.tbn_ic)
                                if find(i==handles.Page{handles.CurPage}.ic_mark)
                                    set(handles.tbn_ic{i},'Value',1);
                                else
                                    set(handles.tbn_ic{i},'Value',0);
                                end
                            end
                        end
                        

                    else
                        set(handles.view_IC,'Enable','off');
                        
                    end
                    if handles.Page{handles.CurPage}.rflag == 1
                        %%% directly load handles.IX from file. 
                        handles.IX = loadMEGData(handles.Page{handles.CurPage}.rfile);
                        set(handles.view_Construted,'Enable','on');
                    else
                        set(handles.view_Construted,'Enable','off');
                    end
                end
            
                handles.tX = handles.X;
                handles = RefreshWorkPlane(handles,handles.tX);
                        
                if handles.PageMode
                    PageInfo = [num2str(handles.CurPage)  ' Page / '  num2str(handles.nPage) ' Pages'];
                    set(handles.text_page,'string', PageInfo);
                end
                set(handles.MNFTool,'name','MNF Tool : Raw Data');
                 %%%% close the waiting GUI
                close(handles.hwaitdlg);
            end
            
        case 'MNF'
            %%%test how many channels are zeros?
            %%% the zeros channels will not take part in the computation
            %%% whatever you choose or not.
            chans = size(handles.X,1);
            handles.z_chn = [];
            k = 1;
            for i=1:chans
                if isempty(find(handles.X(i,:) ~= 0))
                    handles.z_chn(k) = i;
                    k = k + 1;
                    handles.InChn = DelChn(handles.InChn,i);
                end
            end
            
            [S,handles.W]=lbBssMSF(handles.X(handles.InChn,:));  %%% S = W*X
            S = real(S);
            
            if length(handles.z_chn) > 0
                S = [zeros(length(handles.z_chn),size(S,2));S];
            end
            handles.S = S;
            handles.tS = S;
            
            handles.space_s = CalSpace(S);
            handles.space = handles.space_s ;
            handles = RefreshWorkPlane(handles,S);
            handles = ChgColorLine(handles);
            if handles.PageMode
                cfile = handles.MEG_fname{handles.CurPage};
                [cdir,nam,ext] = fileparts(cfile);
                save([cdir '\' nam '_IC'],'S');
                
                if handles.Page{handles.CurPage}.sflag == 0;
                    handles.Page{handles.CurPage}.sflag = 1;
                    handles.Page{handles.CurPage}.sfile = [cdir '\' nam '_IC'];
                    handles.Page{handles.CurPage}.space_s = handles.space;
                else
                    handles.Page{handles.CurPage}.space_s = handles.space;
                end
                
            else
                save([handles.dir handles.dataname '_IC'],'S');
            end
            handles.tX = S;
            
            set(handles.view_IC,'Enable','on');
            set(handles.bn_choose_ICs,'Enable','on');
            set(handles.MNFTool,'name','MNF Tool : Indenpendent Components');
                            
            set(handles.panel_mark_channel,'visible','off');
            set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{1});
            set(handles.panel_mark_IC,'visible','on');
            
            set(handles.bn_choose_channel,'value',0);
            set(handles.bn_choose_channel,'Enable','off');
            set(handles.panel_mark_channel,'visible','off');
            set(handles.bn_choose_ICs,'value',1);
            
            
            %%% create the IC toggle buttons
            if isfield(handles,'tbn_ic')
                disp('exist old project. Clear it!');
                for i=1:length(handles.tbn_ic)
                    delete(handles.tbn_ic{i});
                end
                handles = rmfield(handles,'tbn_ic');
            end
            
            r = size(S,1);
            for i=1:r
                handles.tbn_ic{i} = uicontrol('Parent',handles.panel_mark_IC, ...
                        'Units', 'normalized', ...
                        'Tag',['tbn_ic' num2str(i)],...
                        'style','togglebutton',...
                        'string',num2str(i),...
                        'HorizontalAlignment','Center',...
                        'visible','off',...
                        'Fontsize',11,...
                        'callback',['MNFTool(''tbn_ic'',' num2str(i) ')']);
                    
            end
%             
%             %%%define the pages of channels
%             handles.PagesOfIC = ceil(r/40);
%             if handles.PagesOfIC > 1
%                 set(handles.bn_mark_IC_prev,'enable','off');
%                 set(handles.bn_mark_IC_next,'enable','on');
%             end
%             k=1;
%             for h=1:handles.PagesOfIC
%                 for j=1:8
%                     for i=1:5
%                         handles.ICPosition{k} = [(i-1)*0.2+0.01,(9-j)*0.1, 0.19 ,0.08];
%                         k = k+1;
%                         if k > r, break; end
%                     end
%                     if k > r, break; end
%                 end
%                 if k > r, break; end
%             end
%             
%             r = size(S,1);
            handles.PagesOfIC = ceil(r/40);
            if handles.PagesOfIC > 1
                set(handles.bn_mark_IC_prev,'enable','off');
                set(handles.bn_mark_IC_next,'enable','on');
            end
            %%%display the first page
            if handles.PagesOfIC > 1
                for i=1:40
                    set(handles.tbn_ic{i},'Position',handles.ICPosition{i},'Visible','on');
                end
            else
                for i=1:r
                    set(handles.tbn_ic{i},'Position',handles.ICPosition{i},'Visible','on');
                end
            end
            handles.CurrentICPage = 1;
            
            Info = 'Please choose ICs as artifacts after MNF. Back to ''View Data'', you can specify channels again.';
            set(handles.text_info,'string',Info);

 
        case 'bn_ReStruc'
            if length(handles.z_chn) > 0
                %%extraxt the valid data of handles.tS
                handles.IX = inv(handles.W)*handles.tS(length(handles.z_chn)+1:end,:);
            else
                handles.IX = inv(handles.W)*handles.tS;
            end
            
%             X = handles.IX;
            X = handles.X;
            X(handles.InChn,:) = real(handles.IX);
            handles.space = handles.space_d ;
            handles = RefreshWorkPlane(handles,X);
            handles = ChgColorLine(handles);
            handles.tX = X;
            handles.IX = X;
            
            if handles.PageMode
                cfile = handles.MEG_fname{handles.CurPage};
                [cdir,nam,ext] = fileparts(cfile);
                save([cdir '\' nam '_X'],'X');
                if handles.Page{handles.CurPage}.rflag == 0;
                    handles.Page{handles.CurPage}.rflag = 1;
                    handles.Page{handles.CurPage}.rfile = [cdir '\' nam '_X'];
                    handles.Page{handles.CurPage}.space_d = handles.space;
                else
                    handles.Page{handles.CurPage}.space_d = handles.space;
                end
                
            else
                save([handles.dir handles.dataname '_X'],'X');
            end
            
            set(handles.bn_ReStruc,'Enable','off');
            set(handles.view_Construted,'Enable','on');
            
            set(handles.bn_choose_ICs,'Enable','off');
            set(handles.panel_mark_IC,'visible','off');

            set(handles.MNFTool,'name','MNF Tool : Reconstructed Data');

            Info = 'Back to ''View Independent Components'', you can reconstruct data again by choosing different ICs.';
            set(handles.text_info,'string',Info);

        case 'View'
            class = varargin{2};
            switch class
                case 'X'
                    handles.tX = handles.X;
                    handles.space = handles.space_d ;
                    set(handles.MNFTool,'name','MNF Tool : Raw Data');
                    set(handles.bn_choose_channel,'Enable','on');
                    set(handles.panel_mark_channel,'visible','on');

                    set(handles.bn_choose_ICs,'Enable','off');
                    set(handles.panel_mark_IC,'visible','off');

                    set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{2});
                    Info = '''View Data'': you can specify channels which are not calculated by MNF.';
                    set(handles.text_info,'string',Info);

                case 'S'
                    handles.tX = handles.tS;
                    handles.space = handles.space_s ;
                    set(handles.MNFTool,'name','MNF Tool : Indenpendent Components');
                    set(handles.bn_choose_channel,'Enable','off');
                    set(handles.panel_mark_channel,'visible','off');
                    set(handles.bn_choose_ICs,'Enable','on');
                    set(handles.panel_mark_IC,'visible','on');
                    set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{1});
                    Info = '''View Independent Components'': you can specify ICs as artifacts which will be set to zero.';
                    set(handles.text_info,'string',Info);

                case 'IX'
                    handles.tX = handles.IX;
                    handles.space = handles.space_d ;
                    set(handles.MNFTool,'name','MNF Tool : ReConstruct Data');
                    set(handles.panel_mark_channel,'visible','off');
                    set(handles.panel_mark_IC,'visible','off');
                    set(handles.bn_choose_ICs,'Enable','off');
                    set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{1});
                    Info = '''View Constructed Data'': The final result.';
                    set(handles.text_info,'string',Info);
                    
                otherwise
                    disp('no the matched class. exit');
                    return;
            end
            handles = RefreshWorkPlane(handles,handles.tX);
            handles = ChgColorLine(handles);    
        case 'bnColorSel'
            if handles.LineColor == 0
                handles.LineColor = 1;
                set(handles.color_c,'String','Mono- Color Lines');
            else
                handles.LineColor = 0;
                set(handles.color_c,'String','Multi- Color Lines');
            end
            handles = ChgColorLine(handles);
        case 'bn_yskip'
            handles.yscale = str2num(get(handles.ed_v_yscale,'string'));
            handles = RefreshSignal(handles,handles.tX);
            
            set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
           
        case 'bn_yscale_inc'
            %% increase y scale
            handles.pval = handles.pval *2;
            handles.space = handles.space * 2;
            handles.yscale = handles.yscale *2;
            
            handles = RefreshSignal(handles,handles.tX);
            
            set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
            set(handles.ed_v_yscale,'string',num2str(handles.yscale));

        case 'bn_yscale_dec'
            %% decrease y scale
            handles.pval = handles.pval /2;
            handles.space = handles.space / 2;
            handles.yscale = handles.yscale /2;

            handles = RefreshSignal(handles,handles.tX);

            set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
            set(handles.ed_v_yscale,'string',num2str(handles.yscale));
  
        case 'bn_xskip'
            handles.xscale = str2num(get(handles.ed_v_xscale,'string'));
            set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);

            if handles.xscaletype == 1
                bb = handles.hscale * handles.xscale / handles.xdiv;
                pp = get(handles.ax,'XLim');
            else
                %%% x scale -- second
                bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                pp = get(handles.ax,'XLim');
            end
            
            handles.scrpages = ceil(handles.scrpages*(pp(2)-pp(1)) / bb);
            handles.curscrpg = ceil(pp(1)/bb);
            if handles.curscrpg < 1
                handles.curscrpg = 1;
            end
            if handles.xscaletype == 1
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
            else
                %%% x scale -- second
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                                
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
            end
            if handles.curscrpg == 1
                set(handles.bn_next, 'enable','on');
                set(handles.bn_end,'enable','on');
                set(handles.bn_prev,'enable','off');
                set(handles.bn_begin,'enable','off');
            else
                if handles.curscrpg == handles.scrpages
                    set(handles.bn_next, 'enable','off');
                    set(handles.bn_end,'enable','off');
                    set(handles.bn_prev,'enable','on');
                    set(handles.bn_begin,'enable','on');
                else
                    set(handles.bn_next, 'enable','on');
                    set(handles.bn_end,'enable','on');
                    set(handles.bn_prev,'enable','on');
                    set(handles.bn_begin,'enable','on');
                end
            end
            
        case 'bn_xscale_inc'
            handles.xscale = handles.xscale * 2;
            handles.scrpages = handles.scrpages / 2;
             
            if handles.scrpages < 2
               set(handles.bn_begin,'enable','off');
               set(handles.bn_prev,'enable','off');
               set(handles.bn_next,'enable','off');
               set(handles.bn_end,'enable','off');
            end
            
            set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);
            set(handles.ed_v_xscale,'string',num2str(handles.xscale));
%             set(handles.ax,'XLim',[0 handles.xscale/handles.xdiv]);
            handles.curscrpg = ceil(handles.curscrpg/2);
            
            if handles.xscaletype == 1
                bb = handles.hscale * handles.xscale / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
            else
                %%% x scale -- second
                bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
%                 oXlim = get(handles.ax,'XLim');
%                 set(handles.ax,'XTick',[oXlim(1):handles.xscale*handles.fs:oXlim(2)],...
%                      'XTickLabel',[oXlim(1)/handles.fs:handles.xscale:oXlim(2)/handles.fs]);
            end
        case 'bn_xscale_dec'
            if handles.scrpages == 1
               set(handles.bn_next,'enable','on');
               set(handles.bn_end,'enable','on');
            end
           
            if handles.curscrpg == handles.scrpages
               set(handles.bn_next,'enable','on');
               set(handles.bn_end,'enable','on');
            end
           
            handles.xscale = handles.xscale / 2;
            handles.scrpages = handles.scrpages*2; 
            
            set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);
            set(handles.ed_v_xscale,'string',num2str(handles.xscale));
            handles.curscrpg = 2*handles.curscrpg - 1;

            if handles.xscaletype == 1
                bb = handles.hscale * handles.xscale / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
            else
                %%%x scale -- second 
                bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
%                 oticklabel = get(handles.ax,'XTick');
%                 set(handles.ax,'XTick',oticklabel,'XTickLabel', oticklabel ./ handles.fs );
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
            end
          
        case 'bn_begin'
            handles.curscrpg = 1;
            if handles.xscaletype == 1
                bb = handles.hscale * handles.xscale / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
            else
                %%%x scale -- second 
                bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
            end
            
            set(handles.bn_next, 'enable','on');
            set(handles.bn_end,'enable','on');
            set(handles.bn_prev,'enable','off');
            set(handles.bn_begin,'enable','off');

        case 'bn_prev'
            if handles.curscrpg == handles.scrpages
                set(handles.bn_next,'enable','on');
                set(handles.bn_end,'enable','on');
            end
            
            handles.curscrpg = handles.curscrpg - 1;
            if handles.curscrpg == 1
                if handles.xscaletype == 1
                    bb = handles.hscale * handles.xscale / handles.xdiv;
                    set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                else
                    %%%x scale -- second 
                    bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                    set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
%                     oXlim = get(handles.ax,'XLim');
%                     set(handles.ax,'XTick',[oXlim(1):handles.xscale*handles.fs:oXlim(2)],...
%                      'XTickLabel',[oXlim(1)/handles.fs:handles.xscale:oXlim(2)/handles.fs]);
                end
                set(handles.bn_prev, 'enable','off');
                set(handles.bn_begin,'enable','off');
            else
                if handles.curscrpg > 1
                    if handles.xscaletype == 1
                        bb = handles.hscale * handles.xscale / handles.xdiv;
                        set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                    else
                        bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                        set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
                    end
                else
                    handles.curscrpg = 1;
                end
            end
        case 'bn_next'
            if handles.curscrpg == 1
                set(handles.bn_prev,'enable','on');
                set(handles.bn_begin,'enable','on');
            end
                
            handles.curscrpg = handles.curscrpg + 1;
            if handles.curscrpg == handles.scrpages
                if handles.xscaletype == 1
                    bb = handles.hscale * handles.xscale / handles.xdiv;
                    set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                else
                    bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                    set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
                end
                set(handles.bn_next, 'enable','off');
                set(handles.bn_end,'enable','off');
            else
                if handles.curscrpg < handles.scrpages
                    if handles.xscaletype == 1
                        bb = handles.hscale * handles.xscale / handles.xdiv;
                        set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                    else
                        bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                        set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
                    end
                else
                    handles.curscrpg = handles.scrpages;
                end
            end
         
        case 'bn_end'
            handles.curscrpg = handles.scrpages;
            if handles.xscaletype == 1
                bb = handles.hscale * handles.xscale / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
            else
                bb = handles.hscale * handles.xscale*handles.fs / handles.xdiv;
                set(handles.ax,'XLim',[0+(handles.curscrpg-1)*bb bb+(handles.curscrpg-1)*bb]);
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                     'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
            end
            set(handles.bn_next, 'enable','off');
            set(handles.bn_end,'enable','off');
            set(handles.bn_prev,'enable','on');
            set(handles.bn_begin,'enable','on');
            

        case 'bn_h_spacing_inc'
            handles.hscale = handles.hscale * 2;
            if handles.hscale > 1, set(handles.s_h,'Enable','on'); end 
            handles.xscale = handles.xscale / 2;
                        
            set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);
            set(handles.ed_v_xscale,'string',num2str(handles.xscale));
            
            v_h = get(handles.s_h,'Value');
            v_v = get(handles.s_v,'Value');
            set(handles.panel2,'Position',[-v_h*(handles.hscale-1)  v_v*(1-handles.vscale)  handles.hscale handles.vscale]);
            
        case 'bn_h_spacing_dec'
            handles.hscale = handles.hscale / 2;
            if handles.hscale < 1, 
                handles.hscale = 1; 
                return;
            end
            if handles.hscale == 1
                set(handles.s_h,'Enable','off');
            end

            handles.xscale = handles.xscale * 2;
                        
            set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);
            set(handles.ed_v_xscale,'string',num2str(handles.xscale));

            v_h = get(handles.s_h,'Value');
            v_v = get(handles.s_v,'Value');
            set(handles.panel2,'Position',[-v_h*(handles.hscale-1)  v_v*(1-handles.vscale)  handles.hscale handles.vscale]);

        case 'bn_v_spacing_inc'
            handles.vscale = handles.vscale * 2;
            if handles.vscale > 1, set(handles.s_v,'Enable','on'); end 
            
            handles.yscale = handles.yscale /2;
                        
            set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
            set(handles.ed_v_yscale,'string',num2str(handles.yscale));

            v_h = get(handles.s_h,'Value');
            v_v = get(handles.s_v,'Value');
            set(handles.panel2,'Position',[-v_h*(handles.hscale-1)  v_v*(1-handles.vscale)  handles.hscale handles.vscale]);


        case 'bn_v_spacing_dec'
            handles.vscale = handles.vscale / 2;
            if handles.vscale < 1,
                handles.vscale = 1; 
                return;
            end
            if handles.vscale == 1
                set(handles.s_v,'Enable','off'); 
            end
            handles.yscale = handles.yscale * 2;
                        
            set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
            set(handles.ed_v_yscale,'string',num2str(handles.yscale));

            
            v_h = get(handles.s_h,'Value');
            v_v = get(handles.s_v,'Value');
            set(handles.panel2,'Position',[-v_h*(handles.hscale-1)  v_v*(1-handles.vscale)  handles.hscale handles.vscale]);

            
        case 'tbn_chan'
            NoChn = varargin{2};
            button_state = get(handles.tbn_chn{NoChn},'Value');
            if button_state == get(handles.tbn_chn{NoChn},'Max')
                set(handles.hline(handles.chans - NoChn + 1),'Color','r');                
                handles.InChn = DelChn(handles.InChn,NoChn);
                if handles.PageMode
                    handles.Page{handles.CurPage}.chn_mark = InsertChn(handles.Page{handles.CurPage}.chn_mark, NoChn);
                end
            elseif button_state == get(handles.tbn_chn{NoChn},'Min')
                set(handles.hline(handles.chans - NoChn + 1),'Color','b');
                handles.InChn = InsertChn(handles.InChn, NoChn);
                if handles.PageMode
                    handles.Page{handles.CurPage}.chn_mark = DelChn(handles.Page{handles.CurPage}.chn_mark,NoChn);
                end
            end
            
%         case 'bn_choose_channel'
%             button_state = get(handles.bn_choose_channel,'Value');
%             if button_state == get(handles.bn_choose_channel,'Max')
%                 set(handles.panel_mark_channel,'visible','on');
%                 set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{2});
%                 set(handles.panel_mark_IC,'visible','off');
%                 set(handles.bn_choose_ICs,'value',0);
%             elseif button_state == get(handles.bn_choose_channel,'Min')
%                 set(handles.panel_mark_channel,'visible','off');
%                 set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{1});
%                 set(handles.panel_mark_IC,'visible','on');
%                 set(handles.bn_choose_ICs,'value',1);
%             end
%             
%         case 'bn_choose_IC'
%             button_state = get(handles.bn_choose_ICs,'Value');
%             if button_state == get(handles.bn_choose_ICs,'Min')
%                 set(handles.panel_mark_channel,'visible','on');
%                 set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{2});
%                 set(handles.panel_mark_IC,'visible','off');
%                 set(handles.bn_choose_channel,'value',1);
%             elseif button_state == get(handles.bn_choose_ICs,'Max')
%                 set(handles.panel_mark_channel,'visible','off');
%                 set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{1});
%                 set(handles.panel_mark_IC,'visible','on');
%                 set(handles.bn_choose_channel,'value',0);
%             end
%             
            
        case 'bn_mark_channel_prev'
            handles.CurrentPage = handles.CurrentPage - 1;
            if handles.CurrentPage < 1
                handles.CurrentPage = 1;
            else
                set(handles.bn_mark_channel_next,'enable','on');
                step = (handles.CurrentPage - 1)*40;
                if handles.CurrentPage == 1
                    set(handles.bn_mark_channel_prev,'enable','off');
                end
                if handles.CurrentPage == handles.PagesOfChn -1
                    for i=1:length(handles.tbn_chn)- step-40 
                        set(handles.tbn_chn{step+40+i},'Position',handles.ChnPosition{step+40+i},'Visible','off');
                    end
                    for i=1:40
                        set(handles.tbn_chn{step+i},'Position',handles.ChnPosition{step+i},'Visible','on');
                    end
                    
                else
                    for i=1:40
                        set(handles.tbn_chn{step+40+i},'Position',handles.ChnPosition{step+40+i},'Visible','off');
                        set(handles.tbn_chn{step+i},'Position',handles.ChnPosition{step+i},'Visible','on');
                    end
                end
            end

        case 'bn_mark_channel_next'
            handles.CurrentPage = handles.CurrentPage + 1;
            if handles.CurrentPage > handles.PagesOfChn
                handles.CurrentPage = handles.PagesOfChn;
            else
                step = (handles.CurrentPage - 1)*40;
                set(handles.bn_mark_channel_prev,'enable','on');
                if handles.CurrentPage == handles.PagesOfChn
                    set(handles.bn_mark_channel_next,'enable','off');
                    for i=1:40
                    set(handles.tbn_chn{step-40+i},'Position',handles.ChnPosition{step-40+i},'Visible','off');
                    end
                    for i=1:length(handles.tbn_chn)-step
                    set(handles.tbn_chn{step+i},'Position',handles.ChnPosition{step+i},'Visible','on');
                    end
                else
                    for i=1:40
                    set(handles.tbn_chn{step-40+i},'Position',handles.ChnPosition{step-40+i},'Visible','off');
                    set(handles.tbn_chn{step+i},'Position',handles.ChnPosition{step+i},'Visible','on');
                    end
                end
            end
        case 'bn_mark_IC_prev'
            handles.CurrentICPage = handles.CurrentICPage - 1;
            if handles.CurrentICPage < 1
                handles.CurrentICPage = 1;
            else
                set(handles.bn_mark_IC_next,'enable','on');
                step = (handles.CurrentICPage - 1)*40;
                if handles.CurrentICPage == 1
                    set(handles.bn_mark_IC_prev,'enable','off');
                end
                if handles.CurrentICPage == handles.PagesOfIC -1
                    for i=1:length(handles.tbn_ic)- step-40 
                        set(handles.tbn_ic{step+40+i},'Position',handles.ICPosition{step+40+i},'Visible','off');
                    end
                    for i=1:40
                        set(handles.tbn_ic{step+i},'Position',handles.ICPosition{step+i},'Visible','on');
                    end
                    
                else
                    for i=1:40
                        set(handles.tbn_ic{step+40+i},'Position',handles.ICPosition{step+40+i},'Visible','off');
                        set(handles.tbn_ic{step+i},'Position',handles.ICPosition{step+i},'Visible','on');
                    end
                end
            end

        case 'bn_mark_IC_next'
            handles.CurrentICPage = handles.CurrentICPage + 1;
            if handles.CurrentICPage > handles.PagesOfIC
                handles.CurrentICPage = handles.PagesOfIC;
            else
                step = (handles.CurrentICPage - 1)*40;
                set(handles.bn_mark_IC_prev,'enable','on');
                if handles.CurrentICPage == handles.PagesOfIC
                    set(handles.bn_mark_IC_next,'enable','off');
                    for i=1:40
                    set(handles.tbn_ic{step-40+i},'Position',handles.ICPosition{step-40+i},'Visible','off');
                    end
                    for i=1:length(handles.tbn_ic)-step
                    set(handles.tbn_ic{step+i},'Position',handles.ICPosition{step+i},'Visible','on');
                    end
                else
                    for i=1:40
                    set(handles.tbn_ic{step-40+i},'Position',handles.ICPosition{step-40+i},'Visible','off');
                    set(handles.tbn_ic{step+i},'Position',handles.ICPosition{step+i},'Visible','on');
                    end
                end
            end
        case 'tbn_ic'
            NoIC = varargin{2};
            [chans,tslen] = size(handles.tS);
            button_state = get(handles.tbn_ic{NoIC},'Value');
            meandata = mean(handles.S(:,1:floor(end/20)),2); 
            if button_state == get(handles.tbn_ic{NoIC},'Max')
                %%set to zero
                handles.tS(NoIC,:) = zeros(1,tslen);
                tt = zeros(1,tslen) + handles.S(NoIC,1)  - meandata(NoIC,1) + (chans-NoIC+1)*handles.space; 
                set(handles.hline(chans - NoIC + 1),'Color','r','YData',tt);   
                if handles.PageMode
                    %% if there are many pages, the current page's choosed
                    %% ICs are recorded into handles.Page{i}.ic_mark 
                    handles.Page{handles.CurPage}.ic_mark = InsertChn(handles.Page{handles.CurPage}.ic_mark, NoIC);
                end
            elseif button_state == get(handles.tbn_ic{NoIC},'Min')
                %%restore data
                handles.tS(NoIC,:) = handles.S(NoIC,:);
                tt = handles.S(NoIC,:)- meandata(NoIC,1) + (chans-NoIC+1)*handles.space;
                set(handles.hline(chans - NoIC + 1),'Color','b','YData',tt);        
                if handles.PageMode
                    handles.Page{handles.CurPage}.ic_mark = DelChn(handles.Page{handles.CurPage}.ic_mark, NoIC);
                end
            end
            set(handles.bn_ReStruc,'enable','on');

        case 'bnSet'
            handles.fs= str2num(get(handles.ed_samplerate,'string'));
           
            items = get(handles.ed_xaxis,'string');
            n = get(handles.ed_xaxis,'value');
            if n == handles.xscaletype
                return;
            end
            if n == 2
                 if isempty(handles.fs)
                     warndlg('Please fill the sample rate.');
                     return;
                 end
                 handles.xscaletype = 2;
                 %%% samples to second
                 handles.xscale = handles.xscale / handles.fs;
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                             'XTickLabel',[oXlim(1)/handles.fs:step/handles.fs:oXlim(2)/handles.fs]);
         
%                  oXlim = get(handles.ax,'XLim');
%                  set(handles.ax,'XTick',[oXlim(1):handles.xscale*handles.fs:oXlim(2)],...
%                      'XTickLabel',[oXlim(1)/handles.fs:handles.xscale:oXlim(2)/handles.fs]);
                 set(get(handles.ax,'xlabel'),'string','Time [second]');
            else
                 handles.xscaletype = 1;
                  %%% second to samples
                 handles.xscale = handles.xscale*handles.fs;
                oXlim = get(handles.ax,'XLim');
                step = (oXlim(2)-oXlim(1))/5;
                set(handles.ax,'XTick',[oXlim(1):step:oXlim(2)],...
                    'XTickLabel',[oXlim(1):step:oXlim(2)]);

                 set(get(handles.ax,'xlabel'),'string','Sampels');
            end
            handles.x_label= items{n};
            handles.y_label=get(handles.ed_yaxis,'string');
            set(handles.xscale_label, 'String',[ num2str(handles.xscale) ' ' handles.x_label]);
            set(handles.ed_v_xscale,'string',num2str(handles.xscale));

            set(handles.yscale_label, 'String',[ num2str(handles.yscale) ' ' handles.y_label]);
        case 'bn_exit'
             close(fig);
        otherwise
            disp('operation error. exit');
            return;
    end
    set(fig,'userdata',handles);    
else

    InitGUIMNF;

end
%%% event driver function %%%
function slider_callback(src,eventdata,fig)
handles = get(fig,'userdata');
v_h = get(handles.s_h,'Value');
v_v = get(handles.s_v,'Value');
set(handles.panel2,'Position',[-v_h*(handles.hscale-1)  v_v*(1-handles.vscale)  handles.hscale handles.vscale]);
return;

function handles = RefreshSignal(handles,X)

DrawMode = 0;
[r,c] = size(X);

if r > c
   DrawMode = 1;
   handles.chans = c;
else
   handles.chans = r;
end
% row = size(X,1);
set(handles.ax,'YLim',[0 handles.pval]);
for i=1:handles.chans
    YLabels(i,:) = sprintf('%6d',i);
end
YLabels = flipud(str2mat(YLabels,' '));
set(handles.ax,'YTick',[0:handles.space:handles.chans*handles.space],'YTickLabel', YLabels);

% meandata = mean(X(:,1:floor(end/20)),2); 
if DrawMode
    meandata = mean(X(1:floor(end/20),:),1); 
else
    meandata = mean(X(:,1:floor(end/20)),2); 
end

for i = 1:handles.chans
    if DrawMode
        TMP = X(:,handles.chans-i+1) - meandata(1,handles.chans-i+1) + i*handles.space;
   else
        TMP = X(handles.chans-i+1,:) - meandata(handles.chans-i+1,1) + i*handles.space;
   end
%     TMP = X(handles.chans-i+1,:) - meandata(handles.chans-i+1,1) + i*handles.space;
    set(handles.hline(i),'YData',TMP);
end

% handles.yscale = handles.pval * handles.ydiv;
handles = ChgColorLine(handles);

return;










