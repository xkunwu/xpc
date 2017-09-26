% nt = 2; ml = 4; md = 4; nr = 10; ns = 100; lf = 32;
% % nt = 4; ml = 16; md = 20; nr = 100; ns = 10000; lf = 128;
% hforest = HoughForest.HForest(nt, ml, md, nr);
% tic; fprintf('\ntraining ...\n');
% hforest.Train(randi(100, [lf, ns]), randi(10, [1, ns]), randn([2, ns]));
% fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

classdef HForest < handle
   
    properties
        num_tree
        min_leaf
        max_hght
        num_try
        
        vhtree
        
    end
    
    methods
        function obj = HForest(htree_p)
            obj.num_tree = htree_p.num_tree;
            obj.min_leaf = htree_p.min_leaf;
            obj.max_hght = htree_p.max_hght;
            obj.num_try = htree_p.num_try;

        end
        
        function Train(obj, fextr, step)
            % read files
            fid = fopen(fextr.fname.desc, 'rb');
            fvecList = fread(fid, [fextr.finfo.flen, fextr.finfo.nfeat], 'uint8=>single');
            fclose(fid);
            
            fid = fopen(fextr.fname.invx, 'rb');
            clabList = fread(fid, [2, fextr.finfo.nfeat], '*uint32');
            fclose(fid);
            clabList = clabList(1, :);
            
            fid = fopen(fextr.fname.vcen, 'rb');
            vcenList = fread(fid, [2, fextr.finfo.nfeat], '*single');
            fclose(fid);
            
            % train each tree
            for nt = 1:obj.num_tree
                fprintf('%d', nt);
                vht(nt) = HoughForest.HTree(obj.min_leaf, obj.max_hght, obj.num_try);
                vht(nt).Train(fvecList, clabList, vcenList, step);
            end
            obj.vhtree = vht;
        end
        
        function Draw(obj, fextr, outroot, bdraw)
            for nt = 1:obj.num_tree
                % draw tree
                hfig = obj.vhtree(nt).DrawTree();
                saveas(hfig, sprintf('%s/tree_%d', outroot, nt), 'fig');
                if ~bdraw, close(hfig); end
                
                % draw leaf
                fid = fopen(fextr.fname.vcen, 'rb');
                vcenList = fread(fid, [2, fextr.finfo.nfeat], '*single');
                fclose(fid);
                fid = fopen(fextr.fname.invx, 'rb');
                clabList = fread(fid, [2, fextr.finfo.nfeat], '*uint32');
                fclose(fid);
                clabList = clabList(1, :);
                hfig = obj.vhtree(nt).DrawLeaf(clabList, vcenList);
                saveas(hfig, sprintf('%s/leaf_%d', outroot, nt), 'fig');
                if ~bdraw, close(hfig); end
            end
        end
        
        function [reg_img, v_pair] = Regression(obj, num_m, imsz, fvecList, framList, fextr)
            reg_img = zeros([imsz, 1, num_m]);
            for nt = 1:obj.num_tree
                [v_pair{nt}.bg, v_pair{nt}.src, v_pair{nt}.tgt] = obj.vhtree(nt).Regression(num_m, imsz, fvecList, framList, fextr);
                reg_img = reg_img + v_pair{nt}.bg;
            end
        end
        
    end
        
end

