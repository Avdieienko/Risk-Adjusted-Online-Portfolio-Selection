% Get all CSV files in the current folder
files = dir('*.csv');

for k = 1:length(files)
    % Read CSV into a table (keeps column names)
    T = readtable(files(k).name);

    % Create MAT filename with same base name
    [~, name, ~] = fileparts(files(k).name);
    matFile = [name '.mat'];

    % Save the entire table
    save(matFile, 'T');
end