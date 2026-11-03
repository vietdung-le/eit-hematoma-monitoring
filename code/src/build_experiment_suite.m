function cases = build_experiment_suite(cfg, suite_name)
% Create experiment definitions.
%
% Revision-5 additions:
%   - state_off is an explicit unupdated-geometry control;
%   - growth cases vary growth only (shift strength fixed at nominal value);
%   - shift_prior suite perturbs the inverse prior reference independently
%     of the truth sequence.

suite_name = string(suite_name);

switch suite_name
    case "demo"
        c = local_case('demo_full', cfg);
        c.description = "Main paper-style demo";
        cases = c;

    case "ablation"
        rows = {
            'full',       struct('use_contact_update',true, 'use_adapt',true, 'use_shift_model',true, 'use_shape_update',true, 'use_sigma_update',false), 'Ablation: full';
            'no_contact', struct('use_contact_update',false,'use_adapt',true, 'use_shift_model',true, 'use_shape_update',true, 'use_sigma_update',false), 'Ablation: no_contact';
            'no_adapt',   struct('use_contact_update',true, 'use_adapt',false,'use_shift_model',true, 'use_shape_update',true, 'use_sigma_update',false), 'Ablation: no_adapt';
            'no_shift',   struct('use_contact_update',true, 'use_adapt',true, 'use_shift_model',false,'use_shape_update',true, 'use_sigma_update',false), 'Ablation: no_shift';
            'state_off',  struct('use_contact_update',false,'use_adapt',false,'use_shift_model',false,'use_shape_update',false,'use_sigma_update',false), 'Control: state_off';
        };

        cases = repmat(local_case('tmp', cfg), size(rows,1), 1);
        for i = 1:size(rows,1)
            cases(i) = local_case(rows{i,1}, cfg);
            cases(i).overrides.flags = rows{i,2};
            cases(i).description = rows{i,3};
        end

    case "robustness"
        rows = {
            'rob_noise_low',    struct('noise_std_rel',0.002),         "Low noise";
            'rob_noise_mid',    struct('noise_std_rel',0.005),         "Mid noise";
            'rob_noise_high',   struct('noise_std_rel',0.010),         "High noise";
            'rob_contact_heavy',struct('contact_truth_jitter',0.40),   "Heavy contact drift";
            'rob_dropout_heavy',struct('bad_channel_fraction',0.10),   "Heavy bad-channel corruption";
            'rob_partial_8',    struct('n_elec_active',8),             "Only 8 active electrodes";
        };

        cases = repmat(local_case('tmp', cfg), size(rows,1), 1);
        for i = 1:size(rows,1)
            cases(i) = local_case(rows{i,1}, cfg);
            cases(i).overrides.scalar = rows{i,2};
            cases(i).description = rows{i,3};
        end

    case "growth"
        % Growth is varied independently; the base truth shift strength is
        % held at the same nominal value in all three cases.
        rows = {
            'growth_slow',   [0.00,0.01,0.02,0.03,0.04,0.05];
            'growth_medium', [0.00,0.015,0.03,0.045,0.06,0.08];
            'growth_fast',   [0.00,0.02,0.04,0.06,0.09,0.12];
        };

        cases = repmat(local_case('tmp', cfg), size(rows,1), 1);
        for i = 1:size(rows,1)
            cases(i) = local_case(rows{i,1}, cfg);
            cases(i).overrides.truth.growth_per_frame = rows{i,2};
            cases(i).overrides.truth.shift_strength = cfg.truth.shift_strength;
            cases(i).description = sprintf('Growth-only scenario %s', rows{i,1});
        end

    case "shift_prior"
        refs = [0.020, 0.035, 0.050, 0.065, 0.080];
        names = {'shift_prior_020','shift_prior_035','shift_prior_050', ...
                 'shift_prior_065','shift_prior_080'};
        cases = repmat(local_case('tmp', cfg), numel(refs), 1);
        for i = 1:numel(refs)
            cases(i) = local_case(names{i}, cfg);
            cases(i).overrides.inv.shift_prior_ref = refs(i);
            cases(i).description = sprintf('Shift-prior sensitivity: s_ref = %.3f', refs(i));
        end

    otherwise
        error('Unknown suite: %s', suite_name);
end
end

function c = local_case(name, cfg) %#ok<INUSD>
c = struct();
c.name = string(name);
c.description = '';
c.seed = cfg.random_seed;
c.overrides = struct();
end
