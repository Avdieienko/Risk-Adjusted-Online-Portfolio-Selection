function plotWeightsChangeSimplex(weights, assetNames)
%PLOTWEIGHTSCHANGESIMPLEX Plot weight trajectories on one 3D simplex plane.
% ax = plotWeightsChangeSimplex(WSeries)
% ax = plotWeightsChangeSimplex(WSeries, assetNames)
% ax = plotWeightsChangeSimplex(WSeries, assetNames, seriesLabels)
% ax = plotWeightsChangeSimplex(WSeries, assetNames, seriesLabels, gridStep)
%
% Inputs:
%   WSeries      - T x 3, T x 3 x K, or 1xK cell array of T_k x 3 matrices
%   assetNames   - optional 1x3 labels for vertices [x1, x2, x3]
%   seriesLabels - optional labels for legend (one per trajectory)
%   gridStep     - optional simplex grid spacing in (0,1), default 0.2
%
% Output:
%   ax           - axes handle

    if nargin < 2 || isempty(assetNames)
        assetNames = {'X', 'Y', 'Z'};
    end

    if numel(assetNames) ~= 3
        error('assetNames must contain exactly 3 labels.');
    end

    % Visualize the simplex
    figure('Name', '3D Simplex Weight Trajectory', 'Position', [100, 100, 1000, 800]);

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
    hSimplex = patch('Vertices', vertices, 'Faces', faces, ...
        'FaceColor', 'cyan', 'FaceAlpha', 0.2, ...
        'EdgeColor', 'blue', 'LineWidth', 2);
    hold on;

    % Plot simplex vertices
    hVertices = plot3(vertices(:,1), vertices(:,2), vertices(:,3), ...
        'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'black');


    % Plot trajectory through the simplex by connecting consecutive weights.
    hTrajectory = plot3(weights(:,1), weights(:,2), weights(:,3), ...
        'r-', 'LineWidth', 1.5);

    hStart = plot3(weights(1,1), weights(1,2), weights(1,3), ...
        'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'black');
    hEnd = plot3(weights(end,1), weights(end,2), weights(end,3), ...
        'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'green');

    % Finalize plot
    axis equal;
    grid on;
    xlabel(assetNames{1});
    ylabel(assetNames{2});
    zlabel(assetNames{3});
    title('Simplex Weight Trajectory');
    legend([hSimplex, hVertices, hTrajectory, hStart, hEnd], ...
        {'Simplex', 'Vertices', 'Weight Path', 'Start', 'End'});
    view(45, 30);
    rotate3d on;

    hold off;
