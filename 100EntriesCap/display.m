% Get all MAT files in the current folder
files = dir('*.mat');

% Create a single figure with subplots
figure('Name', 'Log Returns Comparison', 'Position', [100, 100, 1200, 800]);

for k = 1:length(files)
    % Load the MAT file
    load(files(k).name);
    
    % Calculate log returns
    % log_return(t) = log(Price(t) / Price(t-1))
    prices = T.Close_Last;
    log_returns = diff(log(prices));
    
    % Create dates for log returns (one less than original due to diff)
    dates = T.Date(2:end);
    
    % Create subplot (2x2 grid)
    subplot(2, 2, k);
    
    % Plot log returns
    plot(dates, log_returns, 'LineWidth', 1);
    grid on;
    
    % Get filename without extension for title
    [~, name, ~] = fileparts(files(k).name);
    title(['Log Returns: ' strrep(name, '_', ' ')]);
    xlabel('Date');
    ylabel('Log Return');
    
    % Rotate x-axis labels for better readability
    xtickangle(45);
end

% Add overall title
sgtitle('Log Returns for All Assets', 'FontSize', 14, 'FontWeight', 'bold');