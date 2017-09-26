function do_extract(obj)

% clean up, create files
fnv = fieldnames(obj.fname);
for ni = 1:numel(fnv)
    fid = fopen(obj.fname.(fnv{ni}), 'w');
    fclose(fid);
end

% extract feature
fextr = Feature.PHOWExtractor();
fextr.color = 'opponent';
fextr.desc_len = 384;
obj.fextr(fextr.target) = fextr;

fextr = Feature.PHOWExtractor();
fextr.target = 'depth';
fextr.color = 'gray';
obj.fextr(fextr.target) = fextr;

clear fextr;

% update step length, and feature length
vf = values(obj.fextr);
for fi = 1:obj.fextr.Count
    vf{fi}.step = obj.fstep;
    obj.finfo.flen = obj.finfo.flen + vf{fi}.desc_len;
end

% each folder
tic; fprintf('%s >> collecting features ...\n', datestr(now));
for seq = 1:obj.datao.minfo.cnt
    fprintf('in folder: %s\n', obj.datao.mlist(seq).name);
    obj.sift_write(seq);
end
obj.finfo.nfeat = sum(obj.finfo.sumfm);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

end

