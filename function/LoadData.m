function [handles] = LoadData(handles)

r_path =  which('MNFTool.m');
[r_path,nam,ext] = fileparts(r_path);
           
[inputname, inputpath] = uigetfile({'*.mat';'*.data'}, 'Load data', [r_path  '\data\']);
if inputname == 0, handles.X = []; return; end;

% handles.dir = inputpath;
[tname,nam,ext] = fileparts(inputname);
dataname = nam;

if strcmp(ext,'.data')
    %%% processing data as the huge block data
    %%% Counting the pages of the whole data set
    %%% The *.data is the format of MEG. The detail is described in the
    %%% *.hdr.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% The whole data are separated several smaller files which are saved
    %%% to the temporal directionary ..\tmpfilename with t_n_filename.data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% build the temporal dir
    TMP = [inputpath 'tmp' nam '\'];
    if exist(TMP,'dir') ~= 7
        mkdir(TMP);
    end
%     [handles.nPage,line_len,samples] = lbGetParaFromMEGFile([inputpath inputname],handles.PageSize);

    handles.PageMode = 0;
    [handles.fulsamples, line_len handles.chans]= lbGetParaFromMEGFile([inputpath inputname]);
    handles.PageSize = 5000; 
    handles.nPage = ceil(handles.fulsamples/handles.PageSize);
      
    [handles.PageSize,handles.nPage] = separatedlg(handles.fulsamples,handles.chans,handles.PageSize);
    
    if handles.nPage < 2
        data = load([inputpath inputname]);
    else
        handles.MEG_fname = lbSeparateMEGFile([inputpath inputname], handles.nPage, handles.PageSize, line_len, TMP);
        data = loadMEGPage(handles.MEG_fname,1);
        set(handles.bn_pagenext, 'enable','on');
        handles.CurPage = 1;
        handles.PageMode = 1;
        
        for i=1:handles.nPage
            handles.Page{i}.Proc = 0;
            handles.Page{i}.space_d = 0;
            handles.Page{i}.space_s = 0;
            handles.Page{i}.sflag = 0;
            handles.Page{i}.rflag = 0;
            handles.Page{i}.xfile = handles.MEG_fname{i};
            handles.Page{i}.sfile = '';
            handles.Page{i}.rfile = '';
            handles.Page{i}.chn_mark = [];
            handles.Page{i}.ic_mark =[];
        end
        
        handles.Page{1}.Proc = 1;
        handles.Page{1}.space_d = 0;
        handles.Page{1}.space_s = 0;
        handles.Page{1}.sflag = 0;
        handles.Page{1}.rflag = 0;
        handles.Page{1}.sfile = '';
        handles.Page{1}.rfile = '';
        
    end
    
else
    handles.PageMode = 0;
    data = load([inputpath inputname]); 
    if isstruct(data)
        names =  fieldnames(data);
        if length(names) > 1
            disp('more struct''s field. Please check it. The field should be one.');
            return;
        else
            data = getfield(data,names{1});
        end
    else    
        [r,c]=size(data);
        if  r< 1 || c < 1, disp('Please check the input data. Format error!'); return; end
    end
end

[r,c]=size(data);
if r > c
    handles.chans = c;
    data = data';
else
    handles.chans = r;
end

handles.dir = inputpath;
handles.dataname = dataname;
handles.X = data;

disp('Load Data ... Ok!');
return;