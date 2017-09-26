function Write3dM(obj, tgt_spt)
Tc = obj.mdsn.md;
tgt_s = obj.mdsn.sn;
v2d_q = obj.mpair.src;
v2d_m = obj.mpair.tgt;

topleft.query = [1, 1];
fid = fopen(sprintf('%s/%s/%s', obj.datao.rpath.data, obj.datao.mlist(Tc).name, ...
    obj.datao.mlist(Tc).imgl{tgt_s, 4}), 'r');
topleft.match = fscanf(fid, '%d,%d');
fclose(fid);

[qry_imd, ~, ~] = obj.datao.LoadImage( ...
    obj.rdetect.inroot, obj.rdetect.get_comp_imgl());
[tgt_imd, ~, ~] = obj.datao.LoadImage( ...
    sprintf('%s/%s', obj.datao.rpath.data, obj.datao.mlist(Tc).name), ...
    obj.datao.mlist(Tc).imgl(tgt_s, :));

% reconstruct 3d point
p3d_query = Completion.Depth2PC(qry_imd, v2d_q, topleft.query);
p3d_match = Completion.Depth2PC(tgt_imd, v2d_m, topleft.match);

% write out initial correspondences
fid = fopen(sprintf('%s/scene_match.txt', obj.datao.rpath.out), 'a');
fprintf(fid, '# background connection\n');
% fprintf(fid, '%s\n', obj.bgpcname);
fprintf(fid, sprintf('/plybg/%s.ply\n', obj.rdetect.get_comp_iseq()));
fprintf(fid, '%d\n', tgt_spt-1);
nm = size(p3d_query, 2);
fprintf(fid, '%d\n', nm);
for i = 1:nm
    fprintf(fid, '%f %f %f\n', p3d_query(1, i), p3d_query(2, i), p3d_query(3, i));
    fprintf(fid, '%f %f %f\n', p3d_match(1, i), p3d_match(2, i), p3d_match(3, i));
end
fclose(fid);

end

