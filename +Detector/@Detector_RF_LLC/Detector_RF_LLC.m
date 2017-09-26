classdef Detector_RF_LLC < handle
    
    properties
        inroot
        out_hf
        names
        num_bg
        nlist
        
        patpt
    end
    
    methods
        function obj = Detector_RF_LLC(data_obj, szpat, fstep)
            obj.inroot = data_obj.in_root;
            obj.out_hf = [data_obj.out_root, '/hf_result'];
            if ~ exist(obj.out_hf, 'dir'), mkdir(obj.out_hf); end

            obj.names.depth = 'depth';
            obj.names.color = 'color';
            
            obj.patpt.lstep = fstep;
            obj.patpt.szpat = fstep*szpat;
            
            % template patch location
            vpp = 0:obj.patpt.lstep:(obj.patpt.szpat-1);
            numpp = numel(vpp);
            obj.patpt.numpp = numpp;
            obj.patpt.numpp2 = numpp*numpp;
            [obj.patpt.X, obj.patpt.Y] = meshgrid(vpp, vpp);
            obj.patpt.X = reshape(obj.patpt.X, [1, obj.patpt.numpp2]);
            obj.patpt.Y = reshape(obj.patpt.Y, [1, obj.patpt.numpp2]);
        end
        
        function Detect(obj, data_obj, lle_code, encoder, nump)
            % load labels
            fid = fopen(data_obj.agent.fextr.fname.invx, 'rb');
            clabList = fread(fid, [2, data_obj.agent.fextr.finfo.nfeat], '*uint32');
            fclose(fid);
            clabList = clabList(1, :);
            
            obj.list_file();
            for ii = 1:obj.num_bg
                % load image & extract feature
                [img_depth, img_color, img_alpha] = FolderProc.UWDataProc.load_image( ...
                    obj.inroot, obj.nlist.imgl(ii, :));
                [desc, fram] = FolderProc.UWDataProc.extr_mask(data_obj, ...
                    img_depth, img_color, img_alpha, 1);
                imsz = size(img_depth);
                imcard = imsz(1) * imsz(2);
                % encode feature
                bg_code = encoder.encode(desc);
                clear desc;
                numf = size(bg_code, 2);
                fprintf('\tfeature prepared\n');
                % nearest matching
                cimg = - ones(imsz);
                simg = zeros(imsz);
