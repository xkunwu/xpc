classdef BBoxMatch < handle
    
    properties
        datao
        rdetect
        mdsn
        mpair
        bgpcname
    end
    
    methods
        function obj = BBoxMatch()
        end
        
        function PrepBG(obj, datao, fextor, rforest, rdetect, opts)
            tic; fprintf('\npreparing background ...\n');
            obj.datao = datao;
            obj.rdetect = rdetect;
            % match region
            [obj.mdsn.md, obj.mdsn.sn, obj.mpair.src, obj.mpair.tgt] = ...
                Completion.MatchRegion(fextor, rforest, rdetect, opts.dtect.disth, opts.rexp.drawc);
            % export ply for background
            obj.exp_bgply();
            fprintf('%s >> execution time: %.2f\n\n', datestr(now), toc);
        end
    end
    
    methods (Access=private)
        function exp_bgply(obj)
            bgdir = sprintf('%s/plybg/', obj.datao.rpath.out);
            if ~exist(bgdir, 'dir'), mkdir(bgdir); end
            obj.bgpcname = sprintf('%s/%s.ply', bgdir, obj.rdetect.get_comp_iseq());
            if exist(obj.bgpcname, 'file'), return; end
            [img_depth, img_color, img_alpha] = FolderProc.UWDataProc.load_image( ...
                obj.rdetect.inroot, obj.rdetect.get_comp_imgl());
            topleft = [1, 1];
            Completion.Im2PC(img_depth, img_color, img_alpha, topleft, obj.bgpcname)
        end
    end
end

