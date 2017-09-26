function hfig = DrawLeaf(obj, clabList, vcenList, plot_sz)

if 3 > nargin, plot_sz = 200; end

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
clr_arr = hsv(obj.num_lab);

for di = 1:plot_num
    Utility.subaxis(plot_row, plot_col, di, 'Spacing',0, 'Padding',0.03, 'Margin',0);
    lab = clabList(:, obj.leaf_tbl(plot_indx(di)).rang);
%     [~, ~, n] = unique(lab);
    cen = vcenList(:, obj.leaf_tbl(plot_indx(di)).rang);
    hold on;
    scatter(cen(1, :), cen(2, :), 10, clr_arr(lab, :), '*');
    cen = obj.leaf_tbl(plot_indx(di)).cen;
    plot(cen(1), cen(2), 'k*', 'MarkerSize',10);
    if 0 == obj.leaf_tbl(plot_indx(di)).label
        plot(0, 0, 'ko', 'MarkerSize',10);
    elseif -1 == obj.leaf_tbl(plot_indx(di)).label
        plot(0, 0, 'kd', 'MarkerSize',10);
    else
        plot(0, 0, 'k+', 'MarkerSize',10);
    end
    xlim([-plot_sz plot_sz]);
    ylim([-plot_sz plot_sz]);
    title(num2str(plot_indx(di)));
end

end

