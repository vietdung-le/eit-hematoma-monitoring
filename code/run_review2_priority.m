function T = run_review2_priority(mode, n)
%RUN_REVIEW2_PRIORITY Targeted, short reviewer-2 tests on existing EIT data.
% Keep these files in repository code/, next to config/ and src/.
%
% FAST (no EIDORS forward solves):
%   run_review2_priority('audit');
%   run_review2_priority('summary');
%
% MATLAB/EIDORS REQUIRED:
%   run_review2_priority('truth_residual');  % six truth-state evaluations
%   run_review2_priority('contact_trace');   % audit contact-gate decisions in saved 6-frame sequence
%   run_review2_priority('contact_stress');  % x2, x5, x10 contact, one frame
%   run_review2_priority('oracle');          % truth vs nominal initialization
%   run_review2_priority('lambda',2);        % lambda_s=0 and nominal
%   run_review2_priority('lambda',4);        % optional 4-value sweep
%
% These are DIAGNOSTICS on matched old data, not proof of a clinical shift,
% independent anatomical generality, or mesh convergence. The contact test
% is an intentionally stress-loaded synthetic one-frame experiment.
%
% Every output is written under results_review2_priority/ ; no original file
% is replaced. A test that has not run must not be reported as completed.

if nargin < 1 || isempty(mode), mode = 'audit'; end
if nargin < 2 || isempty(n), n = 2; end
mode = lower(char(mode));
root = fileparts(mfilename('fullpath'));
addpath(root,'-begin');
addpath(fullfile(root,'config'),'-begin');
addpath(fullfile(root,'src'),'-begin');
outdir = fullfile(root,'results_review2_priority');
if exist(outdir,'dir') ~= 7, mkdir(outdir); end
fullfileMAT = fullfile(root,'..','data','matched_model','full_bundle.mat');
if exist(fullfileMAT,'file') ~= 2
    error('Review2:MissingResults', [ 'Missing ../data/matched_model/full_bundle.mat in this repository.' ]);
end

switch mode
    case 'audit'
        T = local_audit(root,outdir);
    case 'summary'
        local_summary(outdir);
        T = table();
    case {'truth_residual','oracle','lambda','contact_trace','contact_stress'}
        cfgStartup = q1_config();
        setup_paths(cfgStartup);
        if exist('fwd_solve','file') ~= 2 || exist('mk_common_model','file') ~= 2
            error('Review2:EIDORSUnavailable', 'EIDORS missing. Check EIDORS_PATH then start MATLAB again.');
        end
        S = load(fullfileMAT,'out'); old = S.out;
        if strcmp(mode,'truth_residual')
            T = local_truth_residual(old,outdir);
        elseif strcmp(mode,'oracle')
            T = local_oracle(old,outdir);
        elseif strcmp(mode,'lambda')
            T = local_lambda(old,outdir,n);
        elseif strcmp(mode,'contact_trace')
            T = local_contact_trace(old,outdir);
        else
            T = local_contact_stress(old,outdir);
        end
    otherwise
        error('Review2:BadMode','Use audit, summary, truth_residual, contact_trace, contact_stress, oracle or lambda.');
end
end

