function [scntr, topk] = TopK(qry_desc, fextor, rforest, Tc, ret_k, disth)
if 6 > nargin, disth = 1000; end
% load files
fid = fopen(fextor.fname.invx, 'rb');
clabList = fread(fid, [2, fextor.finfo.nfeat], '*uint32');
fclose(fid);

% get best match
[nidx, ndst] = rforest.MatchLeaf(qry_desc, fextor, ret_k);
% erase noisy match
ndst = ndst / fextor.finfo.flen;
idx = 1:numel(nidx);
idx(disth < ndst) = [];
nidx = nidx(idx); ndst = ndst(idx);
ndst = exp(- ndst / disth);
% erase wrong class label
cidx = clabList(1, nidx);
idx = 1:numel(nidx);
idx(Tc ~= cidx) = [];
nidx = nidx(idx); ndst = ndst(idx);

% accumulate result
cidx = clabList(2, nidx)';
scntr = accumarray(cidx, ndst'); % may less than num_of scene, but ok for top K
[~, topk] = sort(scntr, 'descend');
ret_k = min(ret_k, numel(topk));
topk = topk(1:ret_k);
scntr = scntr(topk);

end

