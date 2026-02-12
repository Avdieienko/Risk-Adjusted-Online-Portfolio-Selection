% Get all CSV files in the current folder
files = dir('*.csv');
for k = 1:length(files)
    % Read CSV into a table (keeps column names)
    T = readtable(files(k).name);
    
    % Keep only Date and Close_Last columns
    T = T(:, {'Date', 'Close_Last'});
    
    % Create MAT filename with same base name
    [~, name, ~] = fileparts(files(k).name);
    matFile = [name '.mat'];
    
    % Save the table with only selected columns
    save(matFile, 'T');
end