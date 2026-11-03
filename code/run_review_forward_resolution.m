function T = run_review_forward_resolution(meshNames)
%RUN_REVIEW_FORWARD_RESOLUTION Quick diagnostic BEFORE costly inversion.
% Repository layout: this file is already in code/, alongside config/ and src/.
%
%   T = run_review_forward_resolution();
%   T = run_review_forward_resolution({'b2c','c2c','d2c'});
%
% Tests a NO-GROWTH and 10/20/30 percent FINAL-AREA-GROWTH condition,
% keeping the same forward-law, contacts and open-arc 56-measurement protocol
% as run_review_24h.m.  Deliberately uses NO INVERSE RECONSTRUCTION.
% Output: results_review24h/forward_signal_resolution.csv
%
% The expected noise norm is a reference calculation, not observed noise;
% a signal/noise ratio > 1 here does NOT prove statistical detectability.
%
% No original code files are modified. This script has NOT been executed on
% MATLAB/EIDORS in the assistant environment. Check output and warnings.

if nargin<1 || isempty(meshNames), meshNames={'b2c','c2c'}; end
if isstring(meshNames), meshNames=cellstr(meshNames); end
if ischar(meshNames), meshNames={meshNames}; end
root = fileparts(mfilename('fullpath'));
addpath(root,'-begin');
addpath(fullfile(root,'config'),'-begin');
addpath(fullfile(root,'src'),'-begin');
cfg = q1_config();
setup_paths(cfg);
if exist('mk_common_model','file') ~= 2
    error('ForwardResolution:NoEIDORS','EIDORS startup failed; check EIDORS_PATH.');
end
outdir=fullfile(root,'results_review24h');
if exist(outdir,'dir')~=7, mkdir(outdir); end
rows=cell(0,9);
for im=1:numel(meshNames)
    meshName=char(meshNames{im});
    fprintf('\nResolution check: truth mesh %s\n',meshName);
    try
        cc=cfg;
        cc.mesh_schedule={meshName};
        cc.flags.use_adapt=false;
        [state,truth]=build_head_model(cc);
        [state,truth]=make_open_arc_56(state,truth);
        nElems=size(state.fwd_model.elems,1);
        p0=nominal_truth(cc,0);
        im0=independent_truth_image(truth.base_img,p0,cc);
        v0=as_pred_vec(fwd_solve(im0));
        v0=v0(:);
        if numel(v0)~=56
            error('ForwardResolution:DataCount','Expected 56 voltages, got %d.',numel(v0));
        end
        expected_sigma=max(cc.noise_std_rel * ...
            max(std(v0), 0.20*mean(abs(v0))),1e-6);
        expected_noise_norm=sqrt(numel(v0))*expected_sigma;
        for pct=[0 10 20 30]
            tt=tic;
            p=nominal_truth(cc,pct);
            im2=independent_truth_image(truth.base_img,p,cc);
            v2=as_pred_vec(fwd_solve(im2));
            v2=v2(:);
            delta=norm(v2-v0);
            changed=nnz(im0.elem_data ~= im2.elem_data);
            relative_delta=delta/max(norm(v0),eps);
            signal_over_noise=delta/max(expected_noise_norm,eps);
            runtime=toc(tt);
            rows(end+1,:)={string(meshName),nElems,pct,changed,delta, ...
                relative_delta,expected_noise_norm,signal_over_noise,runtime}; %#ok<AGROW>
            fprintf(' mesh %s, +%2d%%: %5d changed elements, voltage ratio %.9g, ', ...
                meshName,pct,changed,relative_delta);
            fprintf('signal/expected noise %.5f (%.1fs)\n',signal_over_noise,runtime);
        end
    catch ME
        warning('ForwardResolution:MeshFailed','Mesh %s failed: %s',meshName,ME.message);
        rows(end+1,:)={string(meshName),NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN}; %#ok<AGROW>
    end
    T=cell2table(rows,'VariableNames',{'mesh','elements','growth_percent', ...
        'changed_elements','voltage_delta_norm','voltage_delta_relative', ...
        'expected_noise_norm','signal_to_expected_noise','elapsed_sec'});
    writetable(T,fullfile(outdir,'forward_signal_resolution.csv'));
