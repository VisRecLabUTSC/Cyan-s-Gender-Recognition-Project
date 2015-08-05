function consist=int_consist_GC_E4(subj1, subj2)
 res_fold='bhv_results_E4/'; % results folder
if nargin==0    
    subj1='s07'; % subject number
    subj2='s09';
end

% Initialize empty matrix for all runs
subj1_rank_data = zeros(60,6);
subj2_rank_data = zeros(60,6);

%{
Obtain results for both participants run by run and enter them into the
matrix initialized above.
%}
for run_k=1:6
    subj1_run = [res_fold, subj1, '/', subj1, '_run', num2str(run_k), '_fem_rank.txt'];
    subj2_run = [res_fold, subj2, '/', subj2, '_run', num2str(run_k), '_fem_rank.txt'];
    subj1_rank_data(:,run_k) = importdata(subj1_run);
    subj2_rank_data(:,run_k) = importdata(subj2_run);
end

% Average out the results
subj1_rank_avg = mean(subj1_rank_data,2);
subj2_rank_avg = mean(subj2_rank_data,2);

% Correlate them
consist = corr(subj1_rank_avg, subj2_rank_avg);