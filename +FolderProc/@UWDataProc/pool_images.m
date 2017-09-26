function pool_images(obj)

numagt = numel(obj.agent);

efid = cell(numagt, 1);
dlen = zeros(numagt, 1);
flen = zeros(numagt, 1);
obj.ttset.pcode = cell(obj.minfo.cnt, 1);

pdim = zeros(numagt, 1);
for ai = 1:numagt
    efid{ai}.fram = fopen(obj.agent(ai).files.fram, 'rb');
    efid{ai}.desc = fopen(obj.agent(ai).files.desc, 'rb');
    flen(ai) = obj.agent(ai).fextr.extr.fram_len;
    dlen(ai) = obj.agent(ai).fextr.extr.desc_len;
    obj.agent(ai).pooler.set_encoder(obj.agent(ai).encoder);
    pdim(ai) = obj.agent(ai).pooler.get_output_dim();
end
obj.ttset.pdim = sum(pdim);
for mi = 1:obj.minfo.cnt
    obj.ttset.pcode{mi} = zeros(sum(pdim), obj.minfo.nums(mi));
end

pdim = [0; cumsum(pdim)];
for ai = 1:numagt
    for mi = 1:obj.minfo.cnt
        for si = 1:obj.minfo.nums(mi)
            frams = fread(efid{ai}.fram, [flen(ai), obj.agent(ai).fextr.list(mi).numf(si)], '*single');
            descs = fread(efid{ai}.desc, [dlen(ai), obj.agent(ai).fextr.list(mi).numf(si)], '*uint8');
            obj.ttset.pcode{mi}(pdim(ai)+1:pdim(ai+1), si) = obj.agent(ai).pooler.compute(obj.minfo.list(mi).imsz(si, :), descs, frams);
        end
    end
end

for ai = 1:numagt
    fclose(efid{ai}.fram);
    fclose(efid{ai}.desc);
end

end

