classdef MPIDataProc < handle & FolderProc.GenericProc
    
    properties
        names % name tags for different image category
        minfo % model information summary
        mlist % detailed information
    end
    
    methods
        function obj = MPIDataProc(opts, varargin)
            obj = obj@FolderProc.GenericProc(opts.paths);
            obj.rpath.ply = sprintf('%s/ply/', opts.paths.out);
            
            % data file specific
            obj.names = struct( ...
                'depth','_depth', ...
                'color','_color' ...
                );
            
            % data directory infomation
            obj.parse_folder(opts.datao.step);
            
            Utility.SetProperties(obj, varargin);
        end
        
        function Im2PC(obj)
            tic; fprintf('%s >> exporting 3d point cloud ...\n', datestr(now));
            for seq = 1:obj.minfo.cnt
                fprintf('in folder: %s\n', obj.mlist(seq).name);
                obj.kinect_3d_from_depth(seq);
            end
            fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
        end
        
    end
    
    methods(Access=private)
        function parse_folder(obj, step)
            if 2 > nargin, step = 1; end
            % get model names
            dirdata = dir(obj.rpath.data);
            mln = {dirdata([dirdata.isdir]).name}';
            mln =  mln(~ismember(mln, {'.','..'}));
            cnt = numel(mln);
            
            % fill in model infor
            obj.minfo = struct( ...
                'cnt',cnt, ...
                'step',step, ...
                'nums',zeros(cnt, 1), ...
                'cums',zeros(cnt, 1), ...
                'sums',0 ...
                );
            for mi = cnt:-1:1
                obj.mlist(mi).name = mln{mi};
                obj.mlist(mi).seq = mi;
                obj.mlist(mi).dir = sprintf('%s/%s/', obj.rpath.data, mln{mi});
                folder_proc(obj, mi);
            end
            
            obj.minfo.sums = sum(obj.minfo.nums);
            obj.minfo.cums = cumsum(obj.minfo.nums) - obj.minfo.nums;
        end
        
        function folder_proc(obj, seq)
            model_name = obj.mlist(seq).name;
            
            % list files
            image_list = dir(obj.mlist(seq).dir);
            isDir = [image_list.isdir];
            image_list = {image_list(~isDir).name}';
            
            % seperate categories
            depth_image = image_list(~cellfun(@isempty, regexp(image_list, [model_name, '_\d+_\d+', obj.names.depth, '\.png'], 'match')));
            color_image = image_list(~cellfun(@isempty, regexp(image_list, [model_name, '_\d+_\d+', obj.names.color, '\.png'], 'match')));
            nums = numel(depth_image);
            if nums ~= numel(color_image)
                fprintf(2, 'depth/color image count unmatched!\n');
            end
            image_list = cat(2, depth_image, color_image);
            
            % sequential identifier
            image_seq = regexp(depth_image, [model_name, '_(\d+_\d+).*', '\.png'], 'tokens');
            image_seq = cellfun(@(x) x{:}, image_seq);
            image_seq2 = regexp(image_seq, '_', 'split');
            image_seq2 = cell2mat(cellfun(@(x)[str2double(x{1}), str2double(x{2})], image_seq2, 'UniformOutput',false));
            
            % pick a subset
            image_seq = image_seq(1:obj.minfo.step:end, :);
            image_seq2 = image_seq2(1:obj.minfo.step:end, :);
            image_list = image_list(1:obj.minfo.step:end, :);
            nums = numel(image_seq);
            
            % write to object
            obj.minfo.nums(seq) = nums;
            obj.mlist(seq).imgl = image_list;
            obj.mlist(seq).iseq = image_seq;
            obj.mlist(seq).im2x = image_seq2;
            obj.mlist(seq).imsz = zeros(nums, 2);
            for si = 1:nums
                imif = imfinfo(sprintf('%s/%s', obj.mlist(seq).dir, image_list{seq, 1}));
                obj.mlist(seq).imsz(si, :) = [imif.Height, imif.Width];
            end
        end
    end
    
    methods(Static)
        function [im_d, im_c, im_a] = LoadImage(dir_pref, image_pair)
            
            [im_c, ~, im_a] = imread(sprintf('%s/%s', dir_pref, image_pair{2}), 'png');
            im_a = 0 < im_a;
            im_d = imread(sprintf('%s/%s', dir_pref, image_pair{1}), 'png');
            if 2 < ndims(im_d), im_d = rgb2gray(im_d); end
            im_a(0 == im_d) = 0;
            im_d = single(im_d) / 1000;
            
        end
    end
    
end
