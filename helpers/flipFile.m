function flippedFiles = flipFile(folder_path, assets)
%FLIPFILE Flip selected MAT-table files to chronological order.
% flippedFiles = flipFile(folder_path)
% flippedFiles = flipFile(folder_path, assets)
%
% Inputs:
%   folder_path - folder containing .mat files
%   assets      - optional asset list, same filtering behavior as load_files
%
% Output:
%   flippedFiles - 1xN cell array of file paths that were flipped

    if nargin < 1 || isempty(folder_path)
        error('folder_path is required.');
    end

    if nargin < 2
        files = load_files(folder_path);
    else
        files = load_files(folder_path, assets);
    end

    flippedFiles = {};

    for k = 1:numel(files)
        filePath = files{k};
        S = load(filePath);
        fieldNames = fieldnames(S);

        if isempty(fieldNames)
            warning('Skipping %s (no variables found).', filePath);
            continue;
        end

        % Prefer variable T, otherwise use the only variable if unique.
        if isfield(S, 'T')
            varName = 'T';
        elseif numel(fieldNames) == 1
            varName = fieldNames{1};
        else
            warning('Skipping %s (multiple variables, no T found).', filePath);
            continue;
        end

        if ~istable(S.(varName))
            warning('Skipping %s (%s is not a table).', filePath, varName);
            continue;
        end

        S.(varName) = flipud(S.(varName));
        save(filePath, '-struct', 'S');
        flippedFiles{end+1} = filePath; %#ok<AGROW>

        fprintf('Flipped %s\n', filePath);
    end

    fprintf('Finished flipping %d MAT file(s).\n', numel(flippedFiles));
end

