function plotWeightsChangeSimplex(weights, assetNames, trajLabels)
%PLOTWEIGHTSCHANGESIMPLEX Plot one or more trajectories on a 3D simplex.
% plotWeightsChangeSimplex(weights)
% plotWeightsChangeSimplex(weights, assetNames)
%
% Inputs:
%   weights:
%     - T x 3 numeric matrix (single trajectory), or
%     - 1 x N / N x 1 cell array where each cell is T x 3 numeric, or
%     - T x 3 x N numeric array (N trajectories)
%   assetNames   - 1 x 3 labels for simplex axes
%   trajLabels   - 1 x N labels for trajectories (optional)
    if nargin < 2 || isempty(assetNames)
        assetNames = {'X', 'Y', 'Z'};
    end
    if nargin < 3
        trajLabels = arrayfun(@(k) sprintf('Trajectory %d', k), 1:numel(weights), 'UniformOutput', false);
    end

    if numel(assetNames) ~= 3
        error('assetNames must contain exactly 3 labels.');
    end

    trajectories = normalizeTrajectories(weights);
    numTraj = numel(trajectories);
    colors = lines(numTraj);
    startColor = [0.95, 0.85, 0.10]; % high-contrast yellow
    endColor = [0.95, 0.20, 0.20];   % high-contrast red

    figure('Name', '3D Simplex Weight Trajectories', 'Position', [100, 100, 1000, 800]);

    % Define simplex vertices.
    vertices = [
        0, 0, 0;
        1, 0, 0;
        0, 1, 0;
        0, 0, 1
    ];

    faces = [
        1, 2, 3;
        1, 2, 4;
        1, 3, 4;
        2, 3, 4
    ];

    hSimplex = patch('Vertices', vertices, 'Faces', faces, ...
        'FaceColor', 'cyan', 'FaceAlpha', 0.2, ...
        'EdgeColor', 'blue', 'LineWidth', 1.5, ...
        'DisplayName', 'Simplex');
    hold on;

    hVertices = plot3(vertices(:,1), vertices(:,2), vertices(:,3), ...
        'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'black', ...
        'DisplayName', 'Vertices');

    hTraj = gobjects(numTraj, 1);
    hStart = gobjects(numTraj, 1);
    hEnd = gobjects(numTraj, 1);

    for k = 1:numTraj
        W = trajectories{k};
        c = colors(k, :);

        hTraj(k) = plot3(W(:,1), W(:,2), W(:,3), '-', ...
            'Color', c, 'LineWidth', 1.8, ...
            'DisplayName', trajLabels{k});

        startName = '';
        endName = '';
        if k == 1
            startName = 'Start';
            endName = 'End';
        end

        hStart(k) = plot3(W(1,1), W(1,2), W(1,3), 'o', ...
            'Color', startColor, 'MarkerSize', 8, ...
            'MarkerFaceColor', startColor, 'MarkerEdgeColor', 'black', ...
            'LineWidth', 1.0, ...
            'DisplayName', startName);
        hEnd(k) = plot3(W(end,1), W(end,2), W(end,3), 's', ...
            'Color', endColor, 'MarkerSize', 8, ...
            'MarkerFaceColor', endColor, 'MarkerEdgeColor', 'black', ...
            'LineWidth', 1.0, ...
            'DisplayName', endName);

        if k > 1
            set(hStart(k), 'HandleVisibility', 'off');
            set(hEnd(k), 'HandleVisibility', 'off');
        end
    end

    axis equal;
    grid on;
    xlabel(string(assetNames{1}));
    ylabel(string(assetNames{2}));
    zlabel(string(assetNames{3}));
    title('Simplex Weight Trajectories');
    legend([hSimplex, hVertices, hTraj(:).', hStart(1), hEnd(1)], ...
        'Location', 'best');
    view(45, 30);
    rotate3d on;
    hold off;
end

function trajectories = normalizeTrajectories(weights)
    if isnumeric(weights)
        if ismatrix(weights)
            trajectories = {weights};
        elseif ndims(weights) == 3 && size(weights,2) == 3
            nTraj = size(weights, 3);
            trajectories = cell(1, nTraj);
            for k = 1:nTraj
                trajectories{k} = weights(:, :, k);
            end
        else
            error(['weights must be T x 3, a cell array of T x 3 matrices, ' ...
                'or T x 3 x N.']);
        end
    elseif iscell(weights)
        trajectories = weights;
    else
        error(['weights must be T x 3, a cell array of T x 3 matrices, ' ...
            'or T x 3 x N.']);
    end

    if isempty(trajectories)
        error('weights must contain at least one trajectory.');
    end

    for k = 1:numel(trajectories)
        W = trajectories{k};
        if ~(isnumeric(W) && ismatrix(W) && size(W,2) == 3 && size(W,1) >= 1)
            error('Trajectory %d must be a numeric T x 3 matrix with T >= 1.', k);
        end
    end
end
