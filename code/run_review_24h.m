function T = run_review_24h(mode, n)
%RUN_REVIEW_24H Targeted, checkpointed reviewer experiments for MATLAB/EIDORS.
% Repository layout: this file is already in code/, alongside config/ and src/.
%
%   run_review_24h('preflight')       % check actual forward vs inverse mesh
%   run_review_24h('pilot')           % one static mismatched-mesh pair
%   run_review_24h('configs', 5)      % first 5/50 random 1-frame anatomies
%   run_review_24h('configs', 50)     % continue to 50, resume on restart
%   run_review_24h('growth', 1)       % no/10/20/30%% growth, one noise seed
%   run_review_24h('growth', 3)       % continue growth to 3 seeds per level
%   run_review_24h('summary')         % print paired / growth tables
%
% Critical scope: this is an EXPLORATORY numerical test, not full mechanical
% shift validation, 3D modelling, or evidence for clinical performance.
% Truth uses a finer EIDORS mesh and an ALTERNATIVE Gaussian-shear support
% displacement surrogate. Inversion retains the existing exponential law.
% Pilot protocol explicitly uses 9 physical adjacent drives (E1--E2 ... E9--E10)
% on an open ten-electrode arc, with 56 retained voltage differences.
% One-frame randomized-geometry tests do not establish temporal tracking.

if nargin < 1 || isempty(mode), mode = 'preflight'; end
if nargin < 2 || isempty(n), n = 0; end
root = fileparts(mfilename('fullpath'));
addpath(root, '-begin');
addpath(fullfile(root,'config'), '-begin');
addpath(fullfile(root,'src'), '-begin');
cfg = q1_config();
setup_paths(cfg);
if exist('mk_common_model','file') ~= 2
    error('Review24h:MissingEIDORS', 'EIDORS not detected. Set EIDORS_PATH and restart MATLAB.');
end
outdir = fullfile(root,'results_review24h');
if exist(outdir,'dir') ~= 7, mkdir(outdir); end
csvfile = fullfile(outdir, 'runs.csv');
mode = lower(string(mode));

[coarse, fine] = review_mesh_check(cfg, outdir);
if mode == "preflight"
    T = table(); return;
end

if mode == "summary"
    T = review_read_table(csvfile);
    review_print_summary(T);
    return;
end

T = review_read_table(csvfile);
switch mode
    case "pilot"
        cfgCase = review_base_case(cfg);
        cfgCase.truth.growth_per_frame = 0;
        cfgCase.n_frames = 1;
        cfgCase = review_static_spec(cfgCase, 1);
        T = review_paired_run(T, csvfile, outdir, 'pilot_mismatch_1frame', ...
            cfgCase, coarse, fine, cfg.random_seed, true, 'pilot', NaN);
    case "configs"
        if n == 0, n = 50; end
        validateattributes(n,{'double'},{'scalar','integer','>=',1,'<=',200});
        for i = 1:n
            cfgCase = review_base_case(cfg);
            cfgCase.n_frames = 1;
            cfgCase.truth.growth_per_frame = 0;
            cfgCase = review_static_spec(cfgCase, i);
            name = sprintf('geometry_%03d',i);
            seed = 20270000+i;
            T = review_paired_run(T,csvfile,outdir,name,cfgCase,coarse,fine,seed,true,'geometry',NaN);
        end
    case "growth"
        if n == 0, n = 3; end
        validateattributes(n,{'double'},{'scalar','integer','>=',1,'<=',10});
        for j = 1:n
            for pct = [0 10 20 30]
                cfgCase = review_base_case(cfg);
                cfgCase.n_frames = 6;
                cfgCase.truth.growth_per_frame = ...
                    linspace(0,review_increment_for_area_ratio(1+pct/100, cfgCase),6);
                name = sprintf('growth_%02dpct_seed%02d',pct,j);
                seed = 20273000+j;
                T = review_paired_run(T,csvfile,outdir,name,cfgCase,coarse,fine,seed,true,'growth',pct);
            end
        end
    otherwise
        error('Review24h:BadMode','Use preflight, pilot, configs, growth or summary.');
