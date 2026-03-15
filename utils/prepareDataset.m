function varargout = prepareDataset(dataDir, assets, startDate, endDate)
%PREPAREDATASET Preload asset series into a map keyed by asset name.
% dataset = prepareDataset(dataDir)
% dataset = prepareDataset(dataDir, assets)
% [R, dates, P] = prepareDataset(dataDir, assets, startDate, endDate)
% [dataset, R, dates, P] = prepareDataset(dataDir, assets, startDate, endDate)
%
% Output:
%   dataset(assetName) -> struct with fields:
%       asset         - uppercase asset name
%       dates         - full ascending datetime vector
%       P             - full close-price vector
%       R             - full price-relative vector
%       relativeDates - dates corresponding to R
%       filePath      - source MAT file path

    if nargin < 2
        assets = [];
    end

    dataset = preloadDatasetMap(dataDir, assets);

    if nargout <= 1
        varargout = {dataset};
        return;
    end

    if nargin < 4
        error(['prepareDataset returns the preload map by default.', newline, ...
            'For trimmed/aligned outputs either call prepareTrimmedDataset(dataset, assets, startDate, endDate) ', ...
            'or pass assets, startDate, and endDate here.']);
    end

    [~, R, dates, P] = prepareTrimmedDataset(dataset, assets, startDate, endDate);

    switch nargout
        case 3
            varargout = {R, dates, P};
        case 4
            varargout = {dataset, R, dates, P};
        otherwise
            error('prepareDataset returns either dataset, [R, dates, P], or [dataset, R, dates, P].');
    end
end

function dataset = preloadDatasetMap(dataDir, assets)
    if nargin < 1 || isempty(dataDir)
        error('dataDir is required.');
    end

    if nargin < 2
        files = load_files(dataDir);
    else
        files = load_files(dataDir, assets);
    end

    if isempty(files)
        error('No MAT files found in %s.', dataDir);
    end

    dataset = containers.Map('KeyType', 'char', 'ValueType', 'any');

    for k = 1:numel(files)
        filePath = files{k};
        [~, assetName, ~] = fileparts(filePath);
        assetName = upper(assetName);

        T = loadAssetTable(filePath);
        [dates, prices] = normalizeSeries(T, filePath);

        if numel(prices) < 2
            error('Asset %s must have at least two price rows.', assetName);
        end

        R = prices(2:end) ./ prices(1:end-1);
        if any(~isfinite(R)) || any(R <= 0)
            error('Asset %s produced invalid price relatives.', assetName);
        end

        dataset(assetName) = struct( ...
            'asset', assetName, ...
            'dates', dates, ...
            'P', prices, ...
            'R', R, ...
            'relativeDates', dates(2:end), ...
            'filePath', filePath);
    end
end

function T = loadAssetTable(filePath)
    S = load(filePath);
    fieldNames = fieldnames(S);

    if isempty(fieldNames)
        error('File %s has no variables.', filePath);
    end

    if isfield(S, 'T')
        varName = 'T';
    elseif numel(fieldNames) == 1
        varName = fieldNames{1};
    else
        error('File %s has multiple variables and no T table.', filePath);
    end

    T = S.(varName);
    if ~istable(T)
        error('File %s (%s) is not a table.', filePath, varName);
    end

    if ~all(ismember({'Date', 'Close_Last'}, T.Properties.VariableNames))
        error('File %s (%s) must contain Date and Close_Last.', filePath, varName);
    end
end

function [dates, prices] = normalizeSeries(T, filePath)
    dates = parseDateColumn(T.Date, filePath);
    prices = T.Close_Last;

    if ~isnumeric(prices)
        error('File %s has a non-numeric Close_Last column.', filePath);
    end

    dates = dateshift(dates(:), 'start', 'day');
    prices = prices(:);

    [dates, order] = sort(dates);
    prices = prices(order);

    if numel(unique(dates)) ~= numel(dates)
        error('File %s contains duplicate dates.', filePath);
    end

    if any(~isfinite(prices)) || any(prices <= 0)
        error('File %s contains invalid Close_Last values.', filePath);
    end
end

function dates = parseDateColumn(rawDate, filePath)
    try
        if isdatetime(rawDate)
            dates = rawDate;
        elseif iscategorical(rawDate)
            dates = datetime(string(rawDate), 'InputFormat', 'MM/dd/yyyy');
            natMask = isnat(dates);
            if any(natMask)
                dates(natMask) = datetime(string(rawDate(natMask)));
            end
        elseif iscell(rawDate) || isstring(rawDate) || ischar(rawDate)
            dates = datetime(rawDate, 'InputFormat', 'MM/dd/yyyy');
            natMask = isnat(dates);
            if any(natMask)
                dates(natMask) = datetime(string(rawDate(natMask)));
            end
        elseif isnumeric(rawDate)
            dates = datetime(rawDate, 'ConvertFrom', 'datenum');
        else
            error('Unsupported date type in Date column.');
        end
    catch
        error('Failed to parse Date column in file %s.', filePath);
    end

    if any(isnat(dates))
        error('Date column in file %s contains invalid date values.', filePath);
    end
end
