classdef Detector_HF < handle
    
    properties
        inroot
        out_hf
        names
        num_bg
        nlist
    end
    
    methods
        function obj = Detector_HF(data_obj)
            obj.inroot = data_obj.in_root;
            obj.out_hf = [data_obj.out_root, '/hf_result'];
            if ~ exist(obj.out_hf, 'dir'), mkdir(obj.out_hf); end

            obj.names.depth = 'depth';
            obj.names.color = 'color';
            
        end
        
        function Detect(obj, data_obj, hforest, step, draw)
            obj.list_file();
            for ii = 1:obj.num_bg
                [img_depth, img_color, img_alpha] = FolderProc.UWDataProc.load_image(obj.inroot, ...
                    obj.nlist.imgl(ii, :));
%                 img_gray = rgb2gray(img_color);
%                 [desc, fram] = FolderProc.UWDataProc.extr_mask(data_obj, single(imnoise(img_depth, 'poisson')), imnoise(img_color, 'poisson'), img_alpha);
                [desc, fram] = FolderProc.UWDataProc.extr_mask(data_obj, img_depth, img_color, img_alpha, step);
                num_m = data_obj.minfo.cnt;
                imsz = size(img_depth);
                [reg_img, v_pair] = hforest.Regression(num_m, imsz, desc, fram, data_obj.agent.fextr);
                if true == draw, draw_vote(); end
                reg_img(reg_img < 0.2 * max(reg_img(:))) = 0;
                reg_img_draw = zeros([imsz, 3, num_m]);
                for mi = 1:num_m
                    reg_img(:, :, :, mi) = imfilter(100 * reg_img(:, :, :, mi), fspecial('gaussian', [40 40], 5));
                    reg_img_draw(:, :, :, mi) = sc(cat(3, reg_img(:, :, :, mi), img_color), 'prob');
                end
                hfig = figure;
%                 sc(reg_img_draw); colorbar;
                sc(reg_img_draw, [min(reg_img_draw(:)), max(reg_img_draw(:))])
                saveas(hfig, sprintf('%s/%s', obj.out_hf, obj.nlist.iseq{ii}), 'fig');
                save(sprintf('%s/%s.mat', obj.out_hf, obj.nlist.iseq{ii}), '-mat', 'reg_img');
%                 load(sprintf('%s/%s.mat', obj.out_hf, obj.nlist.iseq{ii}));
            end
            
            function draw_vote()
                num_v = numel(v_pair);
                for vi = 1:num_v
                    if 2 < ndims(v_pair{vi}.bg)
                        num_c = size(v_pair{vi}.bg, 4);
                        for ci = 1:num_c
                            Utility.draw_matches(rgb2gray(img_color), v_pair{vi}.bg(:, :, :, ci), v_pair{vi}.src(:, :, ci), v_pair{vi}.tgt(:, :, ci));
                        end
                    else
                        Utility.draw_matches(rgb2gray(img_color), v_pair{vi}.bg, v_pair{vi}.src, v_pair{vi}.tgt);
                    end
                end
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
        
    end
    
end

