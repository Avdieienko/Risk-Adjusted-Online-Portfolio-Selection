function rt = stochastic_return_choice(R, t)
% STOCHASTIC_RETURN_CHOICE
% Randomly select one of the n price relatives at time t to use as the return vector.
    ensure_dependency_paths();
    [T, n] = size(R);
    if t < 1 || t > T
        error('t must be between 1 and T.');
    end
    if any(R(:) <= 0)
        error('Price relatives must be strictly positive.');
    end

    rt = R(t, randi(n))';
end