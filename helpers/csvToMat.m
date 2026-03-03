function matFiles = csvToMat(folder_path, assets)
%CSVTOMAT Convert selected CSV files into MAT tables.
% matFiles = csvToMat()
% matFiles = csvToMat(folder_path)
% matFiles = csvToMat(folder_path, assets)
%
% Inputs:
%   folder_path - optional folder containing CSV files (default: this file's folder)
%   assets      - optional asset names (string/cell), e.g. ["VOO","QQQ"]
%
% Output:
%   matFiles    - 1xN cell array of saved .mat file paths

    if nargin < 1 || isempty(folder_path)
        folder_path = fileparts(mfilename('fullpath'));
    end

    listing = dir(fullfile(folder_path, '*.csv'));
    csvNames = string({listing.name});

    if nargin >= 2 && ~isempty(assets)
        assets = upper(string(assets(:)));
        baseCsvNames = upper(erase(csvNames, ".csv"));

        selected = strings(0,1);
        for i = 1:numel(assets)
            idx = find(baseCsvNames == assets(i), 1, 'first');
            if ~isempty(idx)
                selected(end+1,1) = csvNames(idx); %#ok<AGROW>
            end
        end
        csvNames = selected;
    end

    matFiles = cell(1, numel(csvNames));

    for k = 1:numel(csvNames)
        csvPath = fullfile(folder_path, csvNames(k));
        T = readtable(csvPath);
        T = T(:, {'Date', 'Close_Last'});

        if iscell(T.Close_Last)
            cleaned = strrep(T.Close_Last, "'", '');
            cleaned = strrep(cleaned, '$', '');
            T.Close_Last = str2double(cleaned);
        elseif isstring(T.Close_Last)
            cleaned = replace(T.Close_Last, "'", '');
            cleaned = replace(cleaned, '$', '');
            T.Close_Last = str2double(cleaned);
        end

        [~, name, ~] = fileparts(csvNames(k));
        matPath = fullfile(folder_path, [char(name) '.mat']);
        save(matPath, 'T');
        matFiles{k} = matPath;
    end
end
