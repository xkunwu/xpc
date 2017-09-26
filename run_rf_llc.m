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
opts.paths.inroot = '/HPS/rtface/work/part_scan/uw_data/object_collection/input';

opts.paths.dataroot(opts.paths.dataroot == '\') = '/';
opts.paths.inroot(opts.paths.inroot == '\') = '/';
opts.paths.outroot(opts.paths.outroot == '\') = '/';

if ~ exist(opts.paths.outroot, 'dir'), mkdir(opts.paths.outroot); end
% diary mode
diary(sprintf('%s/diary_%s', opts.paths.outroot, date));
diary on;
lmup;
% initialize matlabpool
if 0 == matlabpool('size'), matlabpool; end
fprintf('\nnumber of workers: %d\n', matlabpool('size'));
% flag for rebuid
reply = 'N';


%% extract feature
opts.fextr.step = 2;

if exist(sprintf('%s/cws.mat', opts.paths.outroot), 'file')
    load(sprintf('%s/cws.mat', opts.paths.outroot), '-mat');
    fprintf('\ndate set object loaded\n');
else
    uw_obj = FolderProc.UWDataProc(opts.paths);
    uw_obj.collect_features(opts.fextr.step);
    save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', 'uw_obj', 'opts');
    reply = 'Y';
end


%% retrieval tree construction
opts.rtbdr.num_tree = 1;
opts.rtbdr.num_brch = 10;
opts.rtbdr.rnd_rate = 1;
opts.rtbdr.min_leaf = opts.rtbdr.num_brch;
opts.rtbdr.max_hght = 4;
opts.htree.force_redo = false; % true; false;

if ~exist(sprintf('%s/cws_rf.mat', opts.paths.outroot), 'file') || 'Y' == reply
    reply = 'Y';
elseif opts.htree.force_redo
    reply = input('\nrebuild random forest? Y/N [N]: ', 's');
    if isempty(reply), reply = 'N'; end;
end
if 'Y' == reply
    if exist(sprintf('%s/cws_rf.mat', opts.paths.outroot), 'file')
        delete(sprintf('%s/cws_rf.mat', opts.paths.outroot));
    end
    % constructor
    rforest = DecisionForest.RHKM(opts.rtbdr);
    % build tree
    tic; fprintf('\nconstructing random forest ...\n');
    fprintf('%d features\n', uw_obj.agent.fextr.finfo.nfeat);
    rforest.BuildTree(uw_obj.agent.fextr, uw_obj.agent.fextr.fname);
    fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
    save(sprintf('%s/cws_rf.mat', opts.paths.outroot), '-mat', 'rforest');
    % drawing
    hfig = rforest.DrawTree();
    saveas(hfig, sprintf('%s/tree_rand', opts.paths.outroot), 'fig');
else
    load(sprintf('%s/cws_rf.mat', opts.paths.outroot), '-mat');
    fprintf('\nRandom forest already trained\n');
end


%% LLC encode
opts.encode.force_redo = false; % true; false;

if ~exist(sprintf('%s/cws_llc.mat', opts.paths.outroot), 'file') || 'Y' == reply
    reply = 'Y';
elseif opts.htree.force_redo
    reply = input('\nrerun encoding? Y/N [N]: ', 's');
    if isempty(reply), reply = 'N'; end;
end
if 'Y' == reply
    if exist(sprintf('%s/cws_llc.mat', opts.paths.outroot), 'file')
        delete(sprintf('%s/cws_llc.mat', opts.paths.outroot));
    end
    % constructor
    encoder = Encoding.LLCEncoder();
    encoder.norm_type = 'none';
    encoder.max_comps = 0;
    % generate & set code book
    tic; fprintf('\ngenerating code book ...\n');
    encoder.set_codebook(rforest.GenCodeBk());
    fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
    % load feature array
    fid = fopen(uw_obj.agent.fextr.fname.desc, 'rb');
    sift_desc = fread(fid, [uw_obj.agent.fextr.finfo.flen, ...
        uw_obj.agent.fextr.finfo.nfeat], 'uint8=>single');
    fclose(fid);
    % encode
    tic; fprintf('\nLLC encoding ...\n');
    lle_code = encoder.encode(sift_desc);
    save(sprintf('%s/cws_llc.mat', opts.paths.outroot), '-mat', 'lle_code', 'encoder');
    fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
else
    load(sprintf('%s/cws_llc.mat', opts.paths.outroot), '-mat');
    fprintf('\nLLE code already encoded\n');
end
fprintf('[%d, %d] code book.\n', encoder.get_input_dim(), encoder.get_output_dim());
clear fid sift_desc;


%% detection by matching
opts.dtect.step = 3;
opts.dtect.szpat = 9;
opts.dtect.nump = 100000;

tic; fprintf('\ndetecting ...\n');
fprintf('%d sampled patches.\n', opts.dtect.nump);
rfdetect = Detector.Detector_RF_LLC(uw_obj, opts.dtect.szpat, opts.dtect.step);
rfdetect.Detect(uw_obj, lle_code, encoder, opts.dtect.nump);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);


%% save modified options
save(sprintf('%s/cws.mat', opts.paths.outroot), '-mat', '-append', 'opts');

