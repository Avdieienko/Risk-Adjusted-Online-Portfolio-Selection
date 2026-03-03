function plottedFiles = display(folder_path, assets)
%DISPLAY Plot price-relative series from selected MAT files.
% plottedFiles = display(folder_path)
% plottedFiles = display(folder_path, assets)
%
% Inputs:
%   folder_path - folder containing .mat files
%   assets      - optional asset list, same filtering behavior as load_files
%
% Output:
%   plottedFiles - 1xN cell array of file paths that were plotted

    if nargin < 1 || isempty(folder_path)
        error('folder_path is required.');
    end

    if nargin < 2
        files = load_files(folder_path);
    else
        files = load_files(folder_path, assets);
    end

    if isempty(files)
        warning('No MAT files found to plot in %s.', folder_path);
        plottedFiles = {};
        return;
    end

    n = numel(files);
    nRows = ceil(sqrt(n));
    nCols = ceil(n / nRows);

    figure('Name', 'Price Relatives Comparison', 'Position', [100, 100, 1200, 800]);

    plottedFiles = {};
    for k = 1:n
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

        T = S.(varName);
        if ~istable(T) || ~all(ismember({'Date', 'Close_Last'}, T.Properties.VariableNames))
            warning('Skipping %s (%s must be a table with Date and Close_Last).', filePath, varName);
            continue;
        end

        prices = T.Close_Last;
        priceRelatives = prices ./ [NaN; prices(1:end-1)];
        dates = T.Date;
        if ~isdatetime(dates)
            dates = datetime(dates, 'InputFormat', 'MM/dd/yyyy');
        end

        subplot(nRows, nCols, k);
        plot(dates(2:end), priceRelatives(2:end), 'LineWidth', 1.1);
        grid on;

        [~, name, ~] = fileparts(filePath);
        title(strrep(name, '_', ' '));
        xlabel('Date');
        ylabel('Price Relative');
        xtickangle(45);

        plottedFiles{end+1} = filePath; %#ok<AGROW>
    end

    sgtitle('Price Relatives for Selected Assets', 'FontSize', 14, 'FontWeight', 'bold');
end

