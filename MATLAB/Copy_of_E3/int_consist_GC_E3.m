function consist=int_consist_GC_E3(subj1, subj2)
 res_fold='bhv_results_E3/'; % results folder
if nargin==0    
    subj1='s01'; % subject number
    subj2='s04';
end

subj1_rank_data = zeros(60,6);
subj2_rank_data = zeros(60,6);

for run_k=1:6
    subj1_run = [res_fold, subj1, '/', subj1, '_run', num2str(run_k), '_masc_rank.txt'];
    subj2_run = [res_fold, subj2, '/', subj2, '_run', num2str(run_k), '_masc_rank.txt'];
    subj1_rank_data(:,run_k) = importdata(subj1_run);
    subj2_rank_data(:,run_k) = importdata(subj2_run);
end

subj1_rank_avg = mean(subj1_rank_data,2);
subj2_rank_avg = mean(subj2_rank_data,2);

consist = corr(subj1_rank_avg, subj2_rank_avg)