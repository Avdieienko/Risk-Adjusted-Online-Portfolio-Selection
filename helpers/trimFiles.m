function trimmedFiles = trimFiles(files, targetSize)
%TRIMFILES Trim preloaded MAT-table files to a fixed number of rows.
% trimmedFiles = trimFiles(files, targetSize)
%
% Inputs:
%   files          - file list returned by load_files(...)
%   targetSize     - desired maximum number of rows (e.g. 100)
%
% Output:
%   trimmedFiles   - 1xN cell array of file paths that were trimmed

    if nargin < 1 || isempty(files)
        error('files is required (pass output of load_files).');
    end
    if nargin < 2 || isempty(targetSize)
        error('targetSize is required.');
    end
    if ~isscalar(targetSize) || targetSize < 1 || targetSize ~= floor(targetSize)
        error('targetSize must be a positive integer scalar.');
    end

    if isstring(files)
        files = cellstr(files(:))';
    elseif iscell(files)
        files = cellfun(@char, files(:)', 'UniformOutput', false);
    else
        error('files must be a cell/string list from load_files.');
    end

    trimmedFiles = {};
    for k = 1:numel(files)
        filePath = files{k};
        if ~isfile(filePath)
            warning('Skipping missing file %s.', filePath);
            continue;
        end

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

        T = S.(varName);
        if ~istable(T)
            warning('Skipping %s (%s is not a table).', filePath, varName);
            continue;
        end

        nRows = height(T);
        if nRows <= targetSize
            continue;
        end

        T = T(1:targetSize, :);

        S.(varName) = T;
        save(filePath, '-struct', 'S');
        trimmedFiles{end+1} = filePath; %#ok<AGROW>
        fprintf('Trimmed %s to %d rows.\n', filePath, targetSize);
    end

    fprintf('Finished trimming %d MAT file(s).\n', numel(trimmedFiles));
end
