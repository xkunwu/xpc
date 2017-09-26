function p3d = Depth2PC(img, v2d, topleft)

center = [320 240];
[imh, imw] = size(img);
constant = 570.3;
MM_PER_M = 1;
% MM_PER_M = 1000;
idx = sub2ind([imh, imw], v2d(1, :), v2d(2, :));

% convert depth image to 3d point clouds
xgrid = ones(imh,1)*(1:imw) + (topleft(1)-1) - center(1);
ygrid = (1:imh)'*ones(1,imw) + (topleft(2)-1) - center(2);
X = xgrid.*img/constant/MM_PER_M;
Y = ygrid.*img/constant/MM_PER_M;
Z = img/MM_PER_M;
p3d = [X(idx); Y(idx); Z(idx)];

end