end
review_print_summary(T);
fprintf('\nResults: %s\n',csvfile);
end

function cfgCase = review_base_case(cfg)
cfgCase = cfg;
cfgCase.mesh_schedule = {cfg.mesh_schedule{1}};
cfgCase.flags.use_adapt = false; % enforce a fixed INVERSE mesh
% Disable the injected corruption-mask weights, which leak generator truth.
% This sets all supplied weights to 1, not a newly validated blind detector.
cfgCase.flags.use_bad_channel_weights = false;
% All other inverse settings (contact, four passes, penalties) are unchanged.
end

function [coarse,fine] = review_mesh_check(cfg,outdir)
coarse = char(cfg.mesh_schedule{1});
try
    c = mk_common_model(coarse,cfg.n_elec_total);
    nc = size(c.fwd_model.elems,1);
catch ME
    error('Review24h:CoarseModel','Coarse model %s failed: %s',coarse,ME.message);
end
fine = '';
nf = NaN;
for i=2:numel(cfg.mesh_schedule)
    candidate = char(cfg.mesh_schedule{i});
    try
        test = mk_common_model(candidate,cfg.n_elec_total);
        nk = size(test.fwd_model.elems,1);
        if nk > nc, fine = candidate; nf=nk; break; end
    catch ME
        fprintf('Fine mesh %s skipped: %s\n',candidate,ME.message);
    end
end
if isempty(fine)
    error('Review24h:NoFineMesh', ...
        'No valid mesh with MORE than %d elements was found. Do not claim independent meshes.',nc);
end
fprintf('Review24h: inverse=%s (%d elems), truth=%s (%d elems)\n',coarse,nc,fine,nf);
meshTbl = table(string(coarse),nc,string(fine),nf, ...
    'VariableNames',{'inverse_mesh','inverse_elems','truth_mesh','truth_elems'});
writetable(meshTbl,fullfile(outdir,'mesh_preflight.csv'));
end

function cfg = review_static_spec(cfg,i)
% 50 reproducible, distinct geometry + initial-state draws. These are not
% noise-only replicas. Draws are fixed by geometry ID; do not tune on results.
rng(920000+i,'twister');
radius = 0.06+0.29*sqrt(rand());
phi = 2*pi*rand();
cfg.truth.cx0 = radius*cos(phi);
cfg.truth.cy0 = radius*sin(phi);
cfg.truth.ax0 = 0.075+0.080*rand();
cfg.truth.ay0 = 0.060+0.055*rand();
cfg.truth.rotation_deg = -40+80*rand();
cfg.inv.cx0 = -0.28+0.56*rand();
cfg.inv.cy0 = -0.28+0.56*rand();
cfg.inv.ax0 = 0.065+0.10*rand();
cfg.inv.ay0 = 0.055+0.075*rand();
cfg.inv.rotation_deg0 = 5; % fixed inference angle as in published solver
cfg.inv.shift_strength0 = 0.015;
end

function T=review_paired_run(T,csvfile,outdir,name,cfg,coarse,fine,seed,do_no_shift,group,pct)
% Write each arm immediately to permit resumption after interruptions.
arms = {'full','no_shift'};
if ~do_no_shift, arms = {'full'}; end
need = false;
for a=1:numel(arms)
    if ~review_done(T,name,arms{a}), need = true; end
end
if ~need, fprintf('Skip completed pair %s\n',name); return; end
cfgTrue = cfg;
cfgTrue.mesh_schedule = {fine};
cfgTrue.truth.shift_strength = 0.050;
% Independent displacement surrogate keeps shift constant over growth.
cfgInv = cfg;
cfgInv.mesh_schedule = {coarse};
cfgInv.truth.shift_decay = 0.24; % original inverse exponential decay

