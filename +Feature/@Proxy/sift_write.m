function sift_write(obj, m_seq)

image_list = obj.datao.mlist(m_seq).imgl;

num_scn = obj.datao.minfo.nums(m_seq);
fprintf('\t%d scenes:\n\t', num_scn);
for seq = 1:num_scn
    [im_d, im_c, im_a] = obj.datao.LoadImage(obj.datao.mlist(m_seq).dir, image_list(seq, :));
    
    numf = one_write(obj, m_seq, seq, im_d, im_c, im_a);
    obj.flist(m_seq).numf(seq) = numf;
    obj.flist(m_seq).sumf = obj.flist(m_seq).sumf + numf;

    fprintf('.'); if 0 == mod(seq, 80), fprintf('\n\t'); end
end

obj.finfo.sumfm(m_seq) = obj.flist(m_seq).sumf;
obj.flist(m_seq).cumf = ...
    cumsum(obj.flist(m_seq).numf) - obj.flist(m_seq).numf;
for i = 1:m_seq-1
    obj.flist(m_seq).cumf = obj.flist(m_seq).cumf + ...
        repmat(obj.finfo.sumfm(i), [num_scn, 1]);
end

fprintf('\n');
fprintf('\t%d features\n', obj.flist(m_seq).sumf);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function numf = one_write(obj, m_seq, seq, im_d, im_c, idxa)

[desc, fram] = obj.ExtrMask(im_d, im_c, idxa);
numf = size(desc, 2);

% voting center
cen = size(im_d) / 2;
vcen = repmat([cen(2); cen(1)], [1, numf]) - fram(1:2, :);

% Utility.draw_matches(im_d, im_d, fram(2:-1:1, :), fram(2:-1:1, :) + vcen(2:-1:1, :));

% write out
write_out(obj.fname, fram, desc, repmat([m_seq; seq], [1, numf]), vcen);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_out(files, frames, desc, invx, vcen)
% fwrite: column order.
% SIFT frame: [4, nf]
fid = fopen(files.fram, 'a');
fwrite(fid, frames, 'single');
fclose(fid);
% SIFT descriptor: [128, nf]
fid = fopen(files.desc, 'a');
fwrite(fid, desc, 'uint8');
fclose(fid);
% inverted file index: descriptor --> scene
fid = fopen(files.invx, 'a');
fwrite(fid, invx, 'uint32');
fclose(fid);
% central voting vector: 
fid = fopen(files.vcen, 'a');
fwrite(fid, vcen, 'single');
fclose(fid);
end
