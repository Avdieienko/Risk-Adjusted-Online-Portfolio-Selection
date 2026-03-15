scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, '../helpers'));
rootDir = setup_project_paths();

assets = {'CVX', 'T', 'INTC'};

% Rebuild selected MAT files so each run starts from full CSV history.
csvToMat("dataset", assets);

dataset = prepareDataset("dataset");
[trimmedDataset, R, dates, ~] = prepareTrimmedDataset(dataset, assets, "03/02/2025", "02/11/2026");

assert(all(isKey(dataset, assets)), 'prepareDat#aset should preload the requested assets.');
assert(numel(trimmedDataset('CVX').R) == size(R, 1), 'Trimmed per-asset series must match aligned matrix rows.');

[T, n] = size(R);

weightTrajectories = zeros(T, n, 3);
wealthTrajectories = zeros(T+1, 3);

[ogd_w, ogd_wealth] = ogd_portfolio_selection(R, 0.2, @(w,r) logLossReturnGradient(w,r), []);
weightTrajectories(:,:,1) = ogd_w;
wealthTrajectories(:,1) = ogd_wealth;

[ubh_w, ubh_wealth] = solve_ubh(R);
weightTrajectories(:,:,2) = ubh_w;
wealthTrajectories(:,2) = ubh_wealth;

[bcrp_w, bcrp_wealth] = solve_best_crp_logwealth(R, ones(n,1)/n);
weightTrajectories(:,:,3) = bcrp_w;
wealthTrajectories(:,3) = bcrp_wealth;

plotWeightsChange(weightTrajectories, assets, {'OGD', 'UBH', 'BCRP'}, 20, dates);
plotWealthTrajectories(wealthTrajectories, dates, {'OGD', 'UBH', 'BCRP'});