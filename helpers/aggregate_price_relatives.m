function [R, dates, P] = aggregate_price_relatives(files)
% AGGREGATE_PRICE_RELATIVES
% Loads N .mat files, each containing a table with variables:
%   Date (MM/dd/yyyy) and Close_Last (numeric)
% Aligns by intersection of dates and computes price relatives.
%
% Inputs:
%   files : 1xN string/cell array of .mat file paths
%
% Outputs:
%   P     : T x N aligned close prices
%   dates : T x 1 datetime aligned dates
%   R     : (T-1) x N price relatives

    if nargin < 1 || isempty(files)
        error('files must be a non-empty list of .mat file paths.');
    end

    % Normalize to string array
    files = string(files);
    N = numel(files);

    TT = cell(1, N);

    for i = 1:N
        S = load(files(i));
        f = fieldnames(S);

        if numel(f) ~= 1
            error('File %s must contain exactly ONE variable (the table).', files(i));
        end

        T = S.(f{1});

        if ~istable(T)
            error('File %s: the only variable must be a TABLE.', files(i));
        end

        if ~all(ismember({'Date','Close_Last'}, T.Properties.VariableNames))
            error('File %s: table must contain Date and Close_Last.', files(i));
        end

        % Parse dates (your screenshot format)
        d = T.Date;
        if ~isdatetime(d)
            d = datetime(d, 'InputFormat', 'MM/dd/yyyy');
        end

        % Create timetable with a unique close name
        TT{i} = timetable(d, T.Close_Last, 'VariableNames', "Close_" + i);
    end

    % Align by common dates only (intersection)
    TT_all = TT{1};
    for i = 2:N
        TT_all = synchronize(TT_all, TT{i}, 'intersection');
    end
    TT_all = sortrows(TT_all);

    if height(TT_all) < 2
        error('Not enough overlapping dates across assets to compute price relatives.');
    end

    dates = TT_all.d;        % timetable row times
    P = TT_all{:, :};        % T x N close prices
    R = P(2:end,:) ./ P(1:end-1,:);   % (T-1) x N price relatives

    if any(~isfinite(R(:))) || any(R(:) <= 0)
        error('Bad price relatives computed: check for NaNs/zeros in Close_Last.');
    end
end