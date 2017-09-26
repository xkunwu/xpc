function rem_args = SetProperties(obj, varargin)

if ~isobject(obj), error('OBJ must be an object'); end

remainingArgs = {} ;

args = varargin{:};

if mod(length(args), 2) == 1
    error('Parameter-value pair expected (missing value?).') ;
end

for ai = 1:2:length(args)
    paramName = args{ai} ;
    value = args{ai+1} ;
    if isprop(obj, paramName)
        set(obj, paramName, value);
    else
        if nargout < 1
            error('Unknown parameter ''%s''.', paramName);
        else
            remainingArgs(end+1:end+2) = args(ai:ai+1);
        end
    end
end

rem_args = remainingArgs;
