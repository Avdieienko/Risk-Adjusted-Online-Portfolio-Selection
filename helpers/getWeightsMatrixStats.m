function [meanWeights, stdWeights] = getWeightsMatrixStats(weightsMatrix)
    % Given T x n matrix of weights, compute mean and standard deviation for each row
    meanWeights = mean(weightsMatrix, 2);
    stdWeights = std(weightsMatrix, 0, 2);
end