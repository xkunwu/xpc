% path
addpath('./toolbox_nyu_depth_v2');

% compile some mex files
if ~exist('+Encoding/LLCEncodeHelper', 'file'),
    Encoding.mex_setup;
end

if ~exist('toolbox_nyu_depth_v2/mex_cbf', 'file'),
    cd toolbox_nyu_depth_v2;
    compile;
    cd ../
end

