%This fuction will generate a new TLE file for each experiment when
%provided the satellite IDs and a output filename

function stana_GenTle(SatIDs, inputFileName, outputFilename)
    fid = fopen(inputFileName, 'r');
    outputFid = fopen(outputFilename, 'w');
    
    while ~feof(fid)
        satelliteName = strtrim(fgetl(fid));
        if any(strcmp(satelliteName, SatIDs))
            % Save the sat name and TLE data
            fprintf(outputFid, '%s\n', satelliteName);
            for i = 1:2
                line = fgetl(fid);
                fprintf(outputFid, '%s\n', line);
            end
        else
            for i = 1:2 % Skip the next two lines for no match
                fgetl(fid);
            end
        end
    end
    fclose(fid);
    fclose(outputFid);
end