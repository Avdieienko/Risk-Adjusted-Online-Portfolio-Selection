function plotDistributionOvertime(weights)
    % Given T x n matrix of weights, plot distribution of weights for each asset over time
    [meanWeights, stdWeights] = getWeightsMatrixStats(weights);
    T = size(weights, 1);
    time = 1:T;
    figure;
    hold on;
    for i = 1:size(weights, 2)
        % Plot mean with shaded area for std
        plot(time, meanWeights(i)*ones(size(time)), 'LineWidth', 2);
        fill([time, fliplr(time)], [meanWeights(i)+stdWeights(i)*ones(size(time)), fliplr(meanWeights(i)-stdWeights(i)*ones(size(time)))], ...
            'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    end
    hold off;
    grid on;
    xlabel('Time'); ylabel('Weight');
    title('Distribution of Weights Over Time');
    legend(arrayfun(@(i) sprintf('Asset %d', i), 1:size(weights, 2), 'UniformOutput', false), ...
        'Location', 'best');
end