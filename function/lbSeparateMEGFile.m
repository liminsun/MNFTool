function MEG_fname = lbSeparateMEGFile(filename,nPage,PageSize,line_len,tmp)

%%% Open the raw MEG data
[tname,nam,ext] = fileparts(filename);
%%% separate MEG data
for i=1:nPage
    MEG_fname{i} = [tmp 't_' num2str(i) '_' nam ext];
end
SepFile(filename, MEG_fname, PageSize );
%%% Close the raw MEG data

return;