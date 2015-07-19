function data = loadMEGPage(MEG_fname,Page)

disp(['Waiting for loading page...']);
data = load(MEG_fname{Page});
[r,c]=size(data);
if r > c
    data = data';
end
disp(['Load the data from Page ' num2str(Page)]);
return;