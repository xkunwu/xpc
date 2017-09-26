classdef RegExpand < handle
    
    properties
        datao
        fextor
        rforest
    end
    
    methods
        function obj = RegExpand(datao, fextor, rforest)
            obj.datao = datao;
            obj.fextor = fextor;
            obj.rforest = rforest;
        end
    end
    
    methods (Access=private)
        function [Tc, Mid] = s2cm(obj, Msq)
            for i = numel(Msq):-1:1
                Tc(i) = sum(0 < Msq(i) - obj.datao.minfo.cums);
                Mid(i) = Msq(i) - obj.datao.minfo.cums(Tc(i));
            end
        end
        
        function Msq = cm2s(obj, Tc, Mid)
            for i = numel(Tc):-1:1
                Msq(i) = obj.datao.minfo.cums(Tc(i)) + Mid(i);
            end
        end
        
        function desc = load_feature(obj, Tc, Mid)
            f_len = obj.fextor.finfo.flen;
            fid = fopen(obj.fextor.fname.desc, 'rb');
            fseek(fid, f_len * obj.fextor.flist(Tc).cumf(Mid), 'bof'); % read in the feature
            desc = fread(fid, [f_len, ...
                obj.fextor.flist(Tc).numf(Mid)], 'uint8=>single');
            fclose(fid);
        end
    end
    
end

