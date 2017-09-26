classdef GenericProc < handle
    
    properties
        rpath
    end
    
    methods
        function obj = GenericProc(paths)
            obj.rpath.data = paths.data;
            obj.rpath.in = paths.in;
            obj.rpath.out = paths.out;
        end
        
    end
    
    methods(Abstract)
%         ProcFolder(obj, model_seq)
    end
    
end
