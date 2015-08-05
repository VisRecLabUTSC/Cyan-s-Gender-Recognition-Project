% tuples_generate() generates a randomized list of the (N choose 2)
% possible tuples in the first N natural numbers.
%
% (*) The randomized list may contain slightly less than (N choose 2)
% tuples due to the additional criterion that a given natural cannot
% appear in two consecutive tuples.

function [tuples_random, tup_accum] = face_pairs_generate(N)

% On entry:  N - the tuples are created from the first N naturals
%
% On return:  tuples_random - the randomized list of tuples
%             num_removed - the number of tuples removed in order
%                           to satisfy (*); i.e.,
%
%                 num_removed + size(tuples_random, 1) = (N choose 2)

num_tuples = nchoosek(N, 2);
tuples_ordered = nchoosek(1:N, 2);
perm_index = randperm(num_tuples);

j = 1;
num_removed = 0;
tuples_random(j,:) = tuples_ordered(perm_index(j),:);  % (*) okay when j=1 :)
tup_accum = [];
for k = 2:num_tuples
    if tuples_random(j,1) ~= tuples_ordered(perm_index(k),1) && ...
       tuples_random(j,1) ~= tuples_ordered(perm_index(k),2) && ...
       tuples_random(j,2) ~= tuples_ordered(perm_index(k),1) && ...
       tuples_random(j,2) ~= tuples_ordered(perm_index(k),2)
        j = j + 1;
        tuples_random(j,:) = tuples_ordered(perm_index(k),:);  % (*) passed
    else
        num_removed = num_removed + 1;                         % (*) failed
        tup_accum = [tup_accum;tuples_ordered(perm_index(k),:)]; %#ok<AGROW>
    end
end
