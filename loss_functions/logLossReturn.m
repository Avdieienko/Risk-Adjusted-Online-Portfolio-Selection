function loss = logLossReturn(w, r)
    % Compute the log-return loss for a given portfolio and returns
    % w: current portfolio weights (n x 1)
    % r: returns for the current time step (n x 1)
    % The log-return is log(w' * r), so the loss is its negative:
    loss = -log(max(w' * r, 1e-12)); % Add small epsilon to prevent log(0)
end