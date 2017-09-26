classdef GenericExtractor < handle
    
    properties
        target % 'color' or 'depth'
        desc_len
        fram_len
    end
    
    methods
        function obj = GenericExtractor()
            obj.target = 'color';
            obj.desc_len = 0;
            obj.fram_len = 0;
        end
        
    end
    
    methods(Abstract)
        [desc, frames] = compute(obj, im, step)
    end
    
end
