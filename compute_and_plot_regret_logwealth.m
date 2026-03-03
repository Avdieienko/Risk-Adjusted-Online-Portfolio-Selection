function reg = compute_and_plot_regret_logwealth(R, W, dates)
% R: T x n price relatives (strictly > 0)
% W: T x n weights used at each t
% dates: optional datetime vector length T or T+1

    ensure_dependency_paths();

    [T, n] = size(R);

    if size(W,1) ~= T || size(W,2) ~= n
        error('W must be T x n to match R.');
    end
    if any(R(:) <= 0)
        error('Price relatives must be strictly positive.');
    end

    eps_denom = 1e-12;

    % --- Algorithm cumulative log-wealth ---
    algo_cum = zeros(T,1);
    running = 0;
    for t = 1:T
        wt = W(t,:)';
        rt = R(t,:)';
        running = running + log(max(wt' * rt, eps_denom));
        algo_cum(t) = running;
    end

    % --- Best fixed CRP cumulative log-wealth for each prefix ---
    % TODO: Substitute with a list of different algorithms to compare against, e.g. best CRP, UP, etc.
    best_cum = zeros(T,1);
    w_best_prev = ones(n,1)/n;

    for t = 1:T
        Rt = R(1:t, :);
        w_best = solve_best_crp_logwealth(Rt, w_best_prev);
        w_best_prev = w_best;

        % compute prefix objective value at w_best
        val = 0;
        for s = 1:t
            val = val + log(max(w_best' * Rt(s,:)', eps_denom));
        end
        best_cum(t) = val;
    end

    % Regret: best fixed minus algorithm
    reg = best_cum - algo_cum;

    % --- Plot ---
    figure;
    if nargin >= 3 && ~isempty(dates)
        x = dates;
        if numel(x) == T+1
            x = x(2:end);
        end
        plot(x, reg, 'LineWidth', 2);
        xlabel('Date');
    else
        plot(1:T, reg, 'LineWidth', 2);
        xlabel('t');
    end
    ylabel('Regret (log-wealth)');
    title(' Worst-case Regret vs Benchmark algorithm (log-loss)');
    grid on;
end

function ensure_dependency_paths()
    thisDir = fileparts(mfilename('fullpath'));
    addpath(thisDir);

    bcrpDir = fullfile(thisDir, 'bcrp');
    if isfolder(bcrpDir)
        addpath(bcrpDir);
    end
end
