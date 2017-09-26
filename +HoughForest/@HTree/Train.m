function Train(obj, fvecList, clabList, vcenList, grid_step)

if 5 > nargin, grid_step = 1; end
% fvec_wow = WorkerObjWrapper(fvecList);
% clab_wow = WorkerObjWrapper(clabList);
% vcen_wow = WorkerObjWrapper(vcenList);

fprintf('\t');

nnode = int32(0); nleaf = int32(0);
[fvec_len, obj.num_elem] = size(fvecList);
lab = unique(clabList);
obj.num_lab = numel(lab);
obj.lab_map = containers.Map(lab, 1:1:obj.num_lab);
% vcenList = vcenList ./ repmat(max(abs(vcenList), [], 2), [1, obj.num_elem]); % normalization

% candidate stack
candx = 1;
q_cand(1).ran = 1:1:obj.num_elem;
q_cand(1).pid = 1;
q_cand(1).cid = 1;
q_cand(1).lvl = 1;

while ~isempty(q_cand)
    c_cand = q_cand(end);
    q_cand = q_cand(1:end-1);
    
    % check leaf criterion
    if stop_split(c_cand.ran, c_cand.lvl)
        create_leaf(c_cand.ran, c_cand.pid, c_cand.cid);
        fprintf('1');
        candx = candx + 1;
        if 0 == mod(candx, 80), fprintf('\n\t'); end
        continue;
    end
    
    % generate valid dimensions
    valid_dim = gen_valid_dim(c_cand.ran);
    if isempty(valid_dim)
        create_leaf(c_cand.ran, c_cand.pid, c_cand.cid);
        fprintf('2');
        candx = candx + 1;
        if 0 == mod(candx, 80), fprintf('\n\t'); end
        continue;
    end
    
    % try to split the data into binary tree
%     min_rec = try_split(c_cand.ran, fvec_wow, clab_wow, vcen_wow);
    min_rec = try_split(c_cand.ran, ...
        fvecList(:, c_cand.ran), clabList(:, c_cand.ran), vcenList(:, c_cand.ran));
    if isinf(min_rec.score)
        create_leaf(c_cand.ran, c_cand.pid, c_cand.cid);
        if 0 == min_rec.fvno, fprintf('3');
        else fprintf('4'); end
        candx = candx + 1;
        if 0 == mod(candx, 80), fprintf('\n\t'); end
        continue;
    end
    
    % create node and enqueue the children candidates
    create_node(c_cand.ran, c_cand.lvl, c_cand.pid, c_cand.cid, min_rec.fvno, min_rec.th);
    
    tmpc.ran = min_rec.r_l;
    tmpc.pid = nnode;
    tmpc.cid = 1;
    tmpc.lvl = c_cand.lvl + 1;
    q_cand(end+1) = tmpc;
    
    tmpc.ran = min_rec.r_r;
    tmpc.pid = nnode;
    tmpc.cid = 2;
    tmpc.lvl = c_cand.lvl + 1;
    q_cand(end+1) = tmpc;

    % print progress
    fprintf('.');
    candx = candx + 1;
    if 0 == mod(candx, 80), fprintf('\n\t'); end
end
obj.node_tbl(1).pid = 0;

fprintf('\n');

% adjust table according to the actually built tree
obj.num_node = nnode;
obj.num_leaf = nleaf;
obj.node_tbl = obj.node_tbl(1:nnode);
obj.leaf_tbl = obj.leaf_tbl(1:nleaf);

%     function min_rec = try_split(rang, fvec_wow, clab_wow, vcen_wow)
    function min_rec = try_split(rang, fvec, clab, vcen)
        % select a single spliting function for this level
        split_func = {};
%         split_func{end+1} = @I_cs_; % class variance
        split_func{end+1} = @H_d_; % displacement variance
%         split_func{end+1} = @H_s_; % splitting
        func = split_func{randi(numel(split_func))};
        
        % try to split the tree
        min_rec = struct( ...
            'score',Inf, 'fvno',0, 'th',0, 'r_l',0, 'r_r',0 ...
            );
        tries = obj.num_try;
        rec_pool(tries) = min_rec;
%         for ti = 1:tries
        parfor ti = 1:tries
            % random dimension
            fvno = rand_dim(valid_dim);
            
            % random threshold
%             m = mean(fvec_wow.Value(fvno, rang));
%             s = std(fvec_wow.Value(fvno, rang));
            m = median(fvec(fvno, :));
            s = std(fvec(fvno, :));
            th = m + s.*randn;
            
            [tcs, range_l, range_r] = score_split(func, ...
                fvec, clab, vcen, fvno, th);
%             [tcs, range_l, range_r] = score_split( ...
%                 fvec_wow.Value(:, rang), clab_wow.Value(:, rang), vcen_wow.Value(:, rang), fvno, th);
%             fprintf('scr: %f, fvno: %d, th: %.2f, m: %.2f, s: %.2f\n', tcs, fvno, th, m, s);
            rec_pool(ti).score = tcs;
            rec_pool(ti).fvno = fvno;
            rec_pool(ti).th = th;
            rec_pool(ti).r_l = range_l;
            rec_pool(ti).r_r = range_r;
        end
        
        % take the best one and return
        [min_rec.score, ti] = min([rec_pool.score]);
        min_rec.fvno = rec_pool(ti).fvno;
        min_rec.th = rec_pool(ti).th;
        min_rec.r_l = rang(rec_pool(ti).r_l);
        min_rec.r_r = rang(rec_pool(ti).r_r);
        
