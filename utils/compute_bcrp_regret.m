function reg = compute_bcrp_regret(R, loss_algo, loss_func)
    % Compute regret against the best CRP in hindsight using log-wealth.
    % loss_algo should be a T x 1 vector of cumulative loss at each time step for the algorithm.
    % This function will compute the cumulative loss of the best CRP and return the regret.
    % Load historical returns (assuming R is available in the workspace)
    [~, ~, loss_bench] = solve_best_crp_logwealth(R, loss_func);

    % Compute regret
    reg = compute_regret(loss_algo, loss_bench);
end