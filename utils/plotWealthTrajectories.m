function plotWealthTrajectories(wealthTrajectories, dates, labels)
    % wealthTrajectories: T x M matrix of wealth trajectories for M algorithms
    % dates: T x 1 vector of date labels
    % labels: 1 x M cell array of algorithm names

    figure;
    plot(dates, wealthTrajectories, 'LineWidth', 2);
    datetick('x', 'dd-mmm-yyyy');
    xlabel('Date');
    ylabel('Wealth');
    title('Wealth Trajectories of Algorithms');
    legend(labels, 'Location', 'NorthWest');
    grid on;
end