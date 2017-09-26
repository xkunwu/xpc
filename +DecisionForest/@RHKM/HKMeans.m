function HKMeans(obj, fvecList)

% randomly pick subset
obj.num_elem = floor(size(fvecList, 2) * obj.rnd_rate);
rand_indx = uint32(randsample(size(fvecList, 2), obj.num_elem))';

fprintf('\t');

nnode = int32(0); nleaf = int32(0);

% candidate stack
candx = 1;
q_cand(1).ran = rand_indx;
q_cand(1).pid = int32(1);
q_cand(1).sid = int32(1);
q_cand(1).cid = zeros([1, 8], 'int32');
q_cand(1).lvl = uint8(1);

while ~isempty(q_cand)
    c_cand = q_cand(end);
    q_cand = q_cand(1:end-1);
    
    % check leaf criterion
    if stop_split(c_cand.ran, c_cand.lvl)
        create_leaf(c_cand);
        fprintf('1');
        candx = candx + 1;
        if 0 == mod(candx, 80), fprintf('\n\t'); end
        continue;
    end
    
    % kmeans clustering
    [ctrs, idx] = vl_kmeans(fvecList(:, c_cand.ran), obj.num_brch, ...
        'initialization','plusplus', 'algorithm','elkan');
    ctrs = cast(ctrs, 'single');
    [~, ordx] = sort(idx);
    fls = mat2cell(c_cand.ran(:, ordx), size(c_cand.ran, 1), accumarray(idx(:), 1));
    
    % create node
    create_node(c_cand, ctrs);

    % enqueue the children candidates
    for ci = 1:numel(fls)
        tmpc.ran = fls{ci};
        tmpc.pid = nnode;
        tmpc.sid = int32(ci);
        tmpc.cid = zeros([1, 8], 'int32');
        tmpc.lvl = c_cand.lvl + 1;
        q_cand(end+1) = tmpc;
    end
    
    % print progress
    fprintf('.');
    candx = candx + 1;
    if 0 == mod(candx, 80), fprintf('\n\t'); end
end
obj.node_tbl(1).pid = int32(0);
obj.num_node = nnode;
obj.num_leaf = nleaf;

fprintf('\n');

% nn = numel(tree_t);
% rand_tree.sz = tree_size;
% rand_tree.sn = reshape([tree_t.sn], [1, nn]);
% rand_tree.ht = reshape([tree_t.ht], [1, nn]);
% rand_tree.ct = reshape([tree_t.ct], [obj.num_brch, nn]);
% rand_tree.px = reshape([tree_t.px], [1, nn]);
% rand_tree.cx = reshape([tree_t.cx], [obj.num_brch, nn]);

    function bstop = stop_split(rang, tlvl)
        bstop = false;
        if obj.min_leaf > numel(rang), bstop = true; return; end
        if obj.max_hght < tlvl, bstop = true; return; end
    end

    function create_node(cand, ctrs)
        nnode = nnode + 1;
        obj.node_tbl(nnode).pid = cand.pid;
        obj.node_tbl(cand.pid).cid(cand.sid) = nnode;
        obj.node_tbl(nnode).lvl = cand.lvl;
        obj.node_tbl(nnode).ran = cand.ran;
        obj.node_tbl(nnode).ctr = ctrs;
    end

    function create_leaf(cand)
        nleaf = nleaf + 1;
        obj.leaf_tbl(nleaf).pid = cand.pid;
        obj.node_tbl(cand.pid).cid(cand.sid) = - nleaf;
        obj.leaf_tbl(nleaf).lvl = cand.lvl;
        obj.leaf_tbl(nleaf).ran = cand.ran;
%         obj.leaf_tbl(nleaf).ctr = mean(fvecList(:, cand.ran), 2);
    end

end
