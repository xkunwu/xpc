function SeqExpand(obj, datao, fextor, seq_m, bin_w)
if 5 > nargin, bin_w = false; end

% get valid index
indx = 1:datao.minfo.nums(seq_m);
indx = indx(obj.seqsn == datao.mlist(seq_m).im2x(:, 1));
if isempty(indx), fprintf(2, 'error sequence number!\n'); return; end
nums = numel(indx);
indx = [indx; indx(2:end), indx(1)];
matp = 1:nums;
matp = [matp; matp(2:end), matp(1)];

% export registration file
regf = sprintf('%s/%s', obj.outreg, datao.mlist(seq_m).name);
fid = fopen(regf, 'w');
strline = sprintf('%s\n', datao.mlist(seq_m).name);
if bin_w
    fwrite(fid, length(strline), 'uint32');
    fprintf(fid, strline);
    fwrite(fid, nums, 'uint32');
    fwrite(fid, nums, 'uint32');
else
    fprintf(fid, strline);
    fprintf(fid, '%d %d\n', nums, nums);
end
for si = 1:nums
    strline = sprintf('/ply/%s_%s.ply\n', ...
        datao.mlist(seq_m).name, datao.mlist(seq_m).iseq{si});
    if bin_w
        fwrite(fid, length(strline), 'uint32');
    end
    fprintf(fid, strline);
end
fclose(fid);

fprintf('\t%d scenes:\n\t', nums);
for si = 1:nums
    fid = fopen(regf, 'a');
    if bin_w
        fwrite(fid, matp(:, si)-1, 'uint32');
    else
        fprintf(fid, '# match %d\n', si);
        fprintf(fid, '%d %d\n', matp(1, si)-1, matp(2, si)-1);
    end
    fclose(fid);

    expand_one(seq_m, indx(1, si), indx(2, si));
    fprintf('.'); if 0 == mod(si, 100), fprintf('\n\t'); end
end
fprintf('\n');

    function expand_one(seq_m, qry_s, tgt_s)
        
        [qry_imd, tgt_imd, qry_ima, tgt_ima, qry_imc, tgt_imc, topleft] = ...
            load_image(datao, seq_m, qry_s, tgt_s);
        
        [v2d_q, v2d_m] = Completion.SIFTFlowMatch( ...
            qry_imd, qry_imc, qry_ima, ...
            tgt_imd, tgt_imc, tgt_ima, ...
            fextor, 0);
        write_3d_matches(regf, bin_w, qry_imd, tgt_imd, v2d_q, v2d_m, topleft);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function write_3d_matches(regf, bin_w, qry_imd, tgt_imd, v2d_q, v2d_m, topleft)

% reconstruct 3d point
p3d_query = Completion.Depth2PC(qry_imd, v2d_q, topleft.query);
p3d_match = Completion.Depth2PC(tgt_imd, v2d_m, topleft.match);

% write out initial correspondences
fid = fopen(regf, 'a');
nm = size(p3d_query, 2);
if bin_w
    fwrite(fid, nm, 'uint32');
else
    fprintf(fid, '%d\n', nm);
end
for i = 1:nm
    if bin_w
        fwrite(fid, p3d_query(:, i), 'float');
        fwrite(fid, p3d_match(:, i), 'float');
    else
        fprintf(fid, '%f %f %f\n', p3d_query(1, i), p3d_query(2, i), p3d_query(3, i));
        fprintf(fid, '%f %f %f\n', p3d_match(1, i), p3d_match(2, i), p3d_match(3, i));
    end
end
fclose(fid);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [qry_imd, tgt_imd, qry_ima, tgt_ima, qry_imc, tgt_imc, topleft] = ...
    load_image(datao, seq_m, qry_s, tgt_s)

[qry_imd, qry_imc, qry_ima] = datao.LoadImage( ...
    sprintf('%s/%s', datao.rpath.data, datao.mlist(seq_m).name), ...
    datao.mlist(seq_m).imgl(qry_s, :));

[tgt_imd, tgt_imc, tgt_ima] = datao.LoadImage( ...
    sprintf('%s/%s', datao.rpath.data, datao.mlist(seq_m).name), ...
    datao.mlist(seq_m).imgl(tgt_s, :));

if 2 == size(datao.mlist(seq_m).imgl, 2)
    topleft.query = [1, 1];
    topleft.match = [1, 1];
else
    fid = fopen(sprintf('%s/%s/%s', datao.rpath.data, datao.mlist(seq_m).name, ...
        datao.mlist(seq_m).imgl{qry_s, 4}), 'r');
    topleft.query = fscanf(fid, '%d,%d');
    fclose(fid);
    fid = fopen(sprintf('%s/%s/%s', datao.rpath.data, datao.mlist(seq_m).name, ...
        datao.mlist(seq_m).imgl{tgt_s, 4}), 'r');
    topleft.match = fscanf(fid, '%d,%d');
    fclose(fid);
end

end

