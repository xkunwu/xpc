classdef RotReg
    
    properties
        seqsn % sn of capturing sequence
        outreg % output root of registration files
    end
    
    methods
        function obj = RotReg(datao, fextor, opt)
            obj.seqsn = opt.seqsn;
            obj.outreg = sprintf('%s/reg/', datao.rpath.out);
            if ~ exist(obj.outreg, 'dir'), mkdir(obj.outreg); end
            
            % do expansion
            for mi = 1:datao.minfo.cnt
                fprintf('in folder: %s\n', datao.mlist(mi).name);
                obj.SeqExpand(datao, fextor, mi, opt.bin_w);
            end
            % write content file
            fid = fopen(sprintf('%s/model_names', obj.outreg), 'w');
            for mi = 1:datao.minfo.cnt
                fprintf(fid, '%s\n', datao.mlist(mi).name);
            end
            fclose(fid);
        end
    end
    
end

