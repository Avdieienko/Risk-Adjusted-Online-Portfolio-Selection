function [trimmedDataset, R, dates, P] = prepareTrimmedDataset(dataset, assets, startDate, endDate)
%PREPARETRIMMEDDATASET Build a date-trimmed aligned dataset from a preload map.
% [trimmedDataset, R, dates, P] = prepareTrimmedDataset(dataset, assets, startDate, endDate)
%
% Inputs:
%   dataset - map returned by prepareDataset
%   assets  - asset names to align and trim
%   startDate, endDate - inclusive requested bounds
%
% Outputs:
%   trimmedDataset(assetName) -> struct with aligned dates/P/R for each asset
%   R     - aligned price-relative matrix for the selected assets
%   dates - aligned price dates
%   P     - aligned close-price matrix for the selected assets

    if nargin < 1 || isempty(dataset)
        error('dataset is required.');
    end
    if ~isa(dataset, 'containers.Map')
        error('dataset must be the map returned by prepareDataset.');
    end
    if nargin < 2 || isempty(assets)
        assets = sort(string(keys(dataset)));
    else
        assets = upper(string(assets(:))');
    end
    if nargin < 3 || isempty(startDate)
        error('startDate is required.');
    end
    if nargin < 4 || isempty(endDate)
        error('endDate is required.');
    end

    requestedStart = parseScalarDate(startDate, 'startDate');
    requestedEnd = parseScalarDate(endDate, 'endDate');
    if requestedStart > requestedEnd
        error('startDate must be earlier than or equal to endDate.');
    end

    nAssets = numel(assets);
    if nAssets == 0
        error('assets must be non-empty.');
    end

    tt = cell(1, nAssets);
    boundedStarts = NaT(1, nAssets);
    boundedEnds = NaT(1, nAssets);
    perAssetRanges = strings(nAssets, 1);

    availableKeys = sort(string(keys(dataset)));

    for k = 1:nAssets
        assetName = char(assets(k));
        if ~isKey(dataset, assetName)
            error('Asset %s is not preloaded. Available assets: %s', ...
                assetName, strjoin(cellstr(availableKeys), ', '));
        end

        assetData = dataset(assetName);
        assetDates = dateshift(assetData.dates(:), 'start', 'day');
        assetPrices = assetData.P(:);

        inBounds = assetDates >= requestedStart & assetDates <= requestedEnd;
        if ~any(inBounds)
            perAssetRanges(k) = sprintf('%s: no data inside %s to %s', ...
                assetName, ...
                char(string(requestedStart, 'yyyy-MM-dd')), ...
                char(string(requestedEnd, 'yyyy-MM-dd')));
            error('Asset %s has no data inside the requested date range.', assetName);
        end

        boundedDates = assetDates(inBounds);
        boundedPrices = assetPrices(inBounds);

        boundedStarts(k) = boundedDates(1);
        boundedEnds(k) = boundedDates(end);
        perAssetRanges(k) = sprintf('%s: %s to %s', ...
            assetName, ...
            char(string(boundedStarts(k), 'yyyy-MM-dd')), ...
            char(string(boundedEnds(k), 'yyyy-MM-dd')));

        tt{k} = timetable(boundedDates, boundedPrices, 'VariableNames', "Close_" + k);
    end

    effectiveStart = max(boundedStarts);
    effectiveEnd = min(boundedEnds);

    if effectiveStart > effectiveEnd
        error(['No overlapping date range exists across the selected assets within the requested bounds.', newline, ...
            'Requested: %s to %s', newline, ...
            'Per-asset ranges inside request:', newline, ...
            '%s'], ...
            char(string(requestedStart, 'yyyy-MM-dd')), ...
            char(string(requestedEnd, 'yyyy-MM-dd')), ...
            strjoin(cellstr(perAssetRanges), newline));
    end

    for k = 1:nAssets
        rowTimes = tt{k}.Properties.RowTimes;
        keepMask = rowTimes >= effectiveStart & rowTimes <= effectiveEnd;
        tt{k} = tt{k}(keepMask, :);
    end

    aligned = tt{1};
    for k = 2:nAssets
        aligned = synchronize(aligned, tt{k}, 'intersection');
    end
    aligned = sortrows(aligned);

    if height(aligned) < 2
        error('Not enough overlapping dates across assets to compute price relatives.');
    end

    dates = aligned.Properties.RowTimes;
    P = aligned{:, :};
    R = P(2:end, :) ./ P(1:end-1, :);

    if any(~isfinite(R(:))) || any(R(:) <= 0)
        error('Bad price relatives computed: check for NaNs/zeros in Close_Last.');
    end

    trimmedDataset = containers.Map('KeyType', 'char', 'ValueType', 'any');
    for k = 1:nAssets
        assetName = char(assets(k));
        trimmedDataset(assetName) = struct( ...
            'asset', assetName, ...
            'dates', dates, ...
            'P', P(:, k), ...
            'R', R(:, k), ...
            'relativeDates', dates(2:end));
    end
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
