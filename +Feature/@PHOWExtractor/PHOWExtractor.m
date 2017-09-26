classdef PHOWExtractor < handle & Feature.GenericExtractor
    
    properties
        verbose
        sizes
        fast
        step
        color
        contrast_threshold
        window_size
        magnif
        float_descriptors
    end
    
    methods
        function obj = PHOWExtractor(varargin)
            obj.desc_len = 128; % gray: 128; opponent: 384=128*3
            obj.fram_len = 4;
            obj.verbose = false;
            obj.sizes = 8; % [4 6 8 10];
            obj.fast = true;
            obj.step = 2;
            obj.color = 'gray';
            obj.contrast_threshold = 0.005;
            obj.window_size = 1.5;
            obj.magnif = 6;
            obj.float_descriptors = false;
            Utility.SetProperties(obj, varargin);
        end
        [descs, frames] = compute(obj, im, step)
    end
    
end
