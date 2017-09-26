function [nidx, ndst] = MatchLeaf(obj, tagtList, fvecList, ret_k)
[~, numf] = size(tagtList);
nidx = cell(1, numf);
ndst = cell(1, numf);

% match to leaf
leaf_indx = zeros(1, numf);
% for vi = 1:numf
parfor vi = 1:numf
    leaf_indx(vi) = match_one(obj, tagtList(:, vi));
end
% match within leaf
for vi = numf:-1:1
    lvnd = obj.leaf_tbl(leaf_indx(vi));
    lran = lvnd.ran;
    if ret_k > numel(lran)
        lvnd = obj.node_tbl(lvnd.pid);
        lran = lvnd.ran;
    end
    [ndst{vi}, nidx{vi}] = cell_best(tagtList(:, vi), ...
        fvecList(:, lran), ret_k);
    nidx{vi} = lran(nidx{vi});
end

end

function leaf_indx = match_one(obj, feat)
leaf_indx = 1;
while 0 < leaf_indx
    cn = obj.node_tbl(leaf_indx);
    D = vl_alldist2(feat, cn.ctr);
    [~, m] = min(D);
    leaf_indx = cn.cid(m);
end
leaf_indx = - leaf_indx;
end

function [ndst, nidx] = cell_best(feat, lvft, ret_k)
D = vl_alldist2(feat, lvft);
ret_k = min(ret_k, numel(D));
[ndst, nidx] = sort(D, 'ascend');
ndst = ndst(ret_k);
nidx = nidx(ret_k);
end
