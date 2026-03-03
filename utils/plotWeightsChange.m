function plotWeightsChange(W, assetNames, sliceStride)
%PLOTWEIGHTSCHANGE Plot 3-asset weight trajectory as a simplex tube in time.
%   plotWeightsChange(W)
%   plotWeightsChange(W, assetNames)
%   plotWeightsChange(W, assetNames, sliceStride)
%
% Inputs:
%   W          - T x 3 portfolio weights over time
%   assetNames - optional names for the 3 assets
%   sliceStride- optional spacing between simplex slices in the tube

    if nargin < 2 || isempty(assetNames)
        assetNames = {'Asset 1', 'Asset 2', 'Asset 3'};
    end
    if nargin < 3 || isempty(sliceStride)
        sliceStride = max(1, floor(size(W,1) / 40));
    end

    if size(W,2) ~= 3
        error('plotWeightsChange expects W to be T x 3.');
    end
    if numel(assetNames) ~= 3
        error('assetNames must contain exactly 3 labels.');
    end
    if any(~isfinite(W(:)))
        error('W contains NaN or Inf values.');
    end

    % Keep simplex geometry valid despite tiny numerical drift.
    W = max(W, 0);
    rowSums = sum(W, 2);
    if any(rowSums <= 0)
        error('Each row of W must have positive total weight.');
    end
    W = W ./ rowSums;

    T = size(W, 1);
    t = (1:T)';

    % Equilateral 2D simplex vertices in (y,z), mapped through barycentric weights.
    simplexYZ = [
         0.00,  sqrt(3)/2;   % Asset 1 vertex
         0.50,  0.00;        % Asset 2 vertex
        -0.50,  0.00         % Asset 3 vertex
    ];

    trajYZ = W * simplexYZ;
    trajXYZ = [t, trajYZ];

    sampleIdx = unique([1:sliceStride:T, T]);
    edgePairs = [1 2; 2 3; 3 1];

    figure('Color', 'w', 'Name', 'Portfolio Weights in 3-Asset Simplex Tube');
    hold on;

    % Draw translucent side panels between sampled simplex slices.
    for k = 1:numel(sampleIdx)-1
        t1 = sampleIdx(k);
        t2 = sampleIdx(k+1);

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
                  'EdgeColor', 'none');
        end
    end

    % Draw simplex triangle outlines at sampled time slices.
    for k = 1:numel(sampleIdx)
        tk = sampleIdx(k);
        tri = [tk * ones(3,1), simplexYZ];
        patch('Vertices', tri, ...
              'Faces', [1 2 3], ...
              'FaceColor', [0.90 0.94 1.00], ...
              'FaceAlpha', 0.08, ...
              'EdgeColor', [0.35 0.45 0.65], ...
              'LineWidth', 0.7);
    end

    % Portfolio allocation trajectory through the tube.
    plot3(trajXYZ(:,1), trajXYZ(:,2), trajXYZ(:,3), ...
          'Color', [0.90 0.10 0.15], 'LineWidth', 2.2);
    scatter3(trajXYZ(1,1), trajXYZ(1,2), trajXYZ(1,3), 60, ...
             [0.00 0.60 0.00], 'filled');
    scatter3(trajXYZ(end,1), trajXYZ(end,2), trajXYZ(end,3), 60, ...
             [0.10 0.10 0.10], 'filled');

    % Asset labels on first slice.
    labelOffset = 0.06;
    text(1, simplexYZ(1,1), simplexYZ(1,2) + labelOffset, string(assetNames{1}), ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    text(1, simplexYZ(2,1) + labelOffset, simplexYZ(2,2) - labelOffset/2, string(assetNames{2}), ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    text(1, simplexYZ(3,1) - labelOffset, simplexYZ(3,2) - labelOffset/2, string(assetNames{3}), ...
         'FontWeight', 'bold', 'HorizontalAlignment', 'right');

    xlabel('Time');
    ylabel('Simplex X');
    zlabel('Simplex Y');
    title('3-Asset Allocation Trajectory on the r=1 Simplex Tube');
    grid on;
    view(38, 24);
    axis tight;
    box on;
    hold off;
end
