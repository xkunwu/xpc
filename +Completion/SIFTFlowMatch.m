function [msrc, mtgt] = SIFTFlowMatch(qry_imd, qry_imc, qry_ima, tgt_imd, tgt_imc, tgt_ima, ...
    fextor, fmkth, draw_m, step)
if 10 > nargin, step = 2; end
if 9 > nargin, draw_m = 0; end
if 8 > nargin, fmkth = -1; end

% extract feature
if 0 > fmkth
    [qry_desc, qry_fram, qry_ima] = fextor.ExtrMask(qry_imd, qry_imc, qry_ima, step);
else
    [qry_desc, qry_fram, qry_ima] = fextor.ExtrMask(qry_imd, qry_imc, qry_ima, step, fmkth);
end
qry_desc = cast(qry_desc, 'uint8');
qimsz = size(qry_ima);
if 0 > fmkth
    [tgt_desc, tgt_fram, tgt_ima] = fextor.ExtrMask(tgt_imd, tgt_imc, tgt_ima, step);
else
    [tgt_desc, tgt_fram, tgt_ima] = fextor.ExtrMask(tgt_imd, tgt_imc, tgt_ima, step, fmkth);
end
tgt_desc = cast(tgt_desc, 'uint8');
timsz = size(tgt_ima);

% transform data format
qry_desc_2 = zeros([qimsz(1)*qimsz(2), fextor.finfo.flen], 'uint8');
qry_desc_2(sub2ind(qimsz, qry_fram(2, :), qry_fram(1, :)), :) = qry_desc';
qry_desc_2 = reshape(qry_desc_2, [qimsz, fextor.finfo.flen]);

tgt_desc_2 = zeros([timsz(1)*timsz(2), fextor.finfo.flen], 'uint8');
tgt_desc_2(sub2ind(timsz, tgt_fram(2, :), tgt_fram(1, :)), :) = tgt_desc';
tgt_desc_2 = reshape(tgt_desc_2, [timsz, fextor.finfo.flen]);

% compute correspondences
sfpara.alpha=2*255;
sfpara.d=40*255;
sfpara.gamma=0.005*255;
sfpara.nlevels=4;
sfpara.wsize=2;
sfpara.topwsize=10;
sfpara.nTopIterations = 60;
sfpara.nIterations= 30;
[vx, vy, ~] = SIFTFlow.SIFTflowc2f(qry_desc_2, tgt_desc_2, sfpara);
%         warpI2 = SIFTFlow.warpImage(tgt_imc, vx, vy);
%         figure;sc(qry_imc);figure;sc(warpI2);

% map to matching pairs
[XX, YY] = meshgrid(1:qimsz(2), 1:qimsz(1));
msrc = [YY(:), XX(:)]';
XX = XX+vx; YY = YY+vy;
mtgt = [YY(:), XX(:)]';
mask = XX>=1 & XX<=timsz(2) & YY>=1 & YY<=timsz(1); % end point within target image's border
mask = mask & qry_ima; % source image masking
msrc = msrc(:, mask(:));
mtgt = mtgt(:, mask(:));
mask = tgt_ima(sub2ind(timsz, mtgt(1, :), mtgt(2, :))); % target image masking
msrc = msrc(:, mask(:));
mtgt = mtgt(:, mask(:));

% drawing
if 0 == draw_m, return; end
numm = sum(mask(:));
mask = 1:numm;
mask = randsample(mask, min(50, numm));
% figure;
draw_matches(qry_imc, tgt_imc, ...
    msrc(:, mask), mtgt(:, mask));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function draw_matches(img_query, img_match, v2d_q, v2d_m)

dh1 = max(size(img_match, 1) - size(img_query, 1), 0);
dh2 = max(size(img_query, 1) - size(img_match, 1), 0);
o = size(img_query, 2);

sc([padarray(img_query, dh1, 'post') padarray(img_match, dh2, 'post')]);
hold on;
if ~ isempty(v2d_q)
    clr_odr = hsv(size(v2d_q, 2));
    set(gca, 'ColorOrder', clr_odr);
    line([v2d_q(2, :); v2d_m(2, :) + o], [v2d_q(1, :); v2d_m(1, :)]);
    scatter([v2d_q(2, :), v2d_m(2, :) + o], [v2d_q(1, :), v2d_m(1, :)], ...
        20, [clr_odr; clr_odr], '*');
end
hold off;

% [frim, Map] = frame2im(getframe(hfig));
% if ~isempty(Map), frim = ind2rgb(frim, Map); end

end

