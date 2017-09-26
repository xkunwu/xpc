% ml = 4; md = 4; nt = 10; ns = 100; lf = 32;
% % ml = 16; md = 20; nt = 100; ns = 10000; lf = 128;
% htree = HoughForest.HTree(ml, md, nt);
% tic; fprintf('\ntraining ...\n');
% htree.Train(randi(100, [lf, ns]), randi(10, [1, ns]), randn([2, ns]));
% fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);

classdef HTree < handle
    properties
        min_leaf
        max_hght
        num_try
        
        num_node
        num_leaf
        node_tbl
        leaf_tbl
        
        num_elem
        num_lab
        lab_map
        
    end
    
    methods
        function obj = HTree(min_leaf, max_hght, num_try)
            obj.min_leaf = min_leaf;
            obj.max_hght = max_hght;
            obj.num_try = num_try;
            
            obj.num_node = 2 ^ max_hght - 1;
            obj.num_leaf = 2 ^ (max_hght + 1);
            obj.num_elem = 0;
            
            obj.node_tbl(obj.num_node).pid = int32(0);
            obj.node_tbl(obj.num_node).cid = int32([0, 0]);
            obj.node_tbl(obj.num_node).lvl = uint8(0);
            obj.node_tbl(obj.num_node).rang = int32(0);
            obj.node_tbl(obj.num_node).fvno = single(0);
            obj.node_tbl(obj.num_node).the = single(0);
            
            obj.leaf_tbl(obj.num_leaf).pid = int32(0);
            obj.leaf_tbl(obj.num_leaf).label = int32(0);
            obj.leaf_tbl(obj.num_leaf).cen = single([0, 0]);
            obj.leaf_tbl(obj.num_leaf).rang = int32(0);

        end
                
    end
    
end

