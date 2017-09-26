function [BBox, T] = CalcBB(obj, datao)
% get max/min model size
mmsize = get_model_size();
mmsize2 = round(mmsize/2);

% load voting image
load(sprintf('%s/%s.mat', obj.out_hf, obj.get_comp_iseq()), '-mat', 'votim', 'votim_draw');
imsz = size(votim);
imsz = imsz(1:2);

% calculate the bounding box
[~, I] = max(votim(:)); % only take the maximum among classes
[R, C, ~, T] = ind2sub(size(votim), I);
R1 = max(R - mmsize2(1), 0); R2 = min(R + mmsize2(1), imsz(1));
C1 = max(C - mmsize2(2), 0); C2 = min(C + mmsize2(2), imsz(2));
BBox = [C1, R1, C2-C1, R2-R1];
    
% drawing
hfig = figure('Visible','off');
sc(votim_draw(:, :, :, T));
rectangle('Position',BBox, 'LineWidth',2, 'EdgeColor','b');
saveas(hfig, sprintf('%s/%s_bb', obj.out_hf, obj.get_comp_iseq()), 'png');
close(hfig);

    function mmsize = get_model_size()
        mmsize = zeros(datao.minfo.cnt, 2);
        for mi = 1:datao.minfo.cnt
            mmsize(mi, :) = max(datao.mlist(mi).imsz);
            msz = min(datao.mlist(mi).imsz);
            msz = mmsize(mi, :) - msz;
            tsz = round(0.1 * mmsize(mi, :));
            mmsize(mi, :) = mmsize(mi, :) + max([msz; tsz]);
        end
    end
end

