function [reg_img, src_img, tgt_img] = Regression(obj, num_m, imsz, voteList, framList, fextr)

reg_img = zeros([imsz, 1, num_m]);
[f_len, num_vote] = size(voteList);
fil_img = false(1, num_vote);
tgt_img = - ones(2, num_vote, num_m);

% load files
fid = fopen(fextr.fname.desc, 'rb');
fvecList = fread(fid, [fextr.finfo.flen, fextr.finfo.nfeat], 'uint8=>single');
fclose(fid);

% fid = fopen(fextr.fname.invx, 'rb');
% clabList = fread(fid, [2, fextr.finfo.nfeat], '*uint32');
% fclose(fid);
% clabList = clabList(1, :);

fid = fopen(fextr.fname.vcen, 'rb');
vcenList = fread(fid, [2, fextr.finfo.nfeat], '*single');
fclose(fid);

% predict each vote
for vi = 1:num_vote
    leaf_indx = reg_one(vi);
    fill_one(obj.leaf_tbl(leaf_indx), vi);
%     fill_best(obj.leaf_tbl(leaf_indx), vi);
end

src_img = repmat(framList(2:-1:1, fil_img), [1, 1, num_m]);
tgt_img = tgt_img(:, fil_img, :);

    function leaf_indx = reg_one(vi)
        leaf_indx = 1;
        while 0 < leaf_indx
            cn = obj.node_tbl(leaf_indx);
            if cn.the < voteList(cn.fvno, vi)
                leaf_indx = cn.cid(1);
            else
                leaf_indx = cn.cid(2);
            end
        end
        leaf_indx = - leaf_indx;
    end

    function fill_best(leaf, vi)
        if 1 > leaf.label, return; end
        
        % compute best match
        vo = voteList(:, vi);
        [vl, id] = min(sum((fvecList(:, leaf.rang) - repmat(vo, [1, numel(leaf.rang)])) .^ 2, 1));
        % if eps < abs(vl), disp(vl); end
        
        % compute voting center
        cen = vcenList(:, leaf.rang);
        x = round(framList(2, vi) + cen(2, id));
        if 1 > x || imsz(1) < x, return; end;
        y = round(framList(1, vi) + cen(1, id));
        if 1 > y || imsz(2) < y, return; end;
        fil_img(vi) = true;
        tgt_img(1, vi, leaf.label) = x; tgt_img(2, vi, leaf.label) = y;
        
        % accumulate result
        timg = zeros(imsz);
        timg(x, y) = 10 * exp(- sqrt(vl) / f_len);
        timg = imfilter(timg, fspecial('gaussian', [9 9], 1));
        reg_img(:, :, 1, leaf.label) = reg_img(:, :, 1, leaf.label) ...
            + timg;
    end

    function fill_one(leaf, vi)
        if 1 > leaf.label, return; end
        
        % compute voting center
        x = round(framList(2, vi) + leaf.cen(2));
        if 1 > x || imsz(1) < x, return; end;
        y = round(framList(1, vi) + leaf.cen(1));
        if 1 > y || imsz(2) < y, return; end;
        fil_img(vi) = true;
        tgt_img(1, vi, leaf.label) = x; tgt_img(2, vi, leaf.label) = y;
        
        % accumulate result
        timg = zeros(imsz);
        timg(x, y) = exp(- sqrt(sum(var(vcenList(:, leaf.rang), 0, 2))) / 10);
        timg = imfilter(timg, fspecial('gaussian', [5 5], 0.5));
        reg_img(:, :, 1, leaf.label) = reg_img(:, :, 1, leaf.label) ...
            + timg;
    end

end

