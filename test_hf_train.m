fclose('all'); close all hidden; clear;
tic; fprintf('%s >> testing ...\n', datestr(now));

% min_leaf = 4; max_depth = 3; num_try = 10;
% len_feat = 16; num_class = 1;
plot_size = 0.9; step_len = 0.1;
min_leaf = 16; max_depth = 5; num_try = 1000;
len_feat = 2; num_class = 1;
% plot_size = 0.99; step_len = 0.01;

num_sample = numel(-plot_size:step_len:plot_size);
num_sample = num_sample*num_sample;
[X, Y] = meshgrid(-plot_size:step_len:plot_size, -plot_size:step_len:plot_size);
cenL = [reshape(X, [1, num_sample]); reshape(Y, [1, num_sample])];

ht = HoughForest.HTree(min_leaf, max_depth, num_try);

% fvecList = -1 + 2*rand([len_feat, num_sample]);
fvecList = cenL;
% fvecList(:, 1:round(num_sample/3)) = cenL(:, num_sample-round(num_sample/3)+1:num_sample);
% fvecList(:, num_sample-round(num_sample/3)+1:num_sample) = cenL(:, 1:round(num_sample/3));
% fvecList = cenL(:, randperm(num_sample));
clabList = randi(num_class, [1, num_sample]);
% vcenList = randn([2, num_sample]);
vcenList = cenL;

% clr_arr = hsv(num_class+1);
% [~, ordx] = sort(clabList);
% fls = vcenList(:, ordx);
% [~, ~, uniq_indx] = unique(clabList);
% fls = mat2cell(fls, 2, accumarray(uniq_indx(:), 1));
% figure;
% set(gcf, 'Color', 'w');
% hold on;
% for ci = 1:num_class
%     cen = fls{ci};
%     scatter(cen(1, :), cen(2, :), 10, clr_arr(ci, :), '*');
% end
% xlim([-1 1]);
% ylim([-1 1]);

ht.Train(fvecList, clabList, vcenList, step_len);
hfig = ht.DrawLeaf(clabList, vcenList, 1);
saveas(hfig, sprintf('leaf_%d_%d_%d_%d', max_depth, num_try, len_feat, num_class), 'fig');
% hfig = ht.DrawTree();
% saveas(hfig, sprintf('tree_%d_%d_%d_%d', max_depth, num_try, len_feat, num_class), 'fig');

fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);


% min(cellfun(@numel, {ht.leaf_tbl.rang}));

