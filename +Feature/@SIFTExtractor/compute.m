function [desc, frames] = compute(obj, im, step)

if nargin < 3, step = obj.step; end

ims = vl_imsmooth(im, sqrt((obj.binSize/obj.magnif)^2 - .25));
if true == obj.fast
    [frames, desc] = vl_dsift(ims, 'size',obj.binSize, ...
        'step',step, 'fast');
else
    [frames, desc] = vl_dsift(ims, 'size',obj.binSize, ...
        'step',step);
end

frames(3,:) = obj.binSize/obj.magnif;
frames(4,:) = 0;

end
