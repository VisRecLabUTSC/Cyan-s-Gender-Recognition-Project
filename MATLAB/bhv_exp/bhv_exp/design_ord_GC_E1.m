function design_ord_GC_E1(subj_k) %[trial_ord_orig, trial_code_list, trial_list, lr_ind]

RandStream.setGlobalStream ...
    (RandStream('mt19937ar','seed',sum(100*clock)))

if nargin==0
    subj_k=2;
end

run_n=5;

%%%pseudorandomize stimulus order
%%%cnd1: no more than 4 faces of the same gender in a row
%%%cnd2: no image is repeated twice in a row
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%perm here so set of id pairs in a run is random

ord_mat=single(zeros(240, run_n));

for run_k=1:run_n
    
    cnd1=1; cnd2=1;
    k=0;
    while cnd1 || cnd2

        k=k+1;
        
        ord=single(randperm(240));
        
        ord_id=ord.*single(ord<121) + (ord-120).*single(ord>120);
        ord_gend=single(ord_id<61);
        

        male_conv=single(conv(ord_gend, [1 1 1 1 1])>4);
        fem_conv=single(conv((1-ord_gend), [1 1 1 1 1])>4);
        cnd1_n=sum(male_conv'+fem_conv');
        cnd1=cnd1_n>0;

        cnd2_n=sum(single(ord_id(1:end-1)==ord_id(2:end)));
        cnd2=cnd2_n>0;

    end

    k=k
    %[ord_gend' ord_id']
    ord_mat(:, run_k)=ord_id';

end


ord_fold=['stims_ord_E1/'];
fl=[ord_fold, 's', sprintf('%02.0f', subj_k), '_ord_mat.txt']; 
dlmwrite(fl, ord_mat, 'precision', '%03.0f') %'precision', '%03.0f'
        
  
