classdef Proxy < handle
    
    properties
        datao % data object
        nummp % num_of workers
        finfo % feature info
        flist % feature list for each model
        fname % file names
        fextr % feature extractors
        fstep % sample grid step
    end
    
    methods
        function obj = Proxy(datao, opt)
            obj.datao = datao;
            obj.nummp = 1;
            if 0 < matlabpool('size'), obj.nummp = matlabpool('size'); end
            
            % feature summary
            obj.finfo = struct( ...
                'flen',0, ...
                'nfeat',0, ...
                'sumfm',zeros(datao.minfo.cnt, 1) ...
                );
            
            % feature list
            for mi = datao.minfo.cnt:-1:1
                obj.flist(mi).numf = zeros(datao.minfo.nums(mi), 1);
                obj.flist(mi).cumf = zeros(datao.minfo.nums(mi), 1);
                obj.flist(mi).sumf = 0;
            end
            
            % worker extractors
            obj.fextr = containers.Map;
            obj.fstep = opt.step;
            
            % output names
            obj.fname.fram = sprintf('%s/fram.bin', datao.rpath.out);
            obj.fname.desc = sprintf('%s/desc.bin', datao.rpath.out);
            obj.fname.invx = sprintf('%s/invx.bin', datao.rpath.out);
            obj.fname.vcen = sprintf('%s/vcen.bin', datao.rpath.out);
            
            % do extract
            obj.do_extract();
        end
        
    end
    
end