fprintf('\nCASE %s / seed %d / group %s\n',name,seed,group);
rng(seed,'twister');
[modelFine,truth] = build_head_model(cfgTrue);
[modelFine,truth] = review_open_arc(modelFine,truth);
truth = review_generate_truth(modelFine,truth,cfgTrue);
meas = simulate_measurements(modelFine,truth,cfgTrue);
[modelCoarse,trash] = build_head_model(cfgInv); %#ok<ASGLU>
[modelCoarse,~] = review_open_arc(modelCoarse,trash);
if size(modelFine.fwd_model.elems,1) <= size(modelCoarse.fwd_model.elems,1)
    error('Review24h:MeshOrder','Data mesh must have more elements than inverse mesh.');
end
if numel(meas.voltage{1}) ~= 56
    error('Review24h:ProtocolCount', 'Expected 56 measurements for 9-drive open arc.');
end
if numel(meas.voltage{1}) ~= numel(forward_from_state(modelCoarse, ...
        review_initial_params(modelCoarse,cfgInv),cfgInv.contact0,cfgInv))
    error('Review24h:ChannelMismatch','Truth and inverse voltage lengths differ.');
end
for a=1:numel(arms)
    arm=arms{a};
    if review_done(T,name,arm), continue; end
    cfgArm=cfgInv;
    cfgArm.flags.use_shift_model=strcmp(arm,'full');
    t0=tic;
    try
        state = initialize_inverse_state(modelCoarse,cfgArm);
        pred = reconstruct_sequence(modelCoarse,truth,meas,state,cfgArm);
        metrics = evaluate_metrics(pred,truth,meas,cfgArm);
        tSec=toc(t0);
        nT=numel(pred.frames);
        tr=truth.params;
        pp1=pred.frames{1}.state.params;
        pp6=pred.frames{end}.state.params;
        areaTrue=(tr(end).ax*tr(end).ay)/(tr(1).ax*tr(1).ay);
        areaRec=(pp6.ax*pp6.ay)/max(pp1.ax*pp1.ay,1e-10);
        areaError=areaRec-areaTrue;
        row=review_row(name,arm,group,seed,pct,metrics,tSec, ...
            areaTrue,areaRec,areaError,pp6.ax,pp6.ay,'OK');
        fprintf('  %s: ellipseDice=%.4f centreErr=%.4f areaTrue=%.4f areaRec=%.4f time=%.1fs\n', ...
            arm,metrics.mean_ellipse_dice,metrics.mean_centroid_error,areaTrue,areaRec,tSec);
        % Save a compact, auditable record, including observed and clean data;
        % do not overwrite historical simulation bundles.
        file=fullfile(outdir,[name '_' arm '.mat']);
        estimated=cell(nT,1);
        for k=1:nT,estimated{k}=pred.frames{k}.state.params; end
        truth_params=truth.params; %#ok<NASGU>
        observation=meas.voltage; observation_clean=meas.voltage_clean; %#ok<NASGU>
        config_truth=cfgTrue; config_inverse=cfgArm; %#ok<NASGU>
        save(file,'truth_params','estimated','observation','observation_clean', ...
            'config_truth','config_inverse','seed','metrics','tSec','-v7');
    catch ME
        tSec=toc(t0);
        warning('Review24h:RunError','Case %s, arm %s: %s',name,arm,ME.message);
        row=review_row(name,arm,group,seed,pct,struct(),tSec, ...
            NaN,NaN,NaN,NaN,NaN,['ERROR: ' ME.message]);
    end
    T=[T;row]; %#ok<AGROW>
    writetable(T,csvfile);
end
end

function p=review_initial_params(modelState,cfg)
s=initialize_inverse_state(modelState,cfg);p=s.params;
end

