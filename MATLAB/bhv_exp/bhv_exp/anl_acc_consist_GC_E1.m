function [acc, m_acc, f_acc, RT_mn, consist]=anl_acc_consist_GC_E1(fl_nm_array)

if nargin==0    
    res_fold=['bhv_results_E1/'];
    fl1=[res_fold, '/s01/s01_run1.txt'];
    fl_nm_array={fl1};
end

for fl_k=1:size(fl_nm_array, 1)
    fl_nm=char(fl_nm_array{1});
    dt=dlmread(fl_nm)
    if fl_k==1
        dt_mat=dt;
    else dt_mat=[dt_mat; dt];
    end
end
 
%Columns info in data file:  
%1. display side (left 1/right 0) 2. # indvd  3. # gend
%4. response (1-m, 2-f) 5. acc 6. RT

acc=nanmean(dt_mat(:, 5))

m_trials=find(dt_mat(:,3)==1);
f_trials=find(dt_mat(:,3)==2);

m_acc=nanmean(dt_mat(m_trials, 5));
f_acc=nanmean(dt_mat(f_trials, 5));

RT_mn=nanmean(dt_mat(:, 6))

ind_mat=zeros(120, 2);
for indvd_k=1:120
    pos=find(dt_mat(:, 2)'==indvd_k, 2, 'first');
    ind_mat(indvd_k, :)=pos;
end

resp_mat=[dt_mat(ind_mat(:,1), 4) dt_mat(ind_mat(:,2), 4)];
ind_nmb=isfinite(resp_mat(:, 1).*resp_mat(:, 2));
resp_mat=resp_mat(ind_nmb,:);

corr_dt=[resp_mat];
[RHO,PVAL] = corr(corr_dt);
consist=RHO(1,2)
% PVAL=PVAL
