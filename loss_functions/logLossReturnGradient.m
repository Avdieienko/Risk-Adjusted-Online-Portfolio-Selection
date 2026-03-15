function grad = logLossReturnGradient(w, r)
    % Compute the gradient of the log-return with respect to the portfolio weights
    % w: current portfolio weights (n x 1)
    % r: returns for the current time step (n x 1)

    % The log-return is log(w' * r), so its gradient is:
    denom = max(w' * r, 1e-12);
    grad = -r / denom;
end