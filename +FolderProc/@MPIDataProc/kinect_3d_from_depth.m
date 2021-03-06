function kinect_3d_from_depth(obj, m_seq)

dir_pref = obj.mlist(m_seq).dir;
image_list = obj.mlist(m_seq).imgl;
image_seq = obj.mlist(m_seq).iseq;
model_name = obj.mlist(m_seq).name;

if ~ exist(obj.rpath.ply, 'dir')
    mkdir(obj.rpath.ply);
else
    fl = dir(obj.rpath.ply);
    isDir = [fl.isdir];
    fl = {fl(~isDir).name}';
    fl = 1 - cellfun(@isempty, strfind(fl, model_name));
    if 0 < sum(fl)
        fprintf(2, '\tply already exported, not this time\n');
        return;
    end
end

num_scn = size(image_list, 1);

fprintf('\t%d scenes:\n\t', num_scn);
for seq = 1:num_scn
    %% load
    isn = image_seq{seq};
    [im_d, im_c, im_a] = obj.LoadImage(dir_pref, image_list(seq, :));
    nrcs = size(im_d);
    sz = [nrcs, nrcs(1) * nrcs(2)];
    sz(end) = sum(sum(im_a));
    
    % RGB-D camera constants
    center = [320 240];
    [imh, imw] = size(im_d);
    constant = 609.2;
    MM_PER_M = 1;
%     MM_PER_M = 1000;
    
    % convert depth image to 3d point clouds
    xgrid = ones(imh,1)*(1:imw) - center(1);
    ygrid = (1:imh)'*ones(1,imw) - center(2);
    X = xgrid.*im_d/constant/MM_PER_M;
    Y = ygrid.*im_d/constant/MM_PER_M;
    Z = im_d/MM_PER_M;
    X = X(im_a); Y = Y(im_a); Z = Z(im_a);
    
    %% color
    image_pick = zeros(sz(end), 3, 'uint8');
    for i = 1:3
        cc = im_c(:, :, i);
        image_pick(:, i) = cc(im_a);
    end
    
    %% export
    outname = sprintf('%s/%s_%s.ply', obj.rpath.ply, model_name, isn);
    export_ply(outname, sz, X, Y, Z, image_pick);

    fprintf('.'); if 0 == mod(seq, 100), fprintf('\n\t'); end
end
fprintf('\n');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function export_ply(outname, sz, X, Y, Z, image_data)
% dump ply format data

fid = fopen(outname, 'w');
% header
fprintf(fid, 'ply\n');
fprintf(fid, 'format ascii 1.0\n');
fprintf(fid, 'comment generated by depth2pointcloud\n');
fprintf(fid, 'element vertex %d\n', sz(end));
fprintf(fid, 'property float x\n');
fprintf(fid, 'property float y\n');
fprintf(fid, 'property float z\n');
fprintf(fid, 'property uchar red\n');
fprintf(fid, 'property uchar green\n');
fprintf(fid, 'property uchar blue\n');
fprintf(fid, 'end_header\n');
% data
for k = 1:sz(end)
    fprintf(fid, '%f %f %f %u %u %u\n', X(k), Y(k), Z(k), ...
        image_data(k, 1), image_data(k, 2), image_data(k, 3));
end
fclose(fid);

end
