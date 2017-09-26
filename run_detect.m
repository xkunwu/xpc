run_local;
% run_rf;
if ~exist('rforest', 'var'), fprintf(2, '\nNo data!.\n'); return; end


%% detection by matching
opts.dtect.step = 3;
opts.dtect.szpat = 9;
opts.dtect.nump = 1000;
opts.dtect.disth = 1000; % Inf; use Inf to export full distance map

if ~exist(sprintf('%s/cws_dt.mat', opts.paths.out), 'file') || force_redo
    tic; fprintf('\ndetecting ...\n');
    fprintf('%d sampled patches.\n', opts.dtect.nump);
    rdetect = Detector.Detector_RF(uw_obj, opts.dtect);
    rdetect.Detect(fextor, rforest, opts.dtect);
    fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
    reply = 'N';
    save(sprintf('%s/cws_dt.mat', opts.paths.out), '-mat', '-v7.3', 'rdetect');
else
    load(sprintf('%s/cws_dt.mat', opts.paths.out), '-mat');
    fprintf('\nDetection skipped.\n');
end


%% region matching
opts.rexp.drawc = 0; % positive: force draw; 0: mute; negtive: draw on mismatches

bbmatch = Completion.BBoxMatch();
bbmatch.PrepBG(uw_obj, fextor, rforest, rdetect, opts);
Tc = bbmatch.mdsn.md; topmid = bbmatch.mdsn.sn;
% Tc = 1; topmid = 11;

%% object registration
opts.rexp.ratio = 1e-4;
opts.rexp.ret_k = 5;

regexer = Completion.RegExpand(uw_obj, fextor, rforest);
tgt_spt = regexer.ExpandFromOne(Tc, topmid, opts.rexp);
% tgt_spt = 2;


%% append completion
tic; fprintf('\nappending completion anchor ...\n');
bbmatch.Write3dM(tgt_spt);
fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);


%%
return;
[~, tgt_imd, ~] = FolderProc.UWDataProc.load_image( ...
    sprintf('%s/%s', uw_obj.dir_root, uw_obj.minfo.list(Tc).name), ...
    uw_obj.minfo.list(Tc).imgl(topmid, :));

