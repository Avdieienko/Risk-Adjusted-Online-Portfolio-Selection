function plotWeightsChange(weights, assetNames, trajLabels, sliceStride, dates)
%PLOTWEIGHTSCHANGE Plot 3-asset weight trajectory/trajectories as a simplex tube.
%   plotWeightsChange(weights)
%   plotWeightsChange(weights, assetNames)
%   plotWeightsChange(weights, assetNames, trajLabels)
%   plotWeightsChange(weights, assetNames, trajLabels, sliceStride)
%   plotWeightsChange(weights, assetNames, trajLabels, sliceStride, dates)
%
% Inputs:
%   weights:
%     - T x 3 numeric matrix (single trajectory), or
%     - 1 x N / N x 1 cell array where each cell is T x 3 numeric, or
%     - T x 3 x N numeric array (N trajectories)
%   assetNames   - optional names for the 3 assets
%   trajLabels   - optional labels, one per trajectory
%   sliceStride  - optional spacing between simplex slices in the tube
%   dates        - optional datetime (or datenum/string) vector of length T or T+1

    if nargin < 2 || isempty(assetNames)
        assetNames = {'Asset 1', 'Asset 2', 'Asset 3'};
    end
    if nargin < 3
        trajLabels = [];
    end
    if nargin < 4
        sliceStride = [];
    end
    if nargin < 5
        dates = [];
    end

    trajectories = normalizeTrajectories(weights);
    numTraj = numel(trajectories);

    [trajLabels, sliceStride, dates] = resolveOptionalInputs(numTraj, trajLabels, sliceStride, dates);

    if numel(assetNames) ~= 3
        error('assetNames must contain exactly 3 labels.');
    end

    if isempty(trajLabels)
        trajLabels = arrayfun(@(k) sprintf('Trajectory %d', k), 1:numTraj, 'UniformOutput', false);
    else
        trajLabels = cellstr(string(trajLabels));
        if numel(trajLabels) ~= numTraj
            error('trajLabels must have one label per trajectory.');
        end
    end

    Tvals = zeros(numTraj, 1);
    for k = 1:numTraj
        W = trajectories{k};
        if any(~isfinite(W(:)))
            error('Trajectory %d contains NaN or Inf values.', k);
        end

        % Keep simplex geometry valid despite tiny numerical drift.
        W = max(W, 0);
        rowSums = sum(W, 2);
        if any(rowSums <= 0)
            error('Each row of trajectory %d must have positive total weight.', k);
        end
        W = W ./ rowSums;

        trajectories{k} = W;
        Tvals(k) = size(W, 1);
    end

    Tmax = max(Tvals);

    if isempty(sliceStride)
        sliceStride = max(1, floor(Tmax / 40));
    else
        sliceStride = max(1, floor(double(sliceStride)));
    end

    dateVec = [];
    if ~isempty(dates)
        if numTraj > 1 && any(Tvals ~= Tvals(1))
            error('When dates are provided for multiple trajectories, all must have the same length T.');
        end
        dateVec = normalizeDates(dates, Tvals(1));
        xRef = datenum(dateVec);
    else
        xRef = (1:Tmax)';
    end

    % Equilateral 2D simplex vertices in (y,z), mapped through barycentric weights.
    simplexYZ = [
         0.00,  sqrt(3)/2;   % Asset 1 vertex
         0.50,  0.00;        % Asset 2 vertex
        -0.50,  0.00         % Asset 3 vertex
    ];

    sampleIdx = unique([1:sliceStride:numel(xRef), numel(xRef)]);
    edgePairs = [1 2; 2 3; 3 1];

    figure('Color', 'w', 'Name', 'Portfolio Weights in 3-Asset Simplex Tube');
    hold on;

    % Draw translucent side panels between sampled simplex slices.
    for k = 1:numel(sampleIdx)-1
        t1 = xRef(sampleIdx(k));
        t2 = xRef(sampleIdx(k+1));

        for e = 1:size(edgePairs,1)
            i1 = edgePairs(e,1);
            i2 = edgePairs(e,2);
            quad = [
                t1, simplexYZ(i1,1), simplexYZ(i1,2);
                t1, simplexYZ(i2,1), simplexYZ(i2,2);
                t2, simplexYZ(i2,1), simplexYZ(i2,2);
                t2, simplexYZ(i1,1), simplexYZ(i1,2)
            ];
            patch('Vertices', quad, ...
                  'Faces', [1 2 3 4], ...
                  'FaceColor', [0.70 0.82 1.00], ...
                  'FaceAlpha', 0.08, ...
                  'EdgeColor', 'none', ...
                  'HandleVisibility', 'off');
        end
    end

    % Draw simplex triangle outlines at sampled time slices.
    for k = 1:numel(sampleIdx)
        tk = xRef(sampleIdx(k));
        tri = [tk * ones(3,1), simplexYZ];
        patch('Vertices', tri, ...
              'Faces', [1 2 3], ...
              'FaceColor', [0.90 0.94 1.00], ...
              'FaceAlpha', 0.08, ...
              'EdgeColor', [0.35 0.45 0.65], ...
              'LineWidth', 0.7, ...
              'HandleVisibility', 'off');
    end

    lineColors = lines(numTraj);
    startColor = [0.95, 0.85, 0.10]; % high-contrast yellow
    endColor = [0.95, 0.20, 0.20];   % high-contrast red

    hTraj = gobjects(numTraj, 1);
    hStart = gobjects(numTraj, 1);
    hEnd = gobjects(numTraj, 1);

    for k = 1:numTraj
        W = trajectories{k};
        Tk = size(W, 1);

        if isempty(dateVec)
            x = (1:Tk)';
        else
            x = xRef;
        end

        trajYZ = W * simplexYZ;
        trajXYZ = [x, trajYZ];

        hTraj(k) = plot3(trajXYZ(:,1), trajXYZ(:,2), trajXYZ(:,3), ...
            'Color', lineColors(k,:), 'LineWidth', 2.2, ...
            'DisplayName', trajLabels{k});

        startName = '';
        endName = '';
        if k == 1
            startName = 'Start';
            endName = 'End';
        end

        hStart(k) = plot3(trajXYZ(1,1), trajXYZ(1,2), trajXYZ(1,3), 'o', ...
            'Color', startColor, 'MarkerSize', 8, ...
            'MarkerFaceColor', startColor, 'MarkerEdgeColor', 'black', ...
            'LineWidth', 1.0, ...
            'DisplayName', startName);
        hEnd(k) = plot3(trajXYZ(end,1), trajXYZ(end,2), trajXYZ(end,3), 's', ...
            'Color', endColor, 'MarkerSize', 8, ...
            'MarkerFaceColor', endColor, 'MarkerEdgeColor', 'black', ...
            'LineWidth', 1.0, ...
            'DisplayName', endName);

        if k > 1
            set(hStart(k), 'HandleVisibility', 'off');
            set(hEnd(k), 'HandleVisibility', 'off');
        end
    end

    % Asset labels on first slice.
    labelOffset = 0.06;
    text(xRef(1), simplexYZ(1,1), simplexYZ(1,2) + labelOffset, string(assetNames{1}), ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(xRef(1), simplexYZ(2,1) + labelOffset, simplexYZ(2,2) - labelOffset/2, string(assetNames{2}), ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    text(xRef(1), simplexYZ(3,1) - labelOffset, simplexYZ(3,2) - labelOffset/2, string(assetNames{3}), ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'right');

    if isempty(dateVec)
        xlabel('Time');
    else
        xlabel('Date');
        xticks(xRef(sampleIdx));
        xticklabels(cellstr(datestr(dateVec(sampleIdx), 'yyyy-mm-dd')));
        xtickangle(45);
    end
    ylabel('Simplex X');
    zlabel('Simplex Y');
    title('3-Asset Allocation Trajectories on the r=1 Simplex Tube');
    legend([hTraj(:).', hStart(1), hEnd(1)], [trajLabels, {'Start', 'End'}], ...
        'Location', 'best');
    grid on;
    view(38, 24);
    axis tight;
    box on;
    hold off;
end

function [trajLabels, sliceStride, dates] = resolveOptionalInputs(numTraj, arg3, arg4, arg5)
    trajLabels = [];
    sliceStride = [];
    dates = [];

    if isempty(arg3)
        sliceStride = arg4;
        dates = arg5;
        return;
    end

    if isLikelyTrajectoryLabels(arg3, numTraj)
        trajLabels = arg3;
        sliceStride = arg4;
        dates = arg5;
        return;
    end

    % Backward-compatible overloads:
    %   plotWeightsChange(W, assetNames, sliceStride)
    %   plotWeightsChange(W, assetNames, sliceStride, dates)
    %   plotWeightsChange(W, assetNames, dates)
    if isValidStride(arg3)
        sliceStride = arg3;
        dates = arg4;
    else
        dates = arg3;
        if ~isempty(arg4) || ~isempty(arg5)
            error('Ambiguous optional arguments. Use trajLabels, sliceStride, dates ordering.');
        end
    end
end

function tf = isLikelyTrajectoryLabels(value, numTraj)
    if ischar(value)
        tf = true;
        return;
    end

    if isstring(value) || iscellstr(value)
        if numTraj == 1
            tf = numel(value) == 1;
        else
            tf = numel(value) == numTraj;
        end
        return;
    end

    tf = false;
end

function tf = isValidStride(value)
    tf = isnumeric(value) && isscalar(value) && isfinite(value) && value >= 1;
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

function dateVec = normalizeDates(dates, T)
    if isdatetime(dates)
        dateVec = dates(:);
    elseif isnumeric(dates)
        dateVec = datetime(dates(:), 'ConvertFrom', 'datenum');
    else
        dateVec = datetime(dates(:));
    end

    if numel(dateVec) == T + 1
        dateVec = dateVec(2:end);
    end
    if numel(dateVec) ~= T
        error('dates must have length T or T+1 to match each trajectory.');
    end
    if any(isnat(dateVec))
        error('dates contains invalid/NaT entries.');
    end
end
