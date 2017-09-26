function code = encode(obj)

for ai = 1:numel(obj.agent)
    obj.agent(ai).encoder.set_codebook(obj.agent(ai).rtbdr.cdbk);
end

for ai = 1:numel(obj.agent)
    fid = fopen(obj.agent(ai).files.desc, 'rb');
    sift_desc = fread(fid, [obj.agent(ai).fextr.extr.desc_len, obj.agent(ai).fextr.nfeat], 'uint8=>single');
    fclose(fid);
    
    code = obj.agent(ai).encoder.encode(sift_desc);
    
    save(obj.agent(ai).files.code, '-mat', '-v7.3', 'code');
end

end
