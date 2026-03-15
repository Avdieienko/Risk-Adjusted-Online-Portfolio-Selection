scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, 'helpers'));
rootDir = setup_project_paths();

assets = {'CVX', 'T', 'INTC'};

% Rebuild selected MAT files so each run starts from full CSV history.
csvToMat("dataset", assets);

dataset = prepareDataset("dataset");
[trimmedDataset, R, dates, ~] = prepareTrimmedDataset(dataset, assets, "03/02/2021", "02/11/2026");
[trimmedVOO, R_VOO, dates_VOO, ~] = prepareTrimmedDataset(dataset, {'VOO'}, "03/02/2021", "02/11/2026");

assert(all(isKey(dataset, assets)), 'prepareDataset should preload the requested assets.');
assert(numel(trimmedDataset('CVX').R) == size(R, 1), 'Trimmed per-asset series must match aligned matrix rows.');

[T, n] = size(R);


etaValues = [0.05, 0.2, 0.4, 1];
eta_functions = {@(init_eta, t) fixed_eta(init_eta, t), @(init_eta, t) simple_time_decay_eta(init_eta, t)};
numEta = numel(etaValues);
outs = cell(1, numEta);
regrets = zeros(T, numEta);
weightTrajectories = zeros(T, n, numEta);
wealthTrajectories = zeros(T+1, numEta);

for j = 1:size(eta_functions, 2)
    eta_func = eta_functions{j};
    for i = 1:numEta
        eta = etaValues(i);
        [W, wealth, loss] = ogd_portfolio_selection(R, eta, eta_func, @(w,r) logLossReturn(w,r), @(w,r) logLossReturnGradient(w,r), []);
        weightTrajectories(:,:,i) = W;
        wealthTrajectories(:,i) = wealth;
        reg = compute_bcrp_regret(R, loss, @(w,r) logLossReturn(w,r));
        regrets(:,i) = reg;

        assert(isequal(size(W), [T, n]), 'W shape wrong for eta=%g', eta);
        assert(numel(wealth) == T+1, 'wealth length wrong for eta=%g', eta);
        assert(all(wealth > 0), 'wealth must be positive for eta=%g', eta);
        assert(all(abs(sum(W,2) - 1) < 1e-9), 'weights must sum to 1 for eta=%g', eta);
        assert(all(W(:) >= -1e-12), 'weights must be nonnegative for eta=%g', eta);
    end

    plotWeightsChange(weightTrajectories, assets, arrayfun(@(e) sprintf('\\eta = %.2f', e), etaValues, 'UniformOutput', false), 60, dates);
    % plotWeightsChangeSimplex(weightTrajectories, assets, arrayfun(@(e) sprintf('\\eta = %.2f', e), etaValues, 'UniformOutput', false));

    figure;
    hold on;
    for i = 1:numEta
        plot(dates(2:end), wealthTrajectories(2:end,i), 'LineWidth', 1.4);
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
        plot(dates(2:end), regrets(:,i), 'LineWidth', 1.4);
    end
    hold off;
    grid on;
    xlabel('Date'); ylabel('Regret');
    title('OGD Regret Across Different \eta');
    legend(arrayfun(@(e) sprintf('\\eta = %.2f', e), etaValues, 'UniformOutput', false), ...
        'Location', 'best');

    disp('test_ogd_with_matfiles passed.');
end