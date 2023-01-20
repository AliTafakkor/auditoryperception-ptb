function generatePRTfiles(exp, D, filename)
% generate PRT File


condColor = ...
   {[255 16 0],
    [204 102 0],
    [255 255 0],
    [102 204 0],
    [51 204 204],
    [145 43 128]};
TRdur         = 1;


% open file
fid = fopen(filename, 'w');


% header information
fprintf(fid,'\n');
fprintf(fid,'FileVersion:        1\n');
fprintf(fid,'ResolutionOfTime:   Volumes\n');
fprintf(fid,'Experiment:         %s\n', exp.name);
fprintf(fid,'BackgroundColor:    0 0 0\n');
fprintf(fid,'TextColor:          255 255 255\n');
fprintf(fid,'TimeCourseColor:    255 255 255\n');
fprintf(fid,'TimeCourseThick:    3\n');
fprintf(fid,'ReferenceFuncColor: 0 0 80\n');
fprintf(fid,'ReferenceFuncThick: 3\n');
fprintf(fid,'NrOfConditions:     %d\n',exp.numConds);
fprintf(fid,'\n');

% condition information
for thisCond = 1:exp.numConds

    % condition name
    fprintf(fid, '%s\n', exp.condLabel{thisCond});

    % number of events
    fprintf(fid, '%d\n', sum(exp.blockOrder==thisCond));

    % onsets and offsets in TRs
    onsets = exp.blockStartTime(exp.blockOrder==thisCond)/TRdur + 1;
    offsets = exp.blockEndTime(exp.blockOrder==thisCond)/TRdur; % don't add 1 for prt file! + 1;
    for thisTR = 1:length(onsets)
        fprintf(fid, '  %2.0f %2.0f\n', onsets(thisTR), offsets(thisTR));
    end;

    % color
    fprintf(fid,'Color: %d %d %d\n\n', condColor{thisCond});

end;
fclose(fid);
