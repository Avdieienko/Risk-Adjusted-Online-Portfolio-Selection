function eta = simple_time_decay_eta(init_eta, t)
% SIMPLE_TIME_DECAY_ETA Returns a time-decaying learning rate for OGD.
    eta = init_eta / sqrt(t);
end