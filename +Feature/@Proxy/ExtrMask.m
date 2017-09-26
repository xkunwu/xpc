function [desc, fram, im_a] = ExtrMask(obj, im_d, im_c, im_a, step, fmkth)
if 6 > nargin, fmkth = 22; end
im_c = im2single(im_c);
% features
desc = [];
if nargin < 5
    [d] = obj.fextr('depth').compute(im_d);
else
    [d] = obj.fextr('depth').compute(im_d, step);
end
desc = vertcat(desc, d);
if nargin < 5
    [d, fram] = obj.fextr('color').compute(im_c);
else
    [d, fram] = obj.fextr('color').compute(im_c, step);
end
desc = vertcat(desc, d);
fram = fram(1:2, :);

% masking
v2d = round(fram(1:2, :));
fmk = (1 == im_a(sub2ind(size(im_a), v2d(2, :), v2d(1, :))));
fmk(fmkth > sum(abs(desc)) / obj.finfo.flen) = false; % remove insignificant feature
fram = fram(:, fmk); desc = desc(:, fmk);

im_a = false(size(im_a));
v2d = round(fram(1:2, :));
im_a(sub2ind(size(im_a), v2d(2, :), v2d(1, :))) = true;
end
