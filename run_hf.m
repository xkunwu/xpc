fclose('all'); close all hidden; clc; clear;

%% initialize parameters
% opts.paths.dataroot = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\data\';
% opts.paths.inroot = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\input\';
% opts.paths.outroot = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\output\';

% opts.paths.dataroot = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\data\';
% opts.paths.inroot = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\input\';
% opts.paths.outroot = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\output\';

% opts.paths.dataroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\data\';
% opts.paths.outroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\output\';
opts.paths.dataroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\data_2\';
opts.paths.outroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\output_2\';
% opts.paths.dataroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\data_1\';
% opts.paths.outroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\output_1\';
opts.paths.inroot = '/HPS/rtface/work/part_scan/uw_data/object_collection\input\';

opts.paths.dataroot(opts.paths.dataroot == '\') = '/';
opts.paths.inroot(opts.paths.inroot == '\') = '/';
opts.paths.outroot(opts.paths.outroot == '\') = '/';

if ~ exist(opts.paths.outroot, 'dir'), mkdir(opts.paths.outroot); end
% diary mode
diary(sprintf('%s/diary_%s', opts.paths.outroot, date));
diary on
lmup


%% extract feature
opts.fextr.step = 10;

if exist(sprintf('%s/cws.mat', opts.paths.outroot), 'file')
    load(sprintf('%s/cws.mat', opts.paths.outroot), '-mat');
    fprintf('\ndate set object loaded\n');
else
    uw_obj = FolderProc.UWDataProc(opts.paths);
    uw_obj.collect_features(opts.fextr.step);
    save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', 'uw_obj', 'opts');
end
save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', '-append', 'opts');


%% training Hough forest
opts.htree.num_tree = 1;
opts.htree.min_leaf = 16;
opts.htree.max_hght = 20;
opts.htree.num_try = 500;
opts.htree.force_redo = true; % true; false;
opts.htree.draw_tree = true; % true; false;
opts.htree.draw_vote = false; % true; false;

reply = 'N';
if ~exist('hforest', 'var')
    reply = 'Y';
else
    if opts.htree.force_redo
        reply = input('\nrebuild Hough forest? Y/N [N]: ', 's');
        if isempty(reply), reply = 'N'; end;
    end
end
if 'Y' == reply
    hforest = HoughForest.HForest(opts.htree);
    tic; fprintf('\ntraining ...\n');
    fprintf('%d features\n', uw_obj.agent.fextr.finfo.nfeat);
    hforest.Train(uw_obj.agent.fextr, opts.fextr.step);
    fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
    save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', '-append', 'hforest');
    hforest.Draw(uw_obj.agent.fextr, opts.paths.outroot, opts.htree.draw_tree);
else
    fprintf('\nHough forest already trained\n');
end
save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', '-append', 'opts');
clear reply;


%% detection by regression
% opts.dtect.step = 10;
% 
% tic; fprintf('\ndetecting ...\n');
% hfdetect = Detector.Detector_HF(uw_obj);
% hfdetect.Detect(uw_obj, hforest, opts.dtect.step, opts.htree.draw_vote);
% fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
% save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', '-append', 'opts');


