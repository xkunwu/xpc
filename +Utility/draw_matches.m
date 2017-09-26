function draw_matches(img_src, img_tgt, v2d_src, v2d_tgt)

indx = 0 < v2d_tgt(1, :);
v2d_src = v2d_src(:, indx);
v2d_tgt = v2d_tgt(:, indx);

dh1 = max(size(img_tgt, 1) - size(img_src, 1), 0);
dh2 = max(size(img_src, 1) - size(img_tgt, 1), 0);
o = size(img_src, 2);

figure;
if 2 < ndims(img_src)
    sc([padarray(img_src, dh1, 'post') padarray(img_tgt, dh2, 'post')]);
%     image([padarray(img_src, dh1, 'post') padarray(img_tgt, dh2, 'post')]);
else
    sc([padarray(img_src, dh1, 'post') padarray(img_tgt, dh2, 'post')]);
%     imagesc([padarray(img_src, dh1, 'post') padarray(img_tgt, dh2, 'post')]);
end
hold on;
if ~ isempty(v2d_src)
    clr_odr = hsv(size(v2d_src, 2));
    set(gca, 'ColorOrder', clr_odr);
    line([v2d_src(2, :); v2d_tgt(2, :) + o], [v2d_src(1, :); v2d_tgt(1, :)]);
    scatter([v2d_src(2, :), v2d_tgt(2, :) + o], [v2d_src(1, :), v2d_tgt(1, :)], ...
        20, [clr_odr; clr_odr], '*');
end
% title(sprintf('%d inliner matches', size(v2d_src, 2)), 'Color','k');
hold off;
% axis image tight off;

% set(gca, 'Position', get(gca, 'OuterPosition'));
% set(gca, 'Position', get(gca, 'OuterPosition') - get(gca, 'TightInset') * [-1 0 1 0; 0 -1 0 1; 0 0 1 0; 0 0 0 1]);

end

