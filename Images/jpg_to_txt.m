close all; clear all;
filename = 'BOL_7458-640x480'; % image path/name
src = imread([filename, '.jpg']); % decompression
array = [];
for i = 1:size(src,1) % for each horizontal line
    disp(i);
    line = ['(']; 
    for j = 1:size(src,2) % for each pixel in the line
        R = double(src(i,j,1));
        G = double(src(i,j,2));
        B = double(src(i,j,3));
        nr = B/16; % trim to 4 most significant bits (first 4)
        %line = [line, 'X"', dec2hex(65536*R + 256*G + B, 6), '"']; % X"1A2B3C"
        %line = [line, 'X"', dec2hex(B, 2), '"']; % X"1A"
        line = [line, '"', dec2bin(nr, 4), '"']; % "0110" -- the 4 most significant bits of the 8
        if j<size(src,2)
            line = [line, ','];
        end
    end
    line = [line, '),'];
    if isempty(array)
        array = line;
    else
        array = [array; line];
    end
end
dlmwrite([filename, '.txt'], array,'delimiter',''); %save in .txt file