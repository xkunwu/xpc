classdef RHKM_F < handle

    properties
        num_elem % total feature number
        num_tree % tree number
        vtree % tree list
    end
    
    methods
        function obj = RHKM_F(opt, varargin)
            obj.num_tree = opt.num_tree;
            for ti = 1:obj.num_tree
                vta(ti) = DecisionForest.RHKM(opt);
            end
            obj.vtree = vta;
            obj.num_elem = 0;
            Utility.SetProperties(obj, varargin);
        end
        
        function BuildTree(obj, fextr)
            obj.num_elem = fextr.finfo.nfeat;
            fid = fopen(fextr.fname.desc, 'rb');
            fvecList = fread(fid, [fextr.finfo.flen, fextr.finfo.nfeat], 'uint8=>single');
            fclose(fid);
            
            for ti = 1:obj.num_tree
                fprintf('%d', ti);
                obj.vtree(ti).HKMeans(fvecList);
            end
        end
        
        function DrawTree(obj, outroot)
            for ti = 1:obj.num_tree
                hfig = obj.vtree(ti).DrawTree();
                saveas(hfig, sprintf('%s/tree_rand_%d', outroot, ti), 'fig');
            end
        end
        
        function [nidx, ndst] = MatchLeaf(obj, tagtList, fextr, ret_k)
            if 4 > nargin, ret_k = 1; end
            fid = fopen(fextr.fname.desc, 'rb');
            fvecList = fread(fid, [fextr.finfo.flen, fextr.finfo.nfeat], 'uint8=>single');
            fclose(fid);
            
            % for each tree: match & record
            numt = obj.num_tree;
            numf = size(tagtList, 2);
            nidx = cell(1, numf);
            ndst = cell(1, numf);
            for ti = 1:numt
                [ni, nd] = obj.vtree(ti).MatchLeaf(tagtList, fvecList, ret_k);
                [nidx, ndst] = cellfun(@cf_union, nidx, ndst, ni, nd, 'UniformOutput',false);
            end
            clear fvecList;
            
            % take the best among trees
            [nidx, ndst] = cellfun(@(x, y)cf_sort(x, y, ret_k), nidx, ndst, 'UniformOutput',false);
            nidx = [nidx{:}]; ndst = [ndst{:}];
        end
    end
    
end

function [nidx, ndst] = cf_union(nidx, ndst, ni, nd)
nidx = [nidx, ni];
[nidx, A, ~] = unique(nidx);
ndst = [ndst, nd];
ndst = ndst(A);
end

function [nidx, ndst] = cf_sort(nidx, ndst, ret_k)
[ndst, ix] = sort(ndst, 'ascend');
ret_k = min(numel(ix), ret_k);
ndst = ndst(1:ret_k);

nidx = nidx(ix);
nidx = nidx(1:ret_k);
end

