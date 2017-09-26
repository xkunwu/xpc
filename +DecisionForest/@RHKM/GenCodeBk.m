function codebk = GenCodeBk(obj)

codebk = [];
for ni = 1:obj.num_node
    tn = obj.node_tbl(ni);
    for bi = 1:numel(tn.cid)
        if 0 <= tn.cid(bi), continue; end
        codebk = [codebk, tn.ctr(:, bi)];
    end
end

end

