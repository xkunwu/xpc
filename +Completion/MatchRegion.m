function [Tc, topmid, msrc, mtgt] = MatchRegion(fextor, rforest, rdetect, disth, draw_m)

% crop image & extract feature
[qry_imd, qry_imc, qry_ima] = fextor.datao.LoadImage( ...
    rdetect.inroot, rdetect.get_comp_imgl());
[BBox, Tc] = rdetect.CalcBB(fextor.datao);
qry_imd_c = imcrop(qry_imd, BBox);
qry_imc_c = imcrop(qry_imc, BBox);
qry_ima_c = imcrop(qry_ima, BBox);
[qry_desc, ~, ~] = fextor.ExtrMask(qry_imd_c, qry_imc_c, qry_ima_c, 1);
% decide best matching scene id
[~, topmid] = Completion.TopK(qry_desc, fextor, rforest, Tc, 1, disth);
% topmid = 11;

% load target best match
[tgt_imd, tgt_imc, tgt_ima] = fextor.datao.LoadImage( ...
    sprintf('%s/%s', fextor.datao.rpath.data, fextor.datao.mlist(Tc).name), ...
    fextor.datao.mlist(Tc).imgl(topmid, :));

% matching
[msrc, mtgt] = Completion.SIFTFlowMatch(qry_imd_c, qry_imc_c, qry_ima_c, tgt_imd, tgt_imc, tgt_ima, ...
    fextor, draw_m);

% restore coordinate
msrc(1, :) = msrc(1, :) + BBox(2);
msrc(2, :) = msrc(2, :) + BBox(1);

end

