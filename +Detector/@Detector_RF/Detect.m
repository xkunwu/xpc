function Detect(obj, fextor, rforest, opt)
obj.disth = opt.disth;
% load files
fid = fopen(fextor.fname.invx, 'rb');
clabList = fread(fid, [2, fextor.finfo.nfeat], '*uint32');
fclose(fid);
clabList = clabList(1, :);
fid = fopen(fextor.fname.vcen, 'rb');
vcenList = fread(fid, [2, fextor.finfo.nfeat], '*single');
fclose(fid);

obj.list_file();
for ii = 1:obj.num_bg
    % load image & extract feature
    [img_depth, img_color, img_alpha] = fextor.datao.LoadImage( ...
        obj.inroot, obj.nlist.imgl(ii, :));
    [desc, fram] = fextor.ExtrMask(img_depth, img_color, img_alpha, 1);
    imsz = size(img_depth);
    imcard = imsz(1) * imsz(2);
    numf = size(desc, 2);
    fprintf('\tfeature prepared\n');
    % nearest matching
    ximg = zeros(imsz);
    simg = zeros(imsz);
    pre_mat(opt.disth);
    clear desc;
    fprintf('\ttemplate precomputed\n');
    % patch classification
    vpat = vote_patch(opt.nump);
    fprintf('\tpatch matching done\n');
    % draw result
    draw_result(opt.nump, opt.disth);
    fprintf('\tsaved\n');
end

    function pre_mat(disth)
        % nearest matching
        [nidx, ndst] = rforest.MatchLeaf(desc, fextor);
        ndst = ndst / fextor.finfo.flen;
        
        % erase noisy points
        idx = 1:numf;
        idx(disth < ndst) = [];
        numf = numel(idx);
        fram = fram(:, idx);
        nidx = nidx(idx);
        ndst = ndst(idx);
        
        % build voting template
        cidx = clabList(nidx);
        disp(histc(cidx, unique(cidx)));
        for fi = 1:numf
            ximg(fram(2, fi), fram(1, fi)) = nidx(fi);
            simg(fram(2, fi), fram(1, fi)) = ndst(fi);
        end
    end

    function vpat = vote_patch(nump)
        vpat.orig = generate_patches(obj.patpt.szpat, imsz, nump);
        vpat.vote = zeros(1, nump);
        vpat.weit = zeros(1, nump);
        for ti = 1:nump
            % patch locations
            patpX = vpat.orig(ti, 1) + obj.patpt.X;
            patpY = vpat.orig(ti, 2) + obj.patpt.Y;
            lidx = sub2ind(imsz, patpX, patpY);
            tix = (0 == ximg(lidx));
            lidx(tix) = []; patpX(tix) = []; patpY(tix) = [];
            if isempty(lidx), continue; end
            % class label for linearized indices
            clidx = clabList(ximg(lidx));
            cpat = unique(clidx);
            hcc = histc(clidx, cpat);
            [cv, ci] = max(hcc);
            vpat.weit(ti) = cv / numel(clidx);
            % exclude impure patch
            if 0.8 > vpat.weit(ti), continue; end
            vpat.vote(ti) = cpat(ci);
            % compute voting center
            patpX = round(patpX + vcenList(2, ximg(lidx)));
            patpY = round(patpY + vcenList(1, ximg(lidx)));
            idx = (1 <= patpX & imsz(1) >= patpX ...
                & 1 <= patpY & imsz(2) >= patpY);
            if 0 == sum(idx), vpat.vote(ti) = 0; continue; end
            % test center: (0 < sum(2 < abs(patpX ~= imsz(1)/2))) || (0 < sum(2 < abs(patpY ~= imsz(2)/2)))
            vpat.cent{ti} = sub2ind(imsz, patpX(idx), patpY(idx));
            vpat.lidx{ti} = lidx(idx);
        end
    end

    function draw_result(nump, disth)
        num_m = fextor.datao.minfo.cnt;
        % accumulate voting results
        votim = zeros([imcard, 1, num_m]);
        for ti = 1:nump
            if 0 == vpat.vote(ti), continue; end
            votim(vpat.cent{ti}, 1, vpat.vote(ti)) = vpat.weit(ti) * exp(- simg(vpat.lidx{ti}) / disth);
        end
        votim = reshape(votim, [imsz, 1, num_m]);
        % setup for drawing
        votim_draw = zeros([imsz, 3, num_m]);
        for mi = 1:num_m
            votim(:, :, :, mi) = imfilter(100 * votim(:, :, :, mi), fspecial('gaussian', [40 40], 5));
            votim_draw(:, :, :, mi) = sc(cat(3, votim(:, :, :, mi), img_color), 'prob');
        end
        % drawing & saving
        hfig = figure('Visible','off');
        sc(votim_draw, [min(votim_draw(:)), max(votim_draw(:))]);
        saveas(hfig, sprintf('%s/%s', obj.out_hf, obj.nlist.iseq{ii}), 'png');
        save(sprintf('%s/%s.mat', obj.out_hf, obj.nlist.iseq{ii}), '-mat', ...
            'votim', 'votim_draw', 'ximg', 'simg');
        close(hfig);
    end
end

function pato = generate_patches(szpat, imsz, nump)
imsz = imsz - szpat + 1;
pato = horzcat(randsample(imsz(1), nump, true), ...
    randsample(imsz(2), nump, true));
end
