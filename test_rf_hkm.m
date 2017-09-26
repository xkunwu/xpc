fclose('all'); close all hidden; clear;
tic; fprintf('%s >> testing ...\n', datestr(now));

opts.rtbdr.num_tree = 1;
opts.rtbdr.num_brch = 4;
opts.rtbdr.rnd_rate = 1;
opts.rtbdr.min_leaf = opts.rtbdr.num_brch;
opts.rtbdr.max_hght = 8;

plot_size = 0.9; step_len = 0.1;
num_sample = numel(-plot_size:step_len:plot_size);
num_sample = num_sample*num_sample;
[X, Y] = meshgrid(-plot_size:step_len:plot_size, -plot_size:step_len:plot_size);
fvecList = [reshape(X, [1, num_sample]); reshape(Y, [1, num_sample])];

rforest = DecisionForest.RHKM(opts.rtbdr);
rforest.HKMeans(fvecList);
% hfig = rforest.DrawLeaf(fvecList, 1);
% rforest.DrawTree();

rforest.GenCodeBk();

fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

