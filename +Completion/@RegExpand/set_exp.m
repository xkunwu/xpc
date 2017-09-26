function [new_scn_idx, qry_mat] = set_exp(obj, seq_x, step, rexpar)

[mod_x, scn_x] = obj.s2cm(seq_x);
qry_mat = [];
num_qry = numel(seq_x);
for seq = 1:num_qry
    % top-k retrieval
    qry_desc = load_feature(obj, mod_x(seq), scn_x(seq));
    [scntr, topk] = Completion.TopK(qry_desc, obj.fextor, obj.rforest, mod_x(seq), rexpar.ret_k);

    idx = (size(qry_desc, 2) * rexpar.ratio < scntr) & scn_x(seq) ~= topk;
    scntr = scntr(idx); topk = topk(idx);
    cnt = sum(idx);
    qry_mat = horzcat(qry_mat, ...
        [repmat(scn_x(seq), [1, cnt]); topk'; -scntr'; repmat(step, [1, cnt])]);
end

if isempty(qry_mat)
    new_scn_idx = [];
else
    new_scn_idx = unique(qry_mat(2, :));
end

end
