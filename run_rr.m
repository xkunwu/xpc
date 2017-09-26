fclose('all'); close all hidden; clc; clear;

%% initialize matlabpool
% if 0 == matlabpool('size'), matlabpool(2); end
% fprintf('\nnumber of workers: %d\n', matlabpool('size'));

%% initialize parameters
% opts.paths.data = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\data\';
% opts.paths.in = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\input\';
% opts.paths.out = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\output\';

% opts.paths.data = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\data\';
% opts.paths.in = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\input\';
% opts.paths.out = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\output\';

% opts.paths.data = '/HPS/rtface/work/part_scan/uw_data/object_collection\data\';
% opts.paths.out = '/HPS/rtface/work/part_scan/uw_data/object_collection\output\';
opts.paths.data = '/HPS/rtface/work/part_scan/uw_data/object_collection\data_2\';
opts.paths.out = '/HPS/rtface/work/part_scan/uw_data/object_collection\output_2\';
% opts.paths.data = '/HPS/rtface/work/part_scan/uw_data/object_collection\data_1\';
% opts.paths.out = '/HPS/rtface/work/part_scan/uw_data/object_collection\output_1\';
opts.paths.in = '/HPS/rtface/work/part_scan/uw_data/object_collection/input';

opts.paths.data(opts.paths.data == '\') = '/';
opts.paths.in(opts.paths.in == '\') = '/';
opts.paths.out(opts.paths.out == '\') = '/';

if ~ exist(opts.paths.out, 'dir'), mkdir(opts.paths.out); end

%% diary mode
diary(sprintf('%s/diary_%s', opts.paths.out, date));
diary on;

%% local startup
lmup;

%% flag for rebuid
force_redo = false; % true; false;


%% create data object
opts.datao.step = 2;

if ~exist(sprintf('%s/cws.mat', opts.paths.out), 'file') || force_redo
    uw_obj = FolderProc.UWDataProc(opts);
    save(sprintf('%s/cws.mat', opts.paths.out), '-mat', '-v7.3', 'uw_obj');
    force_redo = true;
    uw_obj.Im2PC();
else
    load(sprintf('%s/cws.mat', opts.paths.out), '-mat');
    fprintf('\ndate set object loaded\n');
end


%% extract features
opts.fextr.step = 2;

if ~exist(sprintf('%s/cws_fe.mat', opts.paths.out), 'file') || force_redo
    fextor = Feature.Proxy(uw_obj, opts.fextr);
    save(sprintf('%s/cws_fe.mat', opts.paths.out), '-mat', '-v7.3', 'fextor');
    force_redo = true;
else
    load(sprintf('%s/cws_fe.mat', opts.paths.out), '-mat');
    fprintf('\nfeature extractor loaded\n');
end


%% sequential registration
opts.rotreg.seqsn = 2;
opts.rotreg.bin_w = false; % true; false;

tic; fprintf('%s >> exporting registration files ...\n', datestr(now));
Registration.RotReg(uw_obj, fextor, opts.rotreg);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

