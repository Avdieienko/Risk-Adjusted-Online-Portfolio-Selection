function [wealth, loss] = solve_singleStock_hold(R, stockIndex, loss_func)
% SOLVE_SINGLESTOCK_HOLD Single-stock buy-and-hold in strategy format.
%
% Usage (new):
%   [W, wealth, loss] = solve_singleStock_hold(R)
%   [W, wealth, loss] = solve_singleStock_hold(R, stockIndex)
%   [W, wealth, loss] = solve_singleStock_hold(R, stockIndex, loss_func)
%
% Usage (legacy-compatible):
%   [W, wealth, loss] = solve_singleStock_hold(initWealth, R)
%   [W, wealth, loss] = solve_singleStock_hold(initWealth, R, stockIndex, loss_func)
%
% Outputs:
%   W      - T x n weights used each period (one-hot on selected stock)
%   wealth - (T+1) x 1 wealth path
%   loss   - T x 1 per-step loss

    [T, n] = size(R);
    if any(R(:) <= 0)
        error('Price relatives must be strictly positive.');
    end
    if stockIndex < 1 || stockIndex > n || stockIndex ~= floor(stockIndex)
        error('stockIndex must be an integer in [1, n].');
    end

    w = zeros(n, 1);
    w(stockIndex) = 1;

    wealth = zeros(T + 1, 1);
    wealth(1) = initWealth;
    wealth(2:end) = initWealth * cumprod(R(:, stockIndex));

    loss = zeros(T, 1);
    for t = 1:T
        loss(t) = loss_func(w, R(t, :)');
    end
end