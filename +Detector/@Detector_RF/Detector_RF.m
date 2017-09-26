classdef Detector_RF < handle
    
    properties
        inroot % root input path
        out_hf % result output path
        names % input file category names
        num_bg % number of background to detect
        nlist % image files name list
        
        patpt % patch template grid points
        disth % distance threshold
    end
    
    methods
        function obj = Detector_RF(datao, opt)
            obj.inroot = datao.rpath.in;
            obj.out_hf = [datao.rpath.out, '/hf_result'];
            if ~ exist(obj.out_hf, 'dir'), mkdir(obj.out_hf); end

            obj.names.depth = '_depth';
            obj.names.color = '_color';
            obj.num_bg = 0;
            obj.nlist = [];
            obj.disth = Inf;
            
            obj.patpt.lstep = opt.step;
            obj.patpt.szpat = opt.step*opt.szpat;
            % template patch location
            vpp = 0:obj.patpt.lstep:(obj.patpt.szpat-1);
            numpp = numel(vpp);
            obj.patpt.numpp = numpp;
            obj.patpt.numpp2 = numpp*numpp;
            [obj.patpt.X, obj.patpt.Y] = meshgrid(vpp, vpp);
            obj.patpt.X = reshape(obj.patpt.X, [1, obj.patpt.numpp2]);
            obj.patpt.Y = reshape(obj.patpt.Y, [1, obj.patpt.numpp2]);
        end
        
        function imgl = get_comp_imgl(obj)
            imgl = obj.nlist.imgl(1, :); % only process the first background
        end
        function iseq = get_comp_iseq(obj)
            iseq = obj.nlist.iseq{1}; % only process the first background
        end
    end
    
    methods (Access=private)
        function list_file(obj)
            image_list = dir(obj.inroot);
            isDir = [image_list.isdir];
            image_list = {image_list(~isDir).name}';
            
            depth_image = image_list(~cellfun(@isempty, regexp(image_list, ['.*' obj.names.depth '\.png'], 'match')));
            color_image = image_list(~cellfun(@isempty, regexp(image_list, ['.*' obj.names.color '\.png'], 'match')));
            nums = numel(depth_image);
            if nums ~= numel(color_image)
                fprintf(2, 'depth/color image count unmatched!\n');
                return;
            end
            
            image_seq = regexp(color_image, ['(.*)' obj.names.color '\.png'], 'tokens');
            image_seq = cellfun(@(x) x{:}, image_seq);
            image_list = cat(2, depth_image, color_image);
            nums = numel(image_seq);
            
            obj.num_bg = nums;
            obj.nlist.imgl = image_list;
            obj.nlist.iseq = image_seq;
        end
    end
    
end
