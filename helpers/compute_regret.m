function reg = compute_regret(loss_algo, loss_bench)
    % Compute regret as the difference between cumulative loss of the algorithm and the benchmark.
    % loss_algo and loss_bench should be T x 1 vectors of cumulative loss at each time step.
    if length(loss_algo) ~= length(loss_bench)
        error('loss_algo and loss_bench must have the same length.');
    end
    reg = cumsum(loss_algo) - cumsum(loss_bench);
end
