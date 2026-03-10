scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, 'helpers'));
rootDir = setup_project_paths();

assets = {'CVX', 'T', 'INTC'};

% Rebuild selected MAT files so each run starts from full CSV history.
csvToMat("dataset", assets);

[R, dates, P] = prepareDataset("dataset", assets, "01/02/2021", "02/11/2026");

eta0 = 0.2;
out = ogd_portfolio_selection(R, eta0, @(w,r) logLossFuncGradient(w,r), []);

reg = compute_and_plot_regret_logwealth(R, out.W, dates);
% plotWeightsChange(out.W, assets, 20, dates);
plotWeightsChangeSimplex(out.W, assets);
%plot_regret_with_bounds(reg, dates);
%plot_regret_with_all_bounds(reg, dates);

[T, n] = size(R);

assert(isequal(size(out.W), [T, n]), 'W shape wrong');
assert(numel(out.wealth) == T+1, 'wealth length wrong');
assert(all(out.wealth > 0), 'wealth must be positive');
assert(all(abs(sum(out.W,2) - 1) < 1e-9), 'weights must sum to 1');
assert(all(out.W(:) >= -1e-12), 'weights must be nonnegative');

figure;
plot(dates(2:end), out.wealth(2:end));
grid on;
xlabel('Date'); ylabel('Wealth');
title('OGD wealth');

disp('test_ogd_with_matfiles passed.');

function grad = logLossFuncGradient(w, r)
    denom = max(w' * r, 1e-12);
    grad = -r / denom;
end
