function rootDir = setup_project_paths()
%SETUP_PROJECT_PATHS Adds project folders needed by scripts/functions.
% Returns:
%   rootDir - absolute path to project root.

    thisDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(thisDir);

    addpath(rootDir);
    addpath(thisDir);

    coreDirs = {'ftl', 'helpers', 'bcrp', 'utils'};
    for i = 1:numel(coreDirs)
        d = fullfile(rootDir, coreDirs{i});
        if isfolder(d)
            addpath(d);
        end
    end
end