%         [mv, mi] = min(abs(cellfun(@numel, {rec_pool.r_l})./cellfun(@numel, {rec_pool.r_r}) - 1))
%         rec_pool(ti)
%         rec_pool(mi)
    end

    function bstop = stop_split(rang, tlvl)
        bstop = false;
%         if 1 < sum(Utility.count_unique(clabList(rang))), return; end % enforce single class
        if obj.min_leaf > numel(rang), bstop = true; return; end
        if obj.max_hght < tlvl, bstop = true; return; end
    end

    function valid_dim = gen_valid_dim(rang)
        valid_dim = (1:fvec_len)';
%         valid_dim( ...
%             sum(0 == fvecList(:, rang), 2) ...
%             > 0.4 * numel(rang) ...
%             ) = [];
        valid_dim( ...
            eps > iqr(fvecList(:, rang), 2) ...
            ) = [];
    end

    function create_node(rang, tlvl, node_pid, node_cid, fvno, the)
        nnode = nnode + 1;
%         fprintf('node: %d, pid: %d\n', nnode, node_pid);
        obj.node_tbl(nnode).pid = node_pid;
        obj.node_tbl(node_pid).cid(node_cid) = nnode;
        obj.node_tbl(nnode).lvl = tlvl;
        obj.node_tbl(nnode).rang = rang;
        obj.node_tbl(nnode).fvno = fvno;
        obj.node_tbl(nnode).the = the;
    end

    function create_leaf(rang, node_pid, node_cid)
        nleaf = nleaf + 1;
%         fprintf('leaf: %d, pid: %d\n', nleaf, node_pid);
        obj.leaf_tbl(nleaf).pid = node_pid;
        obj.node_tbl(node_pid).cid(node_cid) = - nleaf;
        obj.leaf_tbl(nleaf).label = unique(clabList(rang));
        if 1 < numel(obj.leaf_tbl(nleaf).label),
            obj.leaf_tbl(nleaf).label = 0;
        elseif 3 < sum(std(vcenList(:, rang), 0, 2)) / grid_step / numel(rang);
            obj.leaf_tbl(nleaf).label = -1;
        end
        obj.leaf_tbl(nleaf).cen = median(vcenList(:, rang), 2);
        obj.leaf_tbl(nleaf).rang = rang;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H_s = H_s_(range_l, range_r, ~, ~)
% H_s(T) = - \sum_{s = 1, 2} (N_s / N) * log_2 (N_s / N)
cnt = [numel(range_l), numel(range_r)];
cnt = cnt / sum(cnt);
H_s = sum(cnt .* log2(cnt)); % note here using minimization
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function I_cs = I_cs_(range_l, range_r, clab, ~)
% I_cs(T) = H_c(T) - \sum_{s = 1, 2} (N_s / N) * H_c(T_s)
cnt = [numel(range_l), numel(range_r)];
cnt = cnt / sum(cnt);
cnt(1) = cnt(1) * H_c_(range_l, clab);
cnt(2) = cnt(2) * H_c_(range_r, clab);
% I_cs = H_c - sum(cnt); % note H_c is a constant
I_cs = sum(cnt); % note here using minimization

    function H_c = H_c_(rang, clab)
        % H_c(T) = - \sum_{c \in C} (N_c / N) * log_2 (N_c / N)
        [~, cul] = Utility.count_unique(clab);
        cul = cul / numel(rang);
        H_c = - sum(cul .* log2(cul));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H_d = H_d_(range_l, range_r, clab, vcen)
% \sum_{s = 1, 2} (N_s / N) * hd_(T_s)
cnt = [numel(range_l), numel(range_r)];
cnt = cnt / sum(cnt);
cnt(1) = cnt(1) * hd_(clab(:, range_l), vcen(:, range_l));
cnt(2) = cnt(2) * hd_(clab(:, range_r), vcen(:, range_r));
H_d = sum(cnt);

    function H_d = hd_(clab, vcen)
        % H_d(T) = \sum_{c \in C} var(D_c)
        [~, ordx] = sort(clab);
        fls = vcen(:, ordx);
        [~, ~, uniq_indx] = unique(clab);
        fls = mat2cell(fls, 2, accumarray(uniq_indx(:), 1));
%         H_d = sum( ...
%             cellfun(@sum, ...
%             cellfun(@(x) mad(x'), fls_c, 'UniformOutput',false) ...
%             ) );
        H_d = sum( ...
            cellfun(@sum, ...
            cellfun(@(x) var(x, 0, 2), fls, 'UniformOutput',false) ...
            ) );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [score, range_l, range_r] = score_split(func, fvec, clab, vcen, fvno, th)
[range_l, range_r] = split_tree(fvec, fvno, th);
if 1 > numel(range_l) || 1 > numel(range_r)
    score = Inf;
    return;
end
score = func(range_l, range_r, clab, vcen);
% score = score / H_s_(range_l, range_r);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [range_l, range_r] = split_tree(fvec, fvno, th)
indx = th < fvec(fvno, :);
% indx = 0.5 < rand([1, size(fvec, 2)]);

ordx = 1:size(fvec, 2);
range_l = ordx(indx); % greater -> left
range_r = ordx(~indx);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fvno = rand_dim(valid_dim)
ri = randi(numel(valid_dim));
fvno = valid_dim(ri);
% valid_dim(ri) = [];
end

