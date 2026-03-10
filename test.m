% Test script for simplexProjection on 3D unit simplex
scriptDir = fileparts(mfilename('fullpath'));
addpath(fullfile(scriptDir, 'helpers'));
setup_project_paths();

fprintf('=== Testing simplexProjection on 3D Unit Simplex ===\n\n');

% Define test points
test_points = [
    0.5,  0.3,  0.2;   % Point already on simplex (sum = 1)
    0.4,  0.4,  0.4;   % Point outside simplex (sum > 1)
    2.0,  3.0,  1.0;   % Point far outside simplex
    -0.5, 0.8,  0.7;   % Point with negative component
    0.1,  0.1,  0.1;   % Point inside simplex (sum < 1)
    1.0,  1.0,  1.0;   % Point with all equal components
    5.0,  0.0,  0.0;   % Point on one axis, far out
    0.0,  0.0,  0.0    % Origin
    ];

% Visualize the simplex
figure('Name', '3D Simplex Projection Test', 'Position', [100, 100, 1000, 800]);

% Define simplex vertices
vertices = [
    0, 0, 0;    % Origin
    1, 0, 0;    % X-axis
    0, 1, 0;    % Y-axis
    0, 0, 1     % Z-axis
    ];

faces = [
    1, 2, 3;
    1, 2, 4;
    1, 3, 4;
    2, 3, 4
    ];

% Plot the simplex
patch('Vertices', vertices, 'Faces', faces, ...
    'FaceColor', 'cyan', 'FaceAlpha', 0.2, ...
    'EdgeColor', 'blue', 'LineWidth', 2);
hold on;

% Plot simplex vertices
plot3(vertices(:,1), vertices(:,2), vertices(:,3), ...
    'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'black');

% % Test each point
% for i = 1:size(test_points, 1)
%     y = test_points(i, :)';

%     % Project onto simplex
%     [x, mu, K] = simplexProjection(y);

%     % Print results
%     fprintf('Test %d:\n', i);
%     fprintf('  Input y    = [%.4f, %.4f, %.4f], sum = %.4f\n', y(1), y(2), y(3), sum(y));
%     fprintf('  Projected x = [%.4f, %.4f, %.4f], sum = %.4f\n', x(1), x(2), x(3), sum(x));
%     fprintf('  mu = %.4f, K = %d\n', mu, K);
%     fprintf('  Distance ||y - x|| = %.4f\n\n', norm(y - x));

%     % Plot original point
%     plot3(y(1), y(2), y(3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'red');

%     % Plot projected point
%     plot3(x(1), x(2), x(3), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'green');

%     % Draw line from original to projected point
%     plot3([y(1), x(1)], [y(2), x(2)], [y(3), x(3)], 'k--', 'LineWidth', 1.5);

%     % Add labels
%     text(y(1), y(2), y(3), sprintf('  y%d', i), 'Color', 'red', 'FontSize', 9);
%     text(x(1), x(2), x(3), sprintf('  x%d', i), 'Color', 'green', 'FontSize', 9);
% end

% Finalize plot
axis equal;
grid on;
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Simplex Projection: Red (original) → Green (projected)');
legend('Simplex', 'Vertices', 'Original Points', 'Projected Points', 'Projection Lines');
view(45, 30);
rotate3d on;

hold off;

fprintf('=== All tests complete ===\n');