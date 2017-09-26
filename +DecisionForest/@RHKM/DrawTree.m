function hfig = DrawTree(obj)

if 0 >= obj.num_elem, return; end

%
scrsz = get(0, 'ScreenSize');
scrsz = [50 50 scrsz(3)-100 scrsz(4)-150];
hfig = figure('Position', scrsz);
set(gcf, 'Color', 'w');
%
Utility.subaxis(4, 1, 1, 1, 1, 1, 'Spacing',0, 'Padding',0.03, 'Margin',0);
hold on;
leaf_cnt = cellfun(@numel, {obj.leaf_tbl.ran});
bar(leaf_cnt);
axis tight
set(gca, 'Box','off')
%
Utility.subaxis(4, 1, 1, 2, 1, 3, 'Spacing',0, 'Padding',0.03, 'Margin',0);
treeplot(double([obj.node_tbl.pid]));
axis tight off;
%

end

