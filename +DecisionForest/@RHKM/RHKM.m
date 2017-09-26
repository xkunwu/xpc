classdef RHKM < handle
    
    properties
        num_brch % branch number
        rnd_rate % random rate for picking subset
        min_leaf % termination: minimum leaf node
        max_hght % termination: maximum height
        
        num_elem % feature number after picking subset
        num_node % node number
        num_leaf % leaf number
        node_tbl % node list
        leaf_tbl % leaf list
    end
    
    methods
        function obj = RHKM(opt, varargin)
            obj.num_brch = opt.num_brch;
            obj.rnd_rate = opt.rnd_rate;
            obj.min_leaf = opt.min_leaf;
            obj.max_hght = opt.max_hght;
            Utility.SetProperties(obj, varargin);
        end
        
        function BuildTree(obj, fextr)
            fid = fopen(fextr.fname.desc, 'rb');
            fvecList = fread(fid, [fextr.finfo.flen, fextr.finfo.nfeat], 'uint8=>single');
            fclose(fid);
            
            obj.HKMeans(fvecList);
        end
        
    end
    
    methods(Static)
    end
    
end
