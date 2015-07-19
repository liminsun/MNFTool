% function [nPage,line_len,samples] = lbGetParaFromMEGFile(filename, block)
function [samples, line_len, chn] = lbGetParaFromMEGFile(filename)

machineformat = 'ieee-le';
fid = fopen(filename,'rt',machineformat);

fseek(fid, 0 , 'bof');
FirstPosition = ftell(fid);
str = fgets(fid); 
SecondPosition = ftell(fid);

line_len = length(str);
chn = length(str2num(str));

OneSample = SecondPosition - FirstPosition;
fseek(fid, 0 , 'eof');
LastPosition = ftell(fid);
samples = (LastPosition - FirstPosition)/OneSample;
% nPage = ceil((LastPosition - FirstPosition)/(block*OneSample));

fclose(fid);
return;