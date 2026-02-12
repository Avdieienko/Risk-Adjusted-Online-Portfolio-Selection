% Get all MAT files in the current folder
files = dir('*.mat');

for k = 1:length(files)
    % Load the MAT file
    load(files(k).name);
    
    % Flip the table so oldest dates are first
    T = flipud(T);
    
    % Save the flipped table back to the same MAT file
    save(files(k).name, 'T');
    
    fprintf('Flipped %s\n', files(k).name);
end

disp('All MAT files have been flipped to chronological order.');