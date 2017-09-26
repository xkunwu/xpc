classdef LLCEncoder < handle
    %LLCENCODER Bag-of-word histogram computation using the LLC method
    
    properties
        norm_type    % 'l1' or 'l2'
        max_comps    % -1 for exact
        num_nn       % number of nearest neighbour bases to assign to
        beta         % LLC regularization parameter
    end
    
    properties(SetAccess=protected)
        kdtree_
        codebook_
    end
    
    methods
        function obj = LLCEncoder()
            % set default parameter values
            obj.norm_type = 'l2';
            obj.max_comps = -1;
            obj.num_nn = 5;
            obj.beta = 1e-4;
            obj.codebook_ = [];
        end
        
        function dim = get_input_dim(obj)
            dim = size(obj.codebook_, 1);
        end
        function dim = get_output_dim(obj)
            dim = size(obj.codebook_, 2);
        end
        
        function set_codebook(obj, codebook)
            obj.codebook_ = codebook;
            if 0 <= obj.max_comps
                obj.kdtree_ = vl_kdtreebuild(codebook);
            end
        end
        
        code = encode(obj, feats)
    end
    
end

