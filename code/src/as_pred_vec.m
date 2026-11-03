function v = as_pred_vec(pred)
%AS_PRED_VEC Convert prediction-like object to a column vector.

if isnumeric(pred)
    v = pred(:);
    return;
end

if isstruct(pred)
    if isfield(pred,'v')
        v = pred.v(:);
        return;
    end
    if isfield(pred,'meas')
        v = pred.meas(:);
        return;
    end
end

error('as_pred_vec:invalidPrediction', ...
    'Prediction must be numeric or a struct with field .v or .meas.');
end
