function design_ord_GC_E3(subj_k)
%% Stimuli ordering script
    %{ 
        Takes subject number as input, outputs a txt file
        of all possible pairings of stimuli in a pseudorandom
        order. Is read with bhv_exp_GC_E3.
    %}

% initialize random seed
RandStream.setGlobalStream ...
    (RandStream('mt19937ar','seed',sum(100*clock)))

% set defaults if no arguments provided
if nargin==0
    subj_k=0; 
end

% pseudorandomize stimulus order
tuples_ordered = nchoosek(1:60, 2);
perm_index = randperm(1770);

% initialize variables for loops
j = 1;
tuples_random(j,:) = tuples_ordered(perm_index(j),:);  % (*) okay when j=1 :)
tup_accum = [];

% loop checks condition: no image is repeated twice in a row
% details provided as follows...
for k = 2:1770
    
    %For every tuple, ensure that its entries do not appear twice 
    %in two consecutive tuples.
    if tuples_random(j,1) ~= tuples_ordered(perm_index(k),1) && ...
       tuples_random(j,1) ~= tuples_ordered(perm_index(k),2) && ...
       tuples_random(j,2) ~= tuples_ordered(perm_index(k),1) && ...
       tuples_random(j,2) ~= tuples_ordered(perm_index(k),2)
        j = j + 1;
        
        % Randomly assign the entries left and right positions. This 
        % if-block executes if and only if the tuple passes the above 
        % criteria.
        if randi(2) == 2
            tuples_random(j,:) = tuples_ordered(perm_index(k),:);  
        else
            tuples_random(j,:) = flip(tuples_ordered(perm_index(k),:));
        end
        
    else
        
        % accumulate rejected tuples
        tup_accum = [tup_accum;tuples_ordered(perm_index(k),:)]; %#ok<AGROW>
        
    end
end

% m is the index at which rejected tuples are inserted to tuples_random
m = size(tuples_random, 1) - 1;

while size(tup_accum, 1) > 0
    %{
    This if block checks for violations of the conditions
    outlined above. Obviously, this can be done far more
    parsimoniously by turning condition checking into a
    separate script but I'm lazy and the implementation
    turned out messier than I thought. In the interest of
    time and transparency to those who maintain the code,
    I've left all this repeated stuff (with modifications)
    here so you can play with it as needed.
    -- Cy
    %}
    if tuples_random(m,1) ~= tup_accum(1,1) && ...
        tuples_random(m,1) ~= tup_accum(1,2) && ...
        tuples_random(m,2) ~= tup_accum(1,1) && ...
        tuples_random(m,2) ~= tup_accum(1,2) && ...
        tuples_random(m+1,1) ~= tup_accum(1,1) && ...
        tuples_random(m+1,1) ~= tup_accum(1,2) && ...
        tuples_random(m+1,2) ~= tup_accum(1,1) && ...
        tuples_random(m+1,2) ~= tup_accum(1,2)
    
            % Split tuples_random at index
            t_split1 = tuples_random(1:m,:);
            t_split2 = tuples_random(m+1:end,:);
            
            % Randomly assign the entries left and right positions.
            if randi(2) == 2
                insertion = tup_accum(1,:);  
            else
                insertion = flip(tup_accum(1,:));
            end
            
            % Insert entry in tuples_random
            tuples_random = [t_split1; insertion; t_split2];

            % Remove entry from tup_accum
            tup_accum = tup_accum(2:end,:);
    else
            % Violation found; get new index
            m = randi(size(tuples_random, 1) - 1);
    end
end

% split tuples_random into 6 runs
ord_mat = [tuples_random(1:295,:) tuples_random(296:590,:) ...
    tuples_random(591:885,:) tuples_random(886:1180,:) ...
    tuples_random(1181:1475,:) tuples_random(1476:1770,:)];

% output the resulting matrix to file
cd('/Users/VisRecLab/VisRecLab_Code_Repository/MATLAB/E3');
ord_fold='stims_ord_E3/';
fl=[ord_fold, 's', sprintf('%02.0f', subj_k), '_ord_mat.txt']; 
dlmwrite(fl, ord_mat, 'precision', '%03.0f');
