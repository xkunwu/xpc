function tgt_spt = ExpandFromOne(obj, Tc, Mid, rexpar)

datao = obj.datao;
scn_idx = obj.cm2s(Tc, Mid);

%%
% Tc = 0; % un-comment this line to see database infomation
if 1 > Tc || datao.minfo.cnt < Tc || 1 > Mid || datao.minfo.nums(Tc) < Mid
    fprintf(2, 'scene index out of range (%d)!\n', sum_scn);
    fprintf('scene list:\n');
    disp({datao.mlist.name});
    fprintf('scene capacity:\n');
    disp(datao.minfo.cnt);
    disp(datao.minfo.cums + 1);
    disp(datao.minfo.cums + datao.minfo.nums);
    return;
end


%% 1NN retrieval
tic; fprintf('%s >> 1NN retrieval started ...\n', datestr(now));
[scn_exp, qry_mat] = obj.ret_1nn(scn_idx, rexpar);
fprintf('%s >> execution time: %.2f\n', datestr(now), toc);

if isempty(qry_mat)
    fprintf(2, '%d images with empty matching set!\n\n', size(scn_exp, 2));
    return;
else
    fprintf('%d images with %d matches retrieved\n\n', size(scn_exp, 2), size(qry_mat, 2));
end

% load(sprintf('%s/match_init.mat', datao.out_root), '-mat');
save(sprintf('%s/match_init.mat', datao.rpath.out), '-mat', ...
    'scn_idx', 'scn_exp', 'qry_mat');


%% maximum connected component & minimum spanning tree
tic; fprintf('%s >> computing maximum connected component ...\n', datestr(now));
[qry_idx_comp, qry_mat, pid_mk, qry_mat_ance] = obj.mcc_mst(Tc, scn_exp, qry_mat);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

% load(sprintf('%s/match_comp.mat', datao.out_root), '-mat');
save(sprintf('%s/match_comp.mat', datao.rpath.out), '-mat', ...
    'qry_idx_comp', 'qry_mat', 'pid_mk', 'qry_mat_ance');
tgt_spt = find(qry_idx_comp(1, :) == scn_idx);


%% write out matches
tic; fprintf('%s >> writing out matches ...\n', datestr(now));
obj.out_mat(Tc, qry_idx_comp(1, :), qry_mat(1:2, :), pid_mk, qry_mat_ance, rexpar.drawc);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

end