function T = local_audit(root,outdir)
% Read the archived final predictions and per-electrode contact states.
% This is genuine retrospective analysis; no new reconstruction is implied.
arms = {'full','no_contact','no_shift','state_off'};
arm = strings(0,1); frnum=[]; electrode=[]; ztrue=[]; zstart=[]; zestimate=[];
ct_error=[]; base_error=[]; abs_err=[]; abs_err0=[];
F = table();
for a = 1:numel(arms)
    filename = fullfile(root,'..','data','matched_model',[arms{a} '_bundle.mat']);
    if exist(filename,'file') ~= 2
        fprintf('Skipping missing arm %s\n',arms{a}); continue;
    end
    X = load(filename,'out'); old = X.out;
    for t = 1:numel(old.results.frames)
        fr = old.results.frames{t};
        y = old.meas.voltage{t}(:); clean = old.meas.voltage_clean{t}(:);
        yp = as_pred_vec(fr.pred); yp = yp(:); w = old.meas.weights{t}(:);
        if numel(y) ~= numel(yp) || numel(y) ~= numel(w)
            error('Review2:DimMismatch', 'Predicted, measured and weighted voltages differ in size for %s frame %d.', arms{a},t);
        end
        zt = old.meas.z_true{t}(:); ze = fr.state.z(:); z0 = old.cfg.contact0(:);
        if numel(zt) ~= numel(ze) || numel(zt) ~= numel(z0)
            error('Review2:ContactDims','Contact vectors have inconsistent size.');
        end
        b = norm(ze-zt)/max(norm(zt),eps);
        b0 = norm(z0-zt)/max(norm(zt),eps);
        row = table(string(arms{a}),t, ...
          norm(y-yp),norm(y-yp)/max(norm(y),eps), ...
          norm((y-yp).*w),norm(y-clean)/max(norm(y),eps), ...
          b,b0,fr.obj,old.runtime_sec, ...
          'VariableNames',{'arm','frame','unweighted_norm','unweighted_relative', ...
          'solver_weighted_norm','noise_vs_clean_relative','contact_relative_estimate', ...
          'contact_relative_initial','objective','total_case_runtime_sec'});
        F = [F;row]; %#ok<AGROW>
        k = numel(zt);
        arm=[arm;repmat(string(arms{a}),k,1)]; %#ok<AGROW>
        frnum=[frnum;repmat(t,k,1)]; %#ok<AGROW>
        electrode=[electrode;(1:k)']; %#ok<AGROW>
        ztrue=[ztrue;zt]; zstart=[zstart;z0]; zestimate=[zestimate;ze]; %#ok<AGROW>
        ct_error=[ct_error;repmat(b,k,1)]; %#ok<AGROW>
        base_error=[base_error;repmat(b0,k,1)]; %#ok<AGROW>
        abs_err=[abs_err;abs(ze-zt)]; %#ok<AGROW>
        abs_err0=[abs_err0;abs(z0-zt)]; %#ok<AGROW>
    end
end
if isempty(F), error('Review2:NoData','No saved bundles found in results/.'); end
T = F;
E = table(arm,frnum,electrode,ztrue,zstart,zestimate,abs_err,abs_err0,ct_error,base_error, ...
  'VariableNames',{'arm','frame','electrode','true_contact','initial_contact','estimated_contact', ...
  'absolute_error_estimate','absolute_error_initial','frame_relative_estimate','frame_relative_initial'});
writetable(F,fullfile(outdir,'SAVED_FRAME_RESIDUAL_CONTACT_AUDIT.csv'));
writetable(E,fullfile(outdir,'SAVED_CONTACT_BY_ELECTRODE.csv'));
S = groupsummary(F,'arm','mean',{'unweighted_relative','solver_weighted_norm', ...
  'noise_vs_clean_relative','contact_relative_estimate','contact_relative_initial'});
writetable(S,fullfile(outdir,'SAVED_ARM_SUMMARY.csv'));
disp(S);
fprintf('Saved archived-data audit in %s\n',outdir);
end

function T = local_truth_residual(old,outdir)
% Compare clean/noisy data with an inverse-model forward solve at EXACT
% generator parameters and exact stored contact. Model errors can persist:
% simulator and inverse code use different contact-projection formulas.
cfg=old.cfg; ms=old.model_state0;
nf = numel(old.meas.voltage);
frame=zeros(nf,1);clean_model_relative=zeros(nf,1);
noise_model_relative=zeros(nf,1);noise_vs_clean_relative=zeros(nf,1);
truth_pred_relative_to_clean=zeros(nf,1);runtime_s=zeros(nf,1);
for t=1:nf
    tic;
    y=old.meas.voltage{t}(:); clean=old.meas.voltage_clean{t}(:);
    p=old.truth.params(t); z=old.meas.z_true{t}(:);
    pred=as_pred_vec(forward_from_state(ms,p,z,cfg));pred=pred(:);
    if numel(pred) ~= numel(y), error('Review2:PredDims','Forward truth prediction size mismatch.');end
    frame(t)=t;
    clean_model_relative(t)=norm(clean-pred)/max(norm(clean),eps);
    noise_model_relative(t)=norm(y-pred)/max(norm(y),eps);
    noise_vs_clean_relative(t)=norm(y-clean)/max(norm(y),eps);
    truth_pred_relative_to_clean(t)=norm(clean-pred)/max(norm(clean),eps);
    runtime_s(t)=toc;
    fprintf('Frame %d: clean-v-inverse truth model=%.5g, noisy-v-inverse=%.5g, noise-v-clean=%.5g\n', ...
      t,clean_model_relative(t),noise_model_relative(t),noise_vs_clean_relative(t));
end
T=table(frame,clean_model_relative,noise_model_relative,noise_vs_clean_relative,runtime_s);
writetable(T,fullfile(outdir,'TRUE_PARAMETER_FORWARD_RESIDUAL.csv'));
end

function T = local_oracle(old,outdir)
% One-frame matched-data diagnostic, frame 6, SAME measured voltages,
% SAME true contact at both starting points, no adaptive mesh, no weight
% information from corruption labels. Only starting geometry differs.
f = numel(old.meas.voltage); cfg=local_test_cfg(old.cfg);
meas=local_frame_meas(old,f); truth=local_frame_truth(old,f);
labels={'nominal_start','truth_start'};
rows=table();
for i=1:numel(labels)
    st=initialize_inverse_state(old.model_state0,cfg);
    st.z=old.meas.z_true{f}(:);st.prev_z=st.z;
    st.params.sigma_brain=old.cfg.sigma_brain;
    if i==2,st.params=old.truth.params(f);end
    st.prev_params=st.params;
    tic;
    res=reconstruct_sequence(old.model_state0,truth,meas,st,cfg);
    elapsed=toc;
    fr=res.frames{1};p=fr.state.params;pT=old.truth.params(f);
    y=meas.voltage{1}(:);pred=as_pred_vec(fr.pred);
    r=table(string(labels{i}),f,cfg.reg.lambda_shift, ...
      local_dice(p,pT),hypot(p.cx-pT.cx,p.cy-pT.cy), ...
      p.ax*p.ay/max(pT.ax*pT.ay,eps),p.shift_strength, ...
      norm(y-pred(:))/max(norm(y),eps),fr.obj,elapsed, ...
      'VariableNames',{'start','source_frame','lambda_shift','ellipse_dice', ...
      'centroid_error_head_radii','ellipse_area_ratio','estimated_shift', ...
      'unweighted_relative_residual','objective','runtime_sec'});
    rows=[rows;r]; %#ok<AGROW>
    fprintf('%s: Dice=%.4f; error=%.4f; relative residual=%.5g; elapsed %.2f s\n', ...
      labels{i},r.ellipse_dice,r.centroid_error_head_radii,r.unweighted_relative_residual,elapsed);
end
T=rows;writetable(T,fullfile(outdir,'ORACLE_INITIALIZATION_ONE_FRAME.csv'));
end

function T=local_lambda(old,outdir,n)
% One-frame sensitivity. All non-lambda settings are identical. This
% tests the PRESET local greedy search, not an optimally tuned estimator.
validateattributes(n,{'numeric'},{'scalar','integer','>=',1,'<=',4});
values=[0, old.cfg.reg.lambda_shift, 10*old.cfg.reg.lambda_shift,100*old.cfg.reg.lambda_shift];
frameIdx=numel(old.meas.voltage);ms=old.model_state0;
meas=local_frame_meas(old,frameIdx); truth=local_frame_truth(old,frameIdx);
rows=table();
for j=1:n
    cfg=local_test_cfg(old.cfg);
    cfg.reg.lambda_shift=values(j);
    st=initialize_inverse_state(ms,cfg);
    st.z=old.meas.z_true{frameIdx}(:);st.prev_z=st.z;
    st.params.sigma_brain=cfg.sigma_brain;st.prev_params=st.params;
    tic;res=reconstruct_sequence(ms,truth,meas,st,cfg);seconds=toc;
    fr=res.frames{1};p=fr.state.params;pT=old.truth.params(frameIdx);
    y=meas.voltage{1}(:);pred=as_pred_vec(fr.pred);pred=pred(:);
    r=table(values(j),frameIdx,local_dice(p,pT), ...
      hypot(p.cx-pT.cx,p.cy-pT.cy),p.ax*p.ay/max(pT.ax*pT.ay,eps), ...
      p.shift_strength,norm(y-pred)/max(norm(y),eps),fr.obj,seconds, ...
      'VariableNames',{'lambda_shift','source_frame','ellipse_dice', ...
      'centroid_error_head_radii','ellipse_area_ratio','estimated_shift', ...
      'unweighted_relative_residual','objective','runtime_sec'});
    rows=[rows;r]; %#ok<AGROW>
    fprintf('lambda_shift=%.5g; Dice %.4f; residual %.5g; elapsed %.2f s\n', ...
      values(j),r.ellipse_dice,r.unweighted_relative_residual,seconds);
    writetable(rows,fullfile(outdir,'LAMBDA_SHIFT_SWEEP_ONE_FRAME.csv'));
end
T=rows;
end

function T=local_contact_trace(old,outdir)
% Re-run the original six-frame full arm with only event counters added.
% Compare each regenerated prediction with the saved historical prediction.
% If code changed since the bundle was produced, counters describe the
% CURRENT code re-run, not the unrecorded original run.
cfg=old.cfg;
ms=old.model_state0;
st=initialize_inverse_state(ms,cfg);
tic;
res=r2_reconstruct_sequence_logged(ms,old.truth,old.meas,st,cfg);
sec=toc;
nf=numel(res.frames);
frame=(1:nf)';attempts=res.r2_contact_attempts(:);
accepted=res.r2_contact_accepts(:);
final_residual_relative=zeros(nf,1);contact_relative=zeros(nf,1);
historical_prediction_difference=zeros(nf,1);
for t=1:nf
    y=old.meas.voltage{t}(:);
    newpred=as_pred_vec(res.frames{t}.pred);
    savedpred=as_pred_vec(old.results.frames{t}.pred);
    if numel(newpred) ~= numel(savedpred)
        error('Review2:ReproductionDimension','Rerun and archived predictions have different lengths.');
    end
    historical_prediction_difference(t)=norm(newpred-savedpred)/max(norm(savedpred),eps);
    final_residual_relative(t)=norm(y-newpred)/max(norm(y),eps);
    zt=old.meas.z_true{t}(:);ze=res.frames{t}.state.z(:);
    contact_relative(t)=norm(zt-ze)/max(norm(zt),eps);
end
T=table(frame,attempts,accepted,final_residual_relative,contact_relative, ...
  historical_prediction_difference);
writetable(T,fullfile(outdir,'CONTACT_GATE_TRACE_6FRAMES.csv'));
fprintf('Contact attempted=%d, accepted=%d; total runtime %.1f s\n',sum(attempts),sum(accepted),sec);
fprintf('Max archived/rerun prediction difference=%.5g\n',max(historical_prediction_difference));
if max(historical_prediction_difference)>1e-6
    warning('Review2:HistoricalCodeDifference', ...
      'Rerun differs from archived predictions; report counter values as a fresh run, not as the old experiment.');
end
end

function T=local_contact_stress(old,outdir)
% One-frame systematic stress, exact truth geometry fixed, ordinary inverse
% contact model and stated original bounds. Factors x2, x5, x10 are applied
% to the nominal contact value. x10 EXCEEDS the original upper bound .060.
factors=[2;5;10];rows=table();ms=old.model_state0;
frameIdx=numel(old.meas.voltage);
p=old.truth.params(frameIdx);
for i=1:numel(factors)
    factor=factors(i);cfg=local_test_cfg(old.cfg);
    cfg.flags.use_shape_update=false;
    cfg.flags.use_contact_update=true;
    cfg.inv.contact_gate_mode='residual_only';
    z0=cfg.contact0(:);zt=factor*z0;
    fm=ms.fwd_model;
    for k=1:min(numel(fm.electrode),numel(zt))
        fm.electrode(k).z_contact=zt(k);
    end
    img=old.truth.frames{frameIdx};img.fwd_model=fm;
    clean=as_pred_vec(fwd_solve(img));clean=clean(:);
    if isfield(ms,'contact_proj') && ~isempty(ms.contact_proj)
        clean=clean+cfg.contact_forward_gain*ms.contact_proj*(zt-z0);
    end
    rng(404000+i,'twister');
    sigmaNoise=max(cfg.noise_std_rel*max(std(clean),0.2*mean(abs(clean))),1e-6);
    y=clean+sigmaNoise*randn(size(clean));
    meas=struct();meas.voltage={y};meas.weights={ones(size(y))};
    meas.weight=meas.weights;meas.z_true={zt};
    st=initialize_inverse_state(ms,cfg);
    st.params=p;st.prev_params=p;st.z=z0;st.prev_z=z0;
    predBefore=as_pred_vec(forward_from_state(ms,p,z0,cfg));predBefore=predBefore(:);
    tic;
    res=r2_reconstruct_sequence_logged(ms,local_frame_truth(old,frameIdx),meas,st,cfg);
    seconds=toc;f=res.frames{1};zest=f.state.z(:);
    predAfter=as_pred_vec(f.pred);predAfter=predAfter(:);
    b=norm(z0-zt)/max(norm(zt),eps);e=norm(zest-zt)/max(norm(zt),eps);
    boundHits=sum(abs(zest-cfg.contact_recon_bounds(1))<1e-8 | ...
      abs(zest-cfg.contact_recon_bounds(2))<1e-8);
    r=table(factor,frameIdx,double(any(zt>cfg.contact_recon_bounds(2))), ...
       b,e,norm(y-predBefore)/max(norm(y),eps), ...
       norm(y-predAfter)/max(norm(y),eps), ...
       res.r2_contact_attempts(1),res.r2_contact_accepts(1), ...
       boundHits,seconds, ...
       'VariableNames',{'contact_factor','source_frame','truth_exceeds_reconstruction_bounds', ...
       'initial_contact_error','estimated_contact_error','initial_unweighted_rel_residual', ...
       'final_unweighted_rel_residual','contact_attempts','contact_accepted', ...
       'electrodes_at_bounds','runtime_sec'});
    rows=[rows;r]; %#ok<AGROW>
    fprintf('contact x%.0f: initial err %.4f, final err %.4f, attempts %d, accepts %d (%.1f s)\n', ...
      factor,b,e,r.contact_attempts,r.contact_accepted,seconds);
    writetable(rows,fullfile(outdir,'CONTACT_STRESS_ONE_FRAME.csv'));
end
T=rows;
end

function cfg=local_test_cfg(cfg)
cfg.mesh_schedule={cfg.mesh_schedule{1}}; % matched original coarse mesh
cfg.flags.use_adapt=false;
cfg.flags.use_bad_channel_weights=false;
cfg.flags.use_contact_update=false;
cfg.inv.max_iter_per_frame=4;
% These tests do not secretly change the search bounds/step sizes.
end

function meas=local_frame_meas(old,t)
y=old.meas.voltage{t}(:);
meas=struct();meas.voltage={y};meas.weights={ones(size(y))};
meas.weight=meas.weights;meas.z_true={old.meas.z_true{t}};
end
function truth=local_frame_truth(old,t)
truth=old.truth;
truth.frames={old.truth.frames{t}};
truth.params=old.truth.params(t);
end
function d=local_dice(p,q)
% Same oriented parameter-ellipse grid approach as evaluate_metrics.m.
v=linspace(-1,1,301);[X,Y]=meshgrid(v,v);
A=local_mask(X,Y,p);B=local_mask(X,Y,q);
d=2*nnz(A&B)/max(nnz(A)+nnz(B),1);
end
function m=local_mask(X,Y,p)
dx=X-p.cx;dy=Y-p.cy;
u=cos(p.rot).*dx+sin(p.rot).*dy;
v=-sin(p.rot).*dx+cos(p.rot).*dy;
m=(u./max(p.ax,1e-6)).^2+(v./max(p.ay,1e-6)).^2<=1;
end
function local_summary(outdir)
files={'SAVED_ARM_SUMMARY.csv','TRUE_PARAMETER_FORWARD_RESIDUAL.csv', ...
       'ORACLE_INITIALIZATION_ONE_FRAME.csv','LAMBDA_SHIFT_SWEEP_ONE_FRAME.csv', ...
       'CONTACT_GATE_TRACE_6FRAMES.csv','CONTACT_STRESS_ONE_FRAME.csv'};
for i=1:numel(files)
    f=fullfile(outdir,files{i});
    if exist(f,'file')==2
        fprintf('\n== %s ==\n', files{i});
        disp(readtable(f));
    else
        fprintf('NOT RUN: %s\n',files{i});
    end
end
end
