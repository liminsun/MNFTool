function handles = InitControls(handles)  

            set(handles.view_data,'Enable','on');
            set(handles.bn_crtmnf,'Enable','on');

            set(handles.view_IC,'Enable','off');
            set(handles.bn_ReStruc,'Enable','off');
            set(handles.view_Construted,'Enable','off');
            
            set(handles.bn_xscale_inc,'Enable','on');
            set(handles.bn_xscale_dec,'Enable','on');
            set(handles.ed_v_xscale,'Enable','on','backgroundcolor','w');
            set(handles.bn_xskip,'Enable','on');
            set(handles.ed_v_xscale,'string',num2str(handles.xscale));

                        
            set(handles.bn_yscale_inc,'Enable','on');
            set(handles.bn_yscale_dec,'Enable','on');
            set(handles.ed_v_yscale,'Enable','on','backgroundcolor','w');
            set(handles.bn_yskip,'Enable','on');
            set(handles.ed_v_yscale,'string',num2str(handles.yscale));
            
            set(handles.bn_h_spacing_inc,'Enable','on');
            set(handles.bn_h_spacing_dec,'Enable','on');
            set(handles.bn_v_spacing_inc,'Enable','on');
            set(handles.bn_v_spacing_dec,'Enable','on');
            
            set(handles.bn_choose_channel,'Enable','on');
            set(handles.panel_mark_channel,'visible','on');
            set(handles.bn_choose_ICs,'Enable','off');
            set(handles.panel_mark_IC,'visible','off');
            set(handles.MNFTool,'name','MNF Tool : Raw Data');
            set(handles.color_c,'enable','on');

            %%% set the scroll condition
            r = handles.chans;
            Pages = floor(r/40);
            if Pages > 1
                handles.vscale = Pages;
                set(handles.panel2,'Position',[0 1-handles.vscale handles.hscale handles.vscale]);
                set(handles.s_v,'enable','on');
            else
                handles.vscale = 1;
                set(handles.panel2,'Position',[0 1-handles.vscale handles.hscale handles.vscale]);
                set(handles.s_v,'enable','off');

            end
                        
            Info = 'Please specify the unuseful channels before running MNF if existed.';
            set(handles.text_info,'string',Info);
            set(handles.bn_choose_channel,'value',1);
            set(handles.bn_choose_ICs,'Position',handles.bn_ICs_Position{2});
            
            set(handles.panel_mark_channel,'visible','on');
            %%%generate the number of channels 
            %%% create the controls.
            
            if isfield(handles,'tbn_chn')
                disp('exist old project. Clear it!');
                for i=1:length(handles.tbn_chn)
                    delete(handles.tbn_chn{i});
                end
                handles = rmfield(handles,'tbn_chn');
            end
            
            if isfield(handles,'tbn_ic')
                disp('exist old project. Clear it!');
                for i=1:length(handles.tbn_ic)
                    delete(handles.tbn_ic{i});
                end
                handles = rmfield(handles,'tbn_ic');
            end
            
            for i=1:r
                %%% channel button controls
                handles.tbn_chn{i} = uicontrol('Parent',handles.panel_mark_channel, ...
                        'Units', 'normalized', ...
                        'Tag',['tbn_channel' num2str(i)],...
                        'style','togglebutton',...
                        'string',num2str(i),...
                        'HorizontalAlignment','Center',...
                        'visible','off',...
                        'Fontsize',11,...
                        'callback',['MNFTool(''tbn_chan'',' num2str(i) ')']);
%                  %%% ic button controls
%                  handles.tbn_ic{i} = uicontrol('Parent',handles.panel_mark_IC, ...
%                         'Units', 'normalized', ...
%                         'Tag',['tbn_ic' num2str(i)],...
%                         'style','togglebutton',...
%                         'string',num2str(i),...
%                         'HorizontalAlignment','Center',...
%                         'visible','off',...
%                         'Fontsize',11,...
%                         'callback',['MNFTool(''tbn_ic'',' num2str(i) ')']);

            end
            
            %%%define the pages of channels
            handles.PagesOfChn = ceil(r/40);
            if handles.PagesOfChn > 1
                set(handles.bn_mark_channel_prev,'enable','off');
                set(handles.bn_mark_channel_next,'enable','on');
            end
            k=1;
            for h=1:handles.PagesOfChn
                for j=1:8
                    for i=1:5
                        handles.ChnPosition{k} = [(i-1)*0.2+0.01,(9-j)*0.1, 0.19 ,0.08];
                        k = k+1;
                        if k > r, break; end
                    end
                    if k > r, break; end
                end
                if k > r, break; end
            end
            
            %%%display the first page
            if handles.PagesOfChn > 1
                for i=1:40
                    set(handles.tbn_chn{i},'Position',handles.ChnPosition{i},'Visible','on');
                end
            else
                for i=1:r
                    set(handles.tbn_chn{i},'Position',handles.ChnPosition{i},'Visible','on');
                end
            end
            handles.CurrentPage = 1;
            handles.ICPosition = handles.ChnPosition;
            
            set(handles.bn_mark_channel_prev,'enable','off');
            handles.scrpages = 1;
            handles.curscrpg = 1;
            handles.InChn = [1:handles.chans];
            handles.z_chn = [];
            


            
            

            
            