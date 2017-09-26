function out_mat(obj, Tc, qry_idx, qry_mat, pid_mk, qry_mat_ance, draw_m)

datao = obj.datao;

num_scn = numel(qry_idx);
num_mat = size(qry_mat, 2);

if 0 ~= draw_m
    scrsz = get(0, 'ScreenSize');
    scrsz = [50 50 scrsz(3)-100 scrsz(4)-150];
    plot_row = floor(scrsz(4) / 400);
    plot_col = floor(scrsz(3) / 400);
    plot_num = plot_row * plot_col;
    hfig = figure('Visible','off', 'Position',scrsz);
    set(gcf, 'Color', 'w');
end

% some header
fid = fopen(sprintf('%s/scene_match.txt', datao.rpath.out), 'w');
fprintf(fid, '%s\n', datao.mlist(Tc).name);
fprintf(fid, '%d %d\n', num_scn, num_mat);
[~, img_idx] = s2cm(obj, qry_idx);
for seq = 1:num_scn
    fprintf(fid, sprintf('/ply/%s_%s.ply\n', ...
        datao.mlist(Tc).name, datao.mlist(Tc).iseq{seq}));
end
fclose(fid);

% matches
for mat = 1:num_mat
    fid = fopen(sprintf('%s/scene_match.txt', datao.rpath.out), 'a');
    fprintf(fid, '# match %d\n', mat);
    fprintf(fid, '%d %d\n', qry_mat(1, mat) - 1, qry_mat(2, mat) - 1);
    fclose(fid);
    if 0 ~= draw_m
        if plot_num >= mat
            Utility.subaxis(plot_row, plot_col, mat, 'Spacing',0, 'Padding',0.005, 'Margin',0);
        end
    end
    one_match(datao, obj.fextor, Tc, ...
        img_idx(qry_mat(1, mat)), img_idx(qry_mat(2, mat)), draw_m);
end
if 0 ~= draw_m
    saveas(hfig, sprintf('%s/matim_%d', datao.rpath.out, Tc), 'png');
    close(hfig);
end

% some tail
fid = fopen(sprintf('%s/scene_match.txt', datao.rpath.out), 'a');
for m = 1:num_scn
    fprintf(fid, '%d ', pid_mk(1, m) - 1);
end
fprintf(fid, '\n');
for m = 1:num_scn
    fprintf(fid, '%d ', pid_mk(2, m) - 1);
end
fprintf(fid, '\n');
for m = 1:num_mat
    fprintf(fid, '%d ', qry_mat_ance(m) - 1);
end
fprintf(fid, '\n');
% for m = 1:num_mat
%     fprintf(fid, '%d ', qry_mat(1, m));
% end
% fprintf(fid, '\n');
% for m = 1:num_mat
%     fprintf(fid, '%d ', qry_mat(2, m));
% end
% fprintf(fid, '\n');
fclose(fid);

    function one_match(datao, fextor, Tc, qry_s, tgt_s, draw_m)
        
        [qry_imd, tgt_imd, qry_ima, tgt_ima, qry_imc, tgt_imc, topleft] = ...
            load_image_diff(datao, Tc, qry_s, tgt_s);
        
        [v2d_q, v2d_m] = Completion.SIFTFlowMatch(qry_imd, qry_imc, qry_ima, ...
            tgt_imd, tgt_imc, tgt_ima, ...
            fextor, draw_m);
        write_3d_matches(datao, qry_imd, tgt_imd, v2d_q, v2d_m, topleft);
        
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_3d_matches(datao, qry_imd, tgt_imd, v2d_q, v2d_m, topleft)

% reconstruct 3d point
p3d_query = Completion.Depth2PC(qry_imd, v2d_q, topleft.query);
p3d_match = Completion.Depth2PC(tgt_imd, v2d_m, topleft.match);

% write out initial correspondences
fid = fopen(sprintf('%s/scene_match.txt', datao.rpath.out), 'a');
nm = size(p3d_query, 2);
fprintf(fid, '%d\n', nm);
for i = 1:nm
    fprintf(fid, '%f %f %f\n', p3d_query(1, i), p3d_query(2, i), p3d_query(3, i));
    fprintf(fid, '%f %f %f\n', p3d_match(1, i), p3d_match(2, i), p3d_match(3, i));
end
fclose(fid);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [qry_imd, tgt_imd, qry_ima, tgt_ima, qry_imc, tgt_imc, topleft] = ...
    load_image_diff(datao, Tc, qry_s, tgt_s)

[qry_imd, qry_imc, qry_ima] = datao.LoadImage( ...
    sprintf('%s/%s', datao.rpath.data, datao.mlist(Tc).name), ...
    datao.mlist(Tc).imgl(qry_s, :));

[tgt_imd, tgt_imc, tgt_ima] = datao.LoadImage( ...
    sprintf('%s/%s', datao.rpath.data, datao.mlist(Tc).name), ...
    datao.mlist(Tc).imgl(tgt_s, :));

if 2 == size(datao.mlist(Tc).imgl, 2)
    topleft.query = [1, 1];
    topleft.match = [1, 1];
else
    fid = fopen(sprintf('%s/%s/%s', datao.rpath.data, datao.mlist(Tc).name, ...
        datao.mlist(Tc).imgl{qry_s, 4}), 'r');
    topleft.query = fscanf(fid, '%d,%d');
    fclose(fid);
    fid = fopen(sprintf('%s/%s/%s', datao.rpath.data, datao.mlist(Tc).name, ...
        datao.mlist(Tc).imgl{tgt_s, 4}), 'r');
    topleft.match = fscanf(fid, '%d,%d');
    fclose(fid);
end

end

