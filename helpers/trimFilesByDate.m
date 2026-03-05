function trimmedFiles = trimFilesByDate(files, startDate, endDate)
%TRIMFILESBYDATE Trim preloaded MAT-table files to an inclusive date range.
% trimmedFiles = trimFilesByDate(files, startDate, endDate)
%
% Inputs:
%   files          - file list returned by load_files(...)
%   startDate      - lower date bound (datetime or date string)
%   endDate        - upper date bound (datetime or date string)
%
% Output:
%   trimmedFiles   - 1xN cell array of file paths retained after filtering.
%                    Returned files are all trimmed to the SAME effective
%                    date range, i.e. the overlap across all files within
%                    [startDate, endDate].

    if nargin < 1 || isempty(files)
        error('files is required (pass output of load_files).');
    end
    if nargin < 2 || isempty(startDate)
        error('startDate is required.');
    end
    if nargin < 3 || isempty(endDate)
        error('endDate is required.');
    end

    requestedStart = parseScalarDate(startDate, 'startDate');
    requestedEnd = parseScalarDate(endDate, 'endDate');
    if requestedStart > requestedEnd
        error('startDate must be earlier than or equal to endDate.');
    end
    requestedStartText = char(string(requestedStart, 'yyyy-MM-dd'));
    requestedEndText = char(string(requestedEnd, 'yyyy-MM-dd'));

    if isstring(files)
        files = cellstr(files(:))';
    elseif iscell(files)
        files = cellfun(@char, files(:)', 'UniformOutput', false);
    else
        error('files must be a cell/string list from load_files.');
    end
    if isempty(files)
        error('files must be non-empty.');
    end

    nFiles = numel(files);
    fileMins = NaT(1, nFiles);
    fileMaxs = NaT(1, nFiles);
    keptFiles = cell(1, nFiles);

    % First pass: validate and collect each file's full date span.
    for k = 1:nFiles
        filePath = files{k};
        keptFiles{k} = filePath;
        if ~isfile(filePath)
            error('Missing file %s.', filePath);
        end

        S = load(filePath);
        fieldNames = fieldnames(S);
        if isempty(fieldNames)
            error('File %s has no variables.', filePath);
        end

        % Prefer variable T, otherwise use the only variable if unique.
        if isfield(S, 'T')
            varName = 'T';
        elseif isscalar(fieldNames)
            varName = fieldNames{1};
        else
            error('File %s has multiple variables and no T table.', filePath);
        end

        T = S.(varName);
        if ~istable(T)
            error('File %s (%s) is not a table.', filePath, varName);
        end

        if ~ismember('Date', T.Properties.VariableNames)
            error('File %s (%s) has no Date column.', filePath, varName);
        end

        try
            d = parseDateColumn(T.Date, filePath);
        catch ME
            error('%s', ME.message);
        end
        d = dateshift(d, 'start', 'day');
        fileMins(k) = min(d);
        fileMaxs(k) = max(d);
    end

    commonStart = max(fileMins);
    commonEnd = min(fileMaxs);

    effectiveStart = max(requestedStart, commonStart);
    effectiveEnd = min(requestedEnd, commonEnd);

    if effectiveStart > effectiveEnd
        commonStartText = char(string(commonStart, 'yyyy-MM-dd'));
        commonEndText = char(string(commonEnd, 'yyyy-MM-dd'));
        perFile = strings(nFiles, 1);
        for k = 1:nFiles
            perFile(k) = sprintf('%s: %s to %s', ...
                files{k}, ...
                char(string(fileMins(k), 'yyyy-MM-dd')), ...
                char(string(fileMaxs(k), 'yyyy-MM-dd')));
        end

        error(['No overlapping date range exists across all files within requested bounds.', newline, ...
            'Requested: %s to %s', newline, ...
            'Common overlap across files: %s to %s', newline, ...
            'Per-file ranges:', newline, ...
            '%s'], ...
            requestedStartText, requestedEndText, ...
            commonStartText, commonEndText, ...
            strjoin(cellstr(perFile), newline));
    end

    effectiveStartText = char(string(effectiveStart, 'yyyy-MM-dd'));
    effectiveEndText = char(string(effectiveEnd, 'yyyy-MM-dd'));

    % Second pass: apply the same effective range to every file.
    nTrimmed = 0;
    for k = 1:nFiles
        filePath = keptFiles{k};

        S = load(filePath);
        fieldNames = fieldnames(S);
        if isfield(S, 'T')
            varName = 'T';
        else
            varName = fieldNames{1};
        end

        T = S.(varName);
        d = dateshift(parseDateColumn(T.Date, filePath), 'start', 'day');
        keepMask = d >= effectiveStart & d <= effectiveEnd;

        if ~all(keepMask)
            T = T(keepMask, :);
            S.(varName) = T;
            save(filePath, '-struct', 'S');
            nTrimmed = nTrimmed + 1;
            fprintf('Trimmed %s to %d rows for date range %s to %s.\n', ...
                filePath, height(T), effectiveStartText, effectiveEndText);
        end
    end

    trimmedFiles = keptFiles;
    fprintf('Finished date-range filtering: kept %d/%d file(s), trimmed %d. Effective range %s to %s.\n', ...
        nFiles, nFiles, nTrimmed, effectiveStartText, effectiveEndText);
end

function d = parseScalarDate(value, argName)
    try
        if isdatetime(value)
            d = value;
        else
            d = datetime(value, 'InputFormat', 'MM/dd/yyyy');
            if isnat(d)
                d = datetime(value);
            end
        end
    catch
        error('%s must be a valid date value.', argName);
    end

    if ~isscalar(d) || isnat(d)
        error('%s must be a valid scalar date.', argName);
    end

    d = dateshift(d, 'start', 'day');
end

function d = parseDateColumn(rawDate, filePath)
    try
        if isdatetime(rawDate)
            d = rawDate;
        elseif iscategorical(rawDate)
            d = datetime(string(rawDate), 'InputFormat', 'MM/dd/yyyy');
            natMask = isnat(d);
            if any(natMask)
                d(natMask) = datetime(string(rawDate(natMask)));
            end
        elseif iscell(rawDate) || isstring(rawDate) || ischar(rawDate)
            d = datetime(rawDate, 'InputFormat', 'MM/dd/yyyy');
            natMask = isnat(d);
            if any(natMask)
                d(natMask) = datetime(string(rawDate(natMask)));
            end
        elseif isnumeric(rawDate)
            d = datetime(rawDate, 'ConvertFrom', 'datenum');
        else
            error('Unsupported date type in Date column.');
        end
    catch
        error('Failed to parse Date column in file %s.', filePath);
    end

    if numel(d) ~= numel(rawDate)
        d = d(:);
    end

    if any(isnat(d))
        error('Date column in file %s contains invalid date values.', filePath);
    end

    d = d(:);
end
