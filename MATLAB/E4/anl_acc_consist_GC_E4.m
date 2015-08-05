function [RT_mn, consist, min, max, total_rightvote, total_leftvote, self_consist]=anl_acc_consist_GC_E4(fl_nm_array, subjid, run_number)
% Old function signature below:
% function [RT_mn, consist]=anl_acc_consist_GC_E4(fl_nm_array)
% Given result file obtained from bhv_exp_GC_E2, returns three elem
% vector indices specified to:
% 1 - mean reaction times, 2 - consistency

%% Read input data

% Default values; used for no input arguments
    res_fold='bhv_results_E4'; % results folder
if nargin==0    
    fl1=[res_fold, '/s04/s04_run6.txt']; % subject number
    fl_nm_array={fl1}; % copy array, maintaining nested levels
    subjid = 's04';
    run_number = 6;
end

% read entries of file
for fl_k=1:size(fl_nm_array, 1)
    fl_nm=char(fl_nm_array{1});
    dt=dlmread(fl_nm);
    if fl_k==1
        dt_mat=dt;
    else dt_mat=[dt_mat; dt]; %#ok<AGROW>
    end
end



%{
 Calculate values for output elem
 Indices for input vector as reference
 1 - img id for left hand side 
 2 - img id for right hand side 
 3 - response: 1: left more masculine, 2: right more masculine
 4 - RT_act
trial_id_code1 trial_id_code2 resp RT_act
%}

%% Mean reaction time
RT_mn=nanmean(dt_mat(:, 4));

%% Consistency calculations
    %{
        For each image, obtain the frequency in which it appears and the
        frequency in which it is rated as being more masculine/feminine.
        Estimate its masculinity/femininity relative to the other images in the
        set. Correlate this with the masculinity/femininity of rankings from
        experiment 2.
    %}
% import data
rate_data = importdata('../E2/gend_vect_rate.txt');


    %{
        Find the instances of the image in results file. Count the number 
        of times an image was voted as being more masculine. The 
        masculinity value is equal to the number of the votes over how many
        times the image was displayed. If an image does not appear this 
        run, give it a NaN value.
    %}
total_rightvote = 0;
total_leftvote = 0;

results=zeros(60, 1);
for indvd_k=61:120
    leftpos = find(dt_mat(:, 1) == indvd_k);
    rightpos = find(dt_mat(:, 2) == indvd_k);
    leftvote = sum(dt_mat(leftpos, 3) == 1);
    rightvote = sum(dt_mat(rightpos, 3) == 2);
    if  (numel(leftpos) + numel(rightpos)) > 0
        results(indvd_k - 60,:) = ...
            (leftvote + rightvote)/(numel(leftpos) + numel(rightpos));
    total_rightvote = total_rightvote + rightvote;
    total_leftvote = total_leftvote + leftvote;
    
    else
        results(indvd_k,:) = NaN;
    end
end


% Make a file to record the results of this run
new_rank_rec = [res_fold,'/', subjid, '/', subjid, '_run', num2str(run_number), '_fem_rank.txt'];
dlmwrite(new_rank_rec, results);

% Remove NaN values
trimmed_rate_data=rate_data(~isnan(results));
trimmed_results=results(~isnan(results));

% Sort by ascending femininity
[~,base_index] = sort(trimmed_rate_data, 1, 'ascend');
[~, res_index] = sort(trimmed_results, 1, 'ascend');

min = res_index(1);                                                                                                                                                                                                                                                                                                                                                                                                                                             
max = res_index(end);

% Correlation of the sets of indices
consist = corr(res_index, base_index);



% Calculate subject intra-consistency

%{
    This is super-duper messy at this time, but I can't think of how to
    implement intraconsistency calculation without tearing the current
    program apart. -- Cy
%}
% initialize a new set of intraconsistency records
old_rank_rec = zeros(60, 1);

% If an old intraconsistency file exists, read it in, 
% if not, create a new one
if run_number > 1;
    for run_k=(run_number-1):-1:1
        prev_rank_file = ...
            [res_fold, '/', subjid, '/', subjid, '_run', ...
            num2str(run_k), '_fem_rank.txt'];
        prev_rank_data = importdata(prev_rank_file);
        old_rank_rec = old_rank_rec + prev_rank_data;
    end
    
    prev_avg_rank = old_rank_rec/run_number;
    self_consist = corr(results, prev_avg_rank);

    

    
    

    
else
    % if an old subject intraconsistency file does not exist, make a new
    % one, and obviously, the first one is consistent with itself.
    
    self_consist = 1.0;
    
end

