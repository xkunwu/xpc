function [qry_idx_comp, qry_mat, pid_mk, qry_mat_ance] = mcc_mst(obj, Tc, scn_idx, qry_mat)

%% maximum connected component

nums_m = obj.datao.minfo.nums(Tc);

% % test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % rng(0, 'twister');
% num_qry = 10; qry_idx = 1:num_qry;
% % mat_idx = randi(num_qry, [1, num_qry]);
% mat_idx = randperm(num_qry);
% num_qry = numel(qry_idx);
% qry_mat = [qry_idx; mat_idx];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % remove symmetric redundency
% qry_mat(1:2, :) = sort(qry_mat(1:2, :), 1);
% qry_mat = sortrows(qry_mat', [1 2 4 3]);
% uni_mk = (0 ~= (qry_mat(2:end, 1:2) - qry_mat(1:end-1, 1:2)));
% uni_mk = uni_mk(:, 1) | uni_mk(:, 2);
% uni_mk = [true; uni_mk];
% qry_mat = qry_mat(uni_mk, :)';
% fprintf('\t%d edges after removing symmetric redundency\n', size(qry_mat, 2));

% components grouping
set_mk = 1:nums_m;
num_mat = size(qry_mat, 2);
for mat = 1:num_mat
    set_mk(set_mk == set_mk(qry_mat(1, mat))) = qry_mat(2, mat);
end

% extract connected components
uni_mk = unique(set_mk); % extract unique serial set for each component
uni_mk_cnt = sum((repmat(set_mk, [numel(uni_mk), 1]) == repmat(uni_mk', [1, nums_m])), 2);
[~, id] = sort(uni_mk_cnt, 'Descend'); % sort by their card
fprintf('\t%d connected components extracted\n', sum(1 < uni_mk_cnt));
for k = 1:uni_mk_cnt % check the same model
    k_idx = sum(0 < uni_mk(id(k)) - obj.datao.minfo.cums);
    if Tc == k_idx, break; end
end
if Tc ~= k_idx
    fprintf(2, 'no matching component!\n');
    return;
end
mcc = (set_mk == uni_mk(id(k))); % mask for the maximum component
fprintf('\t%d elements in the maximum component\n', sum(mcc));
qry_idx_comp = 1:nums_m;
qry_idx_comp = qry_idx_comp(mcc); % take out maximum component
[~, ~, uni_mk] = intersect(qry_idx_comp, scn_idx(1, :));
qry_idx_comp = scn_idx(:, uni_mk);
qry_idx_comp = sortrows(qry_idx_comp', 2)';

% make relation graph closure
qry_mat_comp = [];
for k = 1:num_mat
    if 0 < sum(qry_idx_comp(1, :) == qry_mat(1, k)) && ...
            0 < sum(qry_idx_comp(1, :) == qry_mat(2, k))
        qry_mat_comp = [qry_mat_comp, qry_mat(:, k)];
    end
end
num_mat = size(qry_mat_comp, 2);
fprintf('\t%d edges in the maximum component\n', num_mat);
[~, ~, qry_mat] = unique(reshape(qry_mat_comp(1:2, :), [1, 2 * num_mat]));
qry_mat_comp(1:2, :) = reshape(qry_mat, [2, num_mat]); % use relative ordinal
qry_mat_comp = sortrows(qry_mat_comp', [4 3])';


%% minimum spanning tree

% % test %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% qry_idx_comp = 1:5;
% qry_mat_comp = [1, 3; 2, 3; 3, 4; 5, 4; 1, 5; 1, 2]';
% qry_mat_comp = [qry_mat_comp; 1:6; 1:6];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_qry = size(qry_idx_comp, 2);
num_mat = size(qry_mat_comp, 2);
set_mk = 1:num_qry;
pid_mk = [zeros(2, num_qry); 1:num_qry]; % [parent id; up-link index]
% qry_mat = sortrows(qry_mat_comp', [3 4])'; % score is extending confidence!
qry_mat = sortrows(qry_mat_comp', [4 3])';
qry_mat_tree = zeros(1, num_mat);
qry_mat_loop = zeros(1, num_mat);
for i = 1:num_mat
    if set_mk(qry_mat(1, i)) == set_mk(qry_mat(2, i))
        qry_mat_loop(i) = i;
    else
        set_mk(set_mk == set_mk(qry_mat(1, i))) = set_mk(qry_mat(2, i));
        qry_mat_tree(i) = i;
        
        cl = qry_mat(1, i);
        if 0 ~= pid_mk(1, cl)
            fprintf('\treversed link: %d', cl);
            brc = [];
            while 0 ~= pid_mk(1, cl)
                brc = [[pid_mk(1, cl); pid_mk(2, cl)], brc];
                cl = pid_mk(1, cl);
                fprintf(' %d', cl);
            end
            for j = 1:size(brc, 2)
                qry_mat([1, 2], brc(2, j)) = qry_mat([2, 1], brc(2, j));
                pid_mk(1, brc(1, j)) = qry_mat(2, brc(2, j));
                pid_mk(2, brc(1, j)) = brc(2, j);
            end
            fprintf('\n');
        end
        pid_mk(1, qry_mat(1, i)) = qry_mat(2, i); % already in up-link direction
        pid_mk(2, qry_mat(1, i)) = i;
    end
end
qry_mat_loop = qry_mat_loop(0 < qry_mat_loop);
qry_mat_tree = qry_mat_tree(0 < qry_mat_tree);

pid_mk = pid_mk(1:2, :);


%% compute common ancestor
qry_mat_ance = zeros(1, num_mat); % common ancestor
for i = qry_mat_loop
    cand_loop = qry_mat(1, i);
    qry_mat_ance(i) = qry_mat(1, i);
    cl = pid_mk(1, qry_mat(1, i));
    while 0 ~= cl
        cand_loop = [cand_loop, cl];
        qry_mat_ance(i) = cl; % back-track to root
        cl = pid_mk(1, cl);
    end
    cl = qry_mat(2, i);
    while 0 == sum(cand_loop == cl) && 0 ~= cl
        cl = pid_mk(1, cl);
    end
    if 0 ~= cl % short cut loop
        qry_mat_ance(i) = cl;
    end
end

end
