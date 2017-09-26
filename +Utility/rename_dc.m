function rename_dc()

data_path = 'e:\Workstation\DataCenter\mpi_data\kinect_obj\data\';

data_path(data_path == '\') = '/';

dirdata = dir(data_path);
mln = {dirdata([dirdata.isdir]).name}';
mln =  mln(~ismember(mln, {'.','..'}));

for mi = 1:numel(mln)
    obj_path = sprintf('%s/%s/', data_path, mln{mi});
    rename_obj(obj_path, mln{mi});
end

    function rename_obj(obj_path, name_m)
        name1 = dir(obj_path);
        isDir = [name1.isdir];
        name1 = {name1(~isDir).name}';
        
        name2 = regexprep(name1, ...
            ['([a-zA-Z]+)(\d+)', '\.png'], ...
            [name_m '_1_$2_$1.png']);
        
        for ni = 1:numel(name2)
            movefile(sprintf('%s/%s/', obj_path, name1{ni}), ...
                sprintf(sprintf('%s/%s/', obj_path, name2{ni})));
        end
    end

end