function [state,truth] = review_open_arc(state,truth)
% Physically adjacent electrodes on the OPEN arc E1,...,E10 of 16
% electrodes. This does not connect E10 to E1 (the historical artefact).
fmdl=state.fwd_model;
active=state.active_electrodes(:).';
n_total=numel(fmdl.electrode);
na=numel(active);
if na~=10 || n_total~=16
    error('Review24h:Electrodes', 'Expected ten active electrodes on the 16-electrode head.');
end
stim=repmat(struct('stim_pattern',[],'meas_pattern',[], ...
                   'stimulation','Amp'),na-1,1);
total=0;
for k=1:na-1
    src=active(k);snk=active(k+1);
    I=zeros(n_total,1);I(src)=1;I(snk)=-1;
    M=zeros(0,n_total);
    for j=1:na-1
        a=active(j);b=active(j+1);
        if any([a,b]==src) || any([a,b]==snk),continue;end
        row=zeros(1,n_total);row(a)=1;row(b)=-1;
        M=[M;row]; %#ok<AGROW>
    end
    stim(k).stim_pattern=I;
    stim(k).meas_pattern=M;
    total=total+size(M,1);
end
if total~=56
    error('Review24h:BadProtocol', 'Open arc count should be 56, got %d.',total);
end
fmdl.stimulation=stim;
fmdl.meas_select=true(total,1);
state.fwd_model=fmdl;
state.img_background.fwd_model=fmdl;
state.imdl.fwd_model=fmdl;
state.contact_proj=build_contact_projection(fmdl);
truth.base_img.fwd_model=fmdl;
end

function truth=review_generate_truth(modelFine,truth,cfg)
nT=cfg.n_frames;
frames=cell(nT,1);
params=repmat(struct('cx',0,'cy',0,'ax',0,'ay',0, ...
   'rot',0,'shift_strength',0,'sigma_brain',0),nT,1);
for t=1:nT
    p=struct();
    p.cx=cfg.truth.cx0; p.cy=cfg.truth.cy0;
    p.ax=cfg.truth.ax0+cfg.truth.growth_per_frame(t);
    p.ay=cfg.truth.ay0+0.75*cfg.truth.growth_per_frame(t);
    p.rot=deg2rad(cfg.truth.rotation_deg);
    p.shift_strength=cfg.truth.shift_strength; % UNCOUPLED from growth
    p.sigma_brain=cfg.sigma_brain;
    frames{t}=review_alt_truth_img(truth.base_img,p,cfg);
    params(t)=p;
end
truth.frames=frames;truth.params=params;
end

function img=review_alt_truth_img(base_img,p,cfg)
% Alternative TRUTH support law: Gaussian radial decay + 20% tangential
% shear; not EIDORS original exponential purely radial law. This is still a
% mathematical surrogate, NOT a validated biomechanical shift model.
img=base_img;
cent=interp_mesh(base_img.fwd_model);
rr=sqrt(sum(cent.^2,2));
img.elem_data(rr<=0.78)=p.sigma_brain;
core=make_hematoma_mask(cent,p.cx,p.cy,p.ax,p.ay,p.rot);
img.elem_data(core)=cfg.sigma_blood;
halo=make_hematoma_mask(cent,p.cx,p.cy,1.18*p.ax,1.18*p.ay,p.rot)&~core;
img.elem_data(halo)=0.65*cfg.sigma_blood+0.35*p.sigma_brain;
v=cent(:,1:2)-[p.cx p.cy];
r=sqrt(sum(v.^2,2));
u=v./max(r,1e-8);
% This deliberately differs in SHAPE and DECAY from the inverse kernel.
d=1.8*p.shift_strength*exp(-0.5*(r/0.24).^2).*[u(:,1)-0.20*u(:,2), u(:,2)+0.20*u(:,1)];
warped=cent;
warped(:,1:2)=cent(:,1:2)-d;
mask=make_hematoma_mask(warped,p.cx,p.cy,p.ax,p.ay,p.rot);
img.elem_data(mask)=cfg.sigma_blood;
rim=make_hematoma_mask(warped,p.cx,p.cy,1.12*p.ax,1.12*p.ay,p.rot)&~mask;
img.elem_data(rim)=0.50*cfg.sigma_blood+0.50*p.sigma_brain;
end

