function par = read_optseq_paradigm(file)
%Read contents of optseq paradigm file
%Dimitrios Pantazis, August 2017

fileID = fopen(file,'r');

line = 1;
while ~feof(fileID) %while not end of file
    str = fgets(fileID); %read one line
    dat = sscanf(str,'%f %f %f %f %s'); %parse data
    par.time(line) = dat(1);
    par.eventID(line) = dat(2);
    par.eventduration(line) = dat(3);
    par.eventcontrast(line) = dat(4);
    par.eventlabel{line} = char(dat(5:end))';
    line = line + 1;
end

par.ntp = length(par.time);
fclose(fileID);
