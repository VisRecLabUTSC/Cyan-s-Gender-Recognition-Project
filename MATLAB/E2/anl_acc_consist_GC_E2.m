function [resp_std, RT_mn, consist]=anl_acc_consist_GC_E2(fl_nm_array)

% Given result file obtained from bhv_exp_GC_E2, returns three elem
% vector indices specified to: 1 - response standard deviation, 
% 2 - mean reaction times, 3 - consistency

% Default values; used for no input arguments
if nargin==0    
    res_fold=['bhv_results_E2/']; % results folder
    fl1=[res_fold, '/s01/s01_run2.txt']; % subject number
    fl_nm_array={fl1}; % copy array, maintaining nested levels
end

% read entries of file
for fl_k=1:size(fl_nm_array, 1)
    fl_nm=char(fl_nm_array{1});
    dt=dlmread(fl_nm)
    if fl_k==1
        dt_mat=dt;
    else dt_mat=[dt_mat; dt];
    end
end

% Calculate values for output elem
% Indices for input vector as reference
% 1 - lr_ind(trial_k) --> display side: (left 1/right 0), 
% 2 - trial_id_code --> individual 
% 3 - ord_gend_vect(trial_k, 1) --> individual's gender: (1-m/2-f)
% 4 - resp --> 1 masc :: 7 femn
% 5 - RT_act

resp_std=nanstd(dt_mat(:, 4))
RT_mn=nanmean(dt_mat(:, 5))

ind_mat=zeros(120, 2);
for indvd_k=1:120
    pos=find(dt_mat(:, 2)'==indvd_k, 2, 'first');
    ind_mat(indvd_k, :)=pos;
end

resp_mat=[dt_mat(ind_mat(:,1), 4) dt_mat(ind_mat(:,2), 4)]; % resp matrix
ind_nmb=isfinite(resp_mat(:, 1).*resp_mat(:, 2));
resp_mat=resp_mat(ind_nmb,:);

corr_dt=[resp_mat];
[RHO,PVAL] = corr(corr_dt);
consist=RHO(1,2)
% PVAL=PVAL
