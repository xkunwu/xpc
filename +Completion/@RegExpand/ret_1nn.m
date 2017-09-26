function [obj_idx, qry_mat] = ret_1nn(obj, obj_idx, rexpar)

% expand until maximum components retrieved
qry_mat = [];
new_obj_idx = obj_idx;
step = 1;
step_vec = repmat(step, size(new_obj_idx));
fprintf(1, '\tquery: %d; rate: %.4f\n', obj_idx, rexpar.ratio);
while ~isempty(new_obj_idx)
    [new_obj_idx, new_qry_mat] = obj.set_exp(new_obj_idx, step, rexpar);
    qry_mat = [qry_mat, new_qry_mat]; % back-track short cutting is ensured automatically
    new_obj_idx = setdiff(new_obj_idx, obj_idx); % output here if incremental
    obj_idx = [obj_idx, new_obj_idx];
    step_vec = [step_vec, repmat(step, size(new_obj_idx))];
    fprintf('\t[%d] %d expanded:', step, numel(new_obj_idx));
    fprintf(' %d', new_obj_idx);
    fprintf('\n');
    step = step + 1;
%     break; % un-comment this line to check 1st neighbors
end
if isempty(qry_mat)
    fprintf(2, 'empty matching set!\n');
    return;
end
obj_idx = [obj_idx; step_vec];

% % make sure mutual match
% qry_mat_comp = intersect(qry_mat(1:2, :)', circshift(qry_mat(1:2, :), 1)', 'rows')';
% qry_mat_comp = [qry_mat_comp; zeros(2, size(qry_mat_comp, 2))];
% qry_mat = sortrows(qry_mat', [1 2])';
% qry_mat_comp = sortrows(qry_mat_comp', [1 2])'; % in case of bad beheivior
% j = 1;
% for i = 1:size(qry_mat_comp, 2) % have to manually pick
%     while 0 ~= sum(qry_mat_comp(1:2, i) - qry_mat(1:2, j))
%         j = j + 1;
%     end
%     if j > size(qry_mat, 2)
%         fprintf(2, 'qry_mat error!\n');
%         return;
%     end
%     qry_mat_comp(:, i) = qry_mat(:, j);
%     j = j + 1;
% end
% fprintf(1, '\tmutual match reduction: %d => %d\n', size(qry_mat, 2), size(qry_mat_comp, 2));
% qry_mat = qry_mat_comp;

end
