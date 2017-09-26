function hfig = DrawLeaf(obj, fvecList, plot_sz)

if 3 > nargin, plot_sz = 200; end

fvecList = fvecList(1:2, :);

scrsz = get(0, 'ScreenSize');
scrsz = [50 50 scrsz(3)-100 scrsz(4)-150];

plot_row = floor(scrsz(4) / 200);
plot_col = floor(scrsz(3) / 200);
plot_num = plot_row * plot_col;

if plot_num < obj.num_leaf
    plot_indx = sort(randsample(obj.num_leaf, plot_num));
else
    plot_indx = 1:obj.num_leaf;
    plot_num = double(obj.num_leaf);
end

hfig = figure('Position', scrsz);
set(gcf, 'Color', 'w');
clr_arr = hsv(4);

for di = 1:plot_num
    Utility.subaxis(plot_row, plot_col, di, 'Spacing',0, 'Padding',0.03, 'Margin',0);
    ran = obj.leaf_tbl(plot_indx(di)).ran;
    hold on;
    scatter(fvecList(1, ran), fvecList(2, ran), 10, clr_arr(3, :), '*');

    xlim([-plot_sz plot_sz]);
    ylim([-plot_sz plot_sz]);
    title(num2str(plot_indx(di)));
end

end