end
fprintf('\nSaved: %s\n',fullfile(outdir,'forward_signal_resolution.csv'));
end

function p=nominal_truth(cfg,pct)
ax=cfg.truth.ax0; ay=cfg.truth.ay0;
ratio=1+pct/100;
b=ay+0.75*ax;
g=(-b+sqrt(b*b+3*ax*ay*(ratio-1)))/1.5;
p=struct('cx',cfg.truth.cx0,'cy',cfg.truth.cy0, ...
    'ax',ax+g,'ay',ay+0.75*g,'rot',deg2rad(cfg.truth.rotation_deg), ...
    'shift_strength',cfg.truth.shift_strength,'sigma_brain',cfg.sigma_brain);
end

function img=independent_truth_image(base_img,p,cfg)
% Exact same alternative Gaussian + tangential support mapping as in
% run_review_24h.m; inspect true voltage resolution, NOT inverse accuracy.
img=base_img;
cent=interp_mesh(base_img.fwd_model);
rr=sqrt(sum(cent.^2,2));
img.elem_data(rr<=0.78)=p.sigma_brain;
core=make_hematoma_mask(cent,p.cx,p.cy,p.ax,p.ay,p.rot);
img.elem_data(core)=cfg.sigma_blood;
halo=make_hematoma_mask(cent,p.cx,p.cy,1.18*p.ax,1.18*p.ay,p.rot)&~core;
img.elem_data(halo)=0.65*cfg.sigma_blood+0.35*p.sigma_brain;
v=cent(:,1:2)-[p.cx,p.cy];
r=sqrt(sum(v.^2,2));
u=v./max(r,1e-8);
d=1.8*p.shift_strength*exp(-0.5*(r/0.24).^2) .* ...
    [u(:,1)-0.20*u(:,2),u(:,2)+0.20*u(:,1)];
warped=cent;
warped(:,1:2)=cent(:,1:2)-d;
mask=make_hematoma_mask(warped,p.cx,p.cy,p.ax,p.ay,p.rot);
img.elem_data(mask)=cfg.sigma_blood;
rim=make_hematoma_mask(warped,p.cx,p.cy,1.12*p.ax,1.12*p.ay,p.rot)&~mask;
img.elem_data(rim)=0.50*cfg.sigma_blood+0.50*p.sigma_brain;
end

function [state,truth]=make_open_arc_56(state,truth)
fmdl=state.fwd_model;
a=state.active_electrodes(:).';
if numel(a)~=10 || numel(fmdl.electrode)~=16
    error('ForwardResolution:Electrodes','Requires 10 active of 16 electrodes.');
end
stim=repmat(struct('stim_pattern',[],'meas_pattern',[], ...
    'stimulation','Amp'),numel(a)-1,1);
total=0;
for k=1:numel(a)-1
    src=a(k); sink=a(k+1);
    I=zeros(numel(fmdl.electrode),1);
    I(src)=1;I(sink)=-1;
    M=zeros(0,numel(fmdl.electrode));
    for j=1:numel(a)-1
        aa=a(j);bb=a(j+1);
        if any([aa,bb]==src) || any([aa,bb]==sink),continue;end
        row=zeros(1,numel(fmdl.electrode));row(aa)=1;row(bb)=-1;
        M=[M;row]; %#ok<AGROW>
    end
    stim(k).stim_pattern=I;stim(k).meas_pattern=M;
    total=total+size(M,1);
end
if total~=56,error('ForwardResolution:Protocol','Unexpected count %d',total);end
fmdl.stimulation=stim;
fmdl.meas_select=true(total,1);
state.fwd_model=fmdl;
truth.base_img.fwd_model=fmdl;
end
