function w_next = simple_ogd_update(w, r, eta, loss_func)
% OGD_STEP_SIMPLEX
% One online gradient descent step with projection onto simplex.
%
% w: n x 1 current weights
% r: n x 1 price relatives
% eta: step size
% loss_func: function that calculates the loss and returns its gradient
    ensure_dependency_paths();

    w_new = w - eta * loss_func(w, r);
    w_next = simplexProjection(w_new);
end

function ensure_dependency_paths()
    thisDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(thisDir);
    addpath(rootDir);

    utilsDir = fullfile(rootDir, 'utils');
    if isfolder(utilsDir)
        addpath(utilsDir);
    end
end
