function data = loadMEGData(filename)

data = load(filename);
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
return;