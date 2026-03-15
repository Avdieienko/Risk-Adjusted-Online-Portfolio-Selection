scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, 'helpers'));
rootDir = setup_project_paths();

assets = {'CVX', 'T', 'INTC'};

% Rebuild selected MAT files so each run starts from full CSV history.
csvToMat("dataset", assets);

dataset = prepareDataset("dataset");
[trimmedDataset, R, dates, ~] = prepareTrimmedDataset(dataset, assets, "08/02/2025", "02/11/2026");

assert(all(isKey(dataset, assets)), 'prepareDataset should preload the requested assets.');
assert(numel(trimmedDataset('CVX').R) == size(R, 1), 'Trimmed per-asset series must match aligned matrix rows.');

etaValues = [0.05, 0.2, 0.4, 1];
numEta = numel(etaValues);
outs = cell(1, numEta);
regrets = cell(1, numEta);
weightTrajectories = cell(1, numEta);

[T, n] = size(R);

for i = 1:numEta
    eta = etaValues(i);
    out = ogd_portfolio_selection(R, eta, @(w,r) logLossFuncGradient(w,r), []);
    outs{i} = out;
    weightTrajectories{i} = out.W;
    reg = compute_regret_logwealth(R, out.W);
    regrets{i} = reg;


    assert(isequal(size(out.W), [T, n]), 'W shape wrong for eta=%g', eta);
    assert(numel(out.wealth) == T+1, 'wealth length wrong for eta=%g', eta);
    assert(all(out.wealth > 0), 'wealth must be positive for eta=%g', eta);
    assert(all(abs(sum(out.W,2) - 1) < 1e-9), 'weights must sum to 1 for eta=%g', eta);
    assert(all(out.W(:) >= -1e-12), 'weights must be nonnegative for eta=%g', eta);
end

plotWeightsChangeSimplex(weightTrajectories, assets, arrayfun(@(e) sprintf('\\eta = %.2f', e), etaValues, 'UniformOutput', false));

figure;
hold on;
for i = 1:numEta
    plot(dates(2:end), outs{i}.wealth(2:end), 'LineWidth', 1.4);
end
hold off;
grid on;
xlabel('Date'); ylabel('Wealth');
title('OGD Wealth Across Different \eta');
legend(arrayfun(@(e) sprintf('\\eta = %.2f', e), etaValues, 'UniformOutput', false), ...
    'Location', 'best');

figure;
hold on;
for i = 1:numEta
    plot(dates(2:end), regrets{i}, 'LineWidth', 1.4);
end
hold off;
grid on;
xlabel('Date'); ylabel('Regret');
title('OGD Regret Across Different \eta');
legend(arrayfun(@(e) sprintf('\\eta = %.2f', e), etaValues, 'UniformOutput', false), ...
    'Location', 'best');

disp('test_ogd_with_matfiles passed.');

function grad = logLossFuncGradient(w, r)
    denom = max(w' * r, 1e-12);
    grad = -r / denom;
end
