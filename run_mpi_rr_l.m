fclose('all'); close all hidden; clc; clear;

%% initialize matlabpool
% if 0 == matlabpool('size'), matlabpool(2); end
% fprintf('\nnumber of workers: %d\n', matlabpool('size'));

%% initialize parameters
% opts.paths.root = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\uw_data\uw_obj_1\';
opts.paths.root = 'c:\Users\xwu\Documents\FaceReco\software\partial_scan\mpi_data\kinect_obj\';

% opts.paths.root = 'e:\Workstation\DataCenter\uw_data\uw_obj_1\';

% opts.paths.root = '/HPS/rtface/work/part_scan/uw_data/object_collection\';
% opts.paths.root = '/HPS/rtface/work/part_scan/uw_data/object_collection_1\';
% opts.paths.root = '/HPS/rtface/work/part_scan/uw_data/object_collection_2\';

opts.paths.data = [opts.paths.root '\data\'];
opts.paths.in = [opts.paths.root '\input\'];
opts.paths.out = [opts.paths.root '\output\'];

opts.paths.root(opts.paths.root == '\') = '/';
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
opts.datao.step = 5;

if ~exist(sprintf('%s/cws.mat', opts.paths.out), 'file') || force_redo
    data_obj = FolderProc.MPIDataProc(opts);
    save(sprintf('%s/cws.mat', opts.paths.out), '-mat', '-v7.3', 'data_obj');
    force_redo = true;
    data_obj.Im2PC();
else
    load(sprintf('%s/cws.mat', opts.paths.out), '-mat');
    fprintf('\ndate set object loaded\n');
end

return;


%% extract features
opts.fextr.step = 2;

if ~exist(sprintf('%s/cws_fe.mat', opts.paths.out), 'file') || force_redo
    fextor = Feature.Proxy(data_obj, opts.fextr);
    save(sprintf('%s/cws_fe.mat', opts.paths.out), '-mat', '-v7.3', 'fextor');
    force_redo = true;
else
    load(sprintf('%s/cws_fe.mat', opts.paths.out), '-mat');
    fprintf('\nfeature extractor loaded\n');
end


%% sequential registration
opts.rotreg.seqsn = 1;
opts.rotreg.bin_w = false; % true; false;

tic; fprintf('%s >> exporting registration files ...\n', datestr(now));
Registration.RotReg(data_obj, fextor, opts.rotreg);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