function g=review_increment_for_area_ratio(ratio,cfg)
% (ax0+g)*(ay0+0.75*g) / (ax0*ay0) = ratio.
ax=cfg.truth.ax0;ay=cfg.truth.ay0;
b=ay+0.75*ax;
g=(-b+sqrt(b*b+3*ax*ay*(ratio-1)))/1.5;
end

function tf=review_done(T,name,arm)
tf=~isempty(T)&&any(string(T.case_name)==string(name) & ...
    string(T.arm)==string(arm) & string(T.status)=="OK");
end

function T=review_read_table(path)
if exist(path,'file') == 2
    T=readtable(path,'TextType','string');
else
    T=review_row('','','',0,NaN,struct(),NaN,NaN,NaN,NaN,NaN,NaN,'');
    T(1,:)=[];
end
end

function T=review_row(name,arm,grp,seed,pct,metrics,runtime,trueRatio,recRatio,err,ax,ay,status)
T=table(string(name),string(arm),string(grp),double(seed),double(pct), ...
    double(review_field(metrics,'mean_ellipse_dice')), ...
    double(review_field(metrics,'mean_dice')), ...
    double(review_field(metrics,'mean_centroid_error')), ...
    double(review_field(metrics,'mean_contact_rel_error')), ...
    double(review_field(metrics,'mean_relative_residual')), ...
    double(runtime),double(trueRatio),double(recRatio),double(err), ...
    double(ax),double(ay),string(status), ...
    'VariableNames',{'case_name','arm','group','seed','growth_percent','ellipse_dice', ...
    'box_dice','centroid_error','contact_error','weighted_norm','runtime_sec', ...
    'area_ratio_true','area_ratio_est','area_ratio_error','last_ax','last_ay','status'});
end

function v=review_field(st,name)
v=NaN;
if isstruct(st) && isfield(st,name) && isnumeric(st.(name))
    v=st.(name);
end
end

function review_print_summary(T)
if isempty(T)
    fprintf('No completed results yet.\n');return;
end
valid=(string(T.status)=="OK");
fprintf('\n======= REVIEW24H RESULTS =======\n');
fprintf('Completed %d / total rows %d.\n',nnz(valid),height(T));
M=T(valid,:);
for group=["pilot","geometry","growth"]
    G=M(string(M.group)==group,:);
    if isempty(G),continue;end
    full=G(string(G.arm)=="full",:);
    nsh=G(string(G.arm)=="no_shift",:);
    [names,ia,ib]=intersect(string(full.case_name),string(nsh.case_name)); %#ok<ASGLU>
    fprintf('Group %s: completed full %d, no-shift %d, matched pairs %d\n',group,height(full),height(nsh),numel(ia));
    if numel(ia)>1
        d=full.ellipse_dice(ia)-nsh.ellipse_dice(ib);
        fprintf('  Paired ellipse-Dice full - no-shift: mean %+0.4f, SD %.4f (n=%d)\n', ...
            mean(d),std(d),numel(d));
    end
    if group == "growth" && ~isempty(full)
        for pct=[0 10 20 30]
            k=full.growth_percent==pct;
            if any(k)
                fprintf('  area growth %d%%: %d runs, truth ratio %.3f, estimated ratio %.3f, mean error %+.3f\n', ...
                    pct,nnz(k),mean(full.area_ratio_true(k)), ...
                    mean(full.area_ratio_est(k)),mean(full.area_ratio_error(k)));
            end
        end
    end
end
fprintf('DO NOT report any pilot as clinical or 50-scenario longitudinal validation.\n');
end
