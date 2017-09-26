classdef SIFTExtractor < handle & Feature.GenericExtractor
    
    properties
        binSize
        magnif
        step
        fast
    end
    
    methods
        function obj = SIFTExtractor(varargin)
            obj.desc_len = 128;
            obj.fram_len = 4;
            obj.binSize = 8;
            obj.magnif = 3;
            obj.step = 2;
            obj.fast = true;
            Utility.SetProperties(obj, varargin);
        end
        [descs, frames] = compute(obj, im, step)
    end
    
end
