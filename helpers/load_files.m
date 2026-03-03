function files = load_files(folder_path, assets)
%LOAD_FILES Returns .mat files, optionally filtered by asset names.
% files = load_files(folder_path)
% files = load_files(folder_path, assets)

    listing = dir(fullfile(folder_path, '*.mat'));
    names = string({listing.name});

    if nargin < 2 || isempty(assets)
        files = cellfun(@(x) fullfile(folder_path, x), cellstr(names), 'UniformOutput', false);
        return;
    end

    assets = upper(string(assets(:)));
    baseNames = upper(erase(names, ".mat"));

    files = cell(1, numel(assets));
    k = 0;
    for i = 1:numel(assets)
        idx = find(baseNames == assets(i), 1, 'first');
        if ~isempty(idx)
            k = k + 1;
            files{k} = fullfile(folder_path, names(idx));
        end
    end

    files = files(1:k);
end
