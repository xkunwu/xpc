function opts = argparse(opts, varargin)
if isempty(varargin)
    inopts = struct([]);
else
    inopts = struct(varargin{:});
end

fn = fieldnames(inopts);
for i = 1:length(fn)
    if isfield(opts, fn{i})
        opts = setfield(opts, fn{i}, getfield(inopts, fn{i}));
    else
        error(sprintf('Bad argument: ''%s''', fn{i}));
    end
end
return