%                 nn_mat();
%                 fprintf('\tsingle point matching done\n');
                % patch classification
                vpat = vote_patch();
                fprintf('\tpatch matching done\n');
                % draw result
                draw_result();
                fprintf('\tsaved\n');
            end
            
            function nn_mat()
                % nearest matching
                kdt = vl_kdtreebuild(full(lle_code));
                [IP, ID] = vl_kdtreequery(kdt, full(lle_code), full(bg_code), 'MaxNumComparisons',50);
                %                 IP = zeros(1, numf);
                %                 parfor fi = 1:numf
                %                     D = vl_alldist2(bg_code(:, fi), lle_code);
                %                     [~, IP(fi)] = min(D);
                %                 end
                
                % erase noisy points
                idx = 1:numf;
                idx(1 < ID) = [];
                numf = numel(idx);
                bg_code = bg_code(:, idx);
                fram = fram(:, idx);
                IP = IP(idx);
                
                % build voting template
                cI = clabList(IP);
                disp(histc(cI, unique(cI)));
                for fi = 1:numf
                    cimg(fram(2, fi), fram(1, fi)) = cI(fi);
                end
                cimg = reshape(cimg, [1, imcard]);
            end
            
            function vpat = vote_patch()
                vpat.orig = generate_patches(obj, imsz, nump);
                vpat.vote = zeros(1, nump);
                vpat.weit = zeros(1, nump);
                for ti = 1:nump
                    % patch locations
                    patpX = vpat.orig(ti, 1) + obj.patpt.X;
                    patpY = vpat.orig(ti, 2) + obj.patpt.Y;
                    lidx = sub2ind(imsz, patpX, patpY);
                    vpat.lidx{ti} = lidx;
                    % class label for linearized indices
                    clidx = zeros(1, numel(lidx));
                    for si = 1:numel(lidx)
                        if 0 <= cimg(lidx(si))
                            % fetch look-up table
                            clidx(si) = cimg(lidx(si));
                        else
                            idx = 1:numf;
                            idx = idx(and(patpX(si) == fram(2, :), patpY(si) == fram(1, :)));
                            % non-feature location
                            if isempty(idx), cimg(lidx(si)) = 0; continue; end
                            [D, idx] = pdist2(lle_code', bg_code(:, idx)', 'euclidean', 'Smallest',1);
                            % exclude error matching
                            simg(lidx(si)) = exp(- 5 * D);
                            if 1 < D, cimg(lidx(si)) = 0; continue; end
                            % update look-up table
                            cimg(lidx(si)) = clabList(idx);
                            clidx(si) = cimg(lidx(si));
                        end
                    end
                    cpat = unique(clidx);
                    hcc = histc(clidx, cpat);
                    [cv, ci] = max(hcc);
                    vpat.weit(ti) = cv / obj.patpt.numpp2;
                    % exclude impure patch
                    if 0.8 > vpat.weit(ti), continue; end
                    vpat.vote(ti) = cpat(ci);
                end
            end
            
            function draw_result()
                num_m = data_obj.minfo.cnt;
                votim = zeros([imcard, num_m]);
                for ti = 1:nump
                    if 0 == vpat.vote(ti), continue; end
                    votim(vpat.lidx{ti}, vpat.vote(ti)) = vpat.weit(ti) * simg(vpat.lidx{ti});
                end
                votim = reshape(votim, [imsz, 1, num_m]);
                votim_draw = zeros([imsz, 3, num_m]);
                for mi = 1:num_m
                    votim(:, :, :, mi) = imfilter(100 * votim(:, :, :, mi), fspecial('gaussian', [40 40], 5));
                    votim_draw(:, :, :, mi) = sc(cat(3, votim(:, :, :, mi), img_color), 'prob');
                end
                hfig = figure;
                sc(votim_draw, [min(votim_draw(:)), max(votim_draw(:))]);
                saveas(hfig, sprintf('%s/%s', obj.out_hf, obj.nlist.iseq{ii}), 'fig');
                save(sprintf('%s/%s.mat', obj.out_hf, obj.nlist.iseq{ii}), '-mat', 'votim');
            end
        end
        
    end
    
    methods (Access=private)
        function list_file(obj)
            image_list = dir(obj.inroot);
            isDir = [image_list.isdir];
            image_list = {image_list(~isDir).name}';
            
            depth_image = image_list(~cellfun(@isempty, regexp(image_list, '.*_depth\.png', 'match')));
            color_image = image_list(~cellfun(@isempty, regexp(image_list, '.*_color\.png', 'match')));
%             alpha_image = image_list(~cellfun(@isempty, regexp(image_list, '.*_alpha\.png', 'match')));
            nums = numel(depth_image);
            if nums ~= numel(color_image)
                fprintf(2, 'depth/color image count unmatched!\n');
            end
            
            image_seq = regexp(color_image, '(.*)_color\.png', 'tokens');
            image_seq = cellfun(@(x) x{:}, image_seq);
            image_list = cat(2, depth_image, color_image);
%             image_list = cat(2, depth_image, color_image, alpha_image);
            % image_seq = image_seq(1:2:end, :); image_list = image_list(1:2:end, :);
            nums = numel(image_seq);
            
            obj.num_bg = nums;
            obj.nlist.imgl = image_list;
            obj.nlist.iseq = image_seq;
%             obj.nlist.imsz = zeros(nums, 2);
        end
        
        function pato = generate_patches(obj, imsz, nump)
            imsz = imsz - obj.patpt.szpat + 1;
            pato = horzcat(randsample(imsz(1), nump, true), ...
                randsample(imsz(2), nump, true));
        end
        
    end
    
    methods(Static)
    end
    
end

