function labels = pretty_case_labels(case_names, multiline)
% Prettify case labels for plots. Underscores are removed to avoid TeX-like
% subscript rendering in figure tick labels.

if nargin < 2
    multiline = false;
end

names = string(case_names);
labels = strings(size(names));
for i = 1:numel(names)
    s = lower(strtrim(names(i)));
    switch s
        case "conductivity_only"
            label = "legacy-state-off";
        case "state_off"
            label = "state-off";
        case "demo_full"
            label = "demo-full";
        case "full"
            label = "proposed";
        case "growth_slow"
            label = "growth-slow";
        case "growth_medium"
            label = "growth-medium";
        case "growth_fast"
            label = "growth-fast";
        case "no_contact"
            label = "no-contact";
        case "no_adapt"
            label = "no-adapt";
        case "no_shift"
            label = "no-shift";
        case "rob_contact_heavy"
            label = "contact-heavy";
        case "rob_dropout_heavy"
            label = "dropout-heavy";
        case "rob_noise_low"
            label = "noise-low";
        case "rob_noise_mid"
            label = "noise-mid";
        case "rob_noise_high"
            label = "noise-high";
        case "rob_partial_8"
            label = "partial-8";
        otherwise
            if startsWith(s, "shift_prior_")
                label = replace(s, "shift_prior_", "prior-");
            else
                label = replace(s, '_', '-');
            end
    end

    if multiline
        toks = split(replace(label, '-', ' '));
        if numel(toks) >= 2
            label = join(toks(1:min(2,end)), newline);
            if numel(toks) > 2
                label = label + newline + join(toks(3:end), ' ');
            end
        end
    end
    labels(i) = label;
end
labels = cellstr(labels);
end
