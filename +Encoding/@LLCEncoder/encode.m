function code = encode(obj, feats)
%ENCODE Encode features using the LLC method

% setup encoder
if isempty(obj.codebook_)
    error('setup code book first!');
end

% Apply encoding ------------------------------------------------------

outputFullMat = true;
if obj.max_comps ~= -1
    % using ann...
    code = LLCEncode(feats, obj.codebook_, ...
        obj.num_nn, obj.beta, obj.kdtree_, obj.max_comps, outputFullMat);
else
    % using exact assignment...
    code = LLCEncode(feats, obj.codebook_, ...
        obj.num_nn, obj.beta, [], [], outputFullMat);
end

% code = LLC_coding_appr(obj.codebook_, feats);

% Normalize -----------------------------------------------------------

[i,j,s] = find(code);
[m,n] = size(code);
code = sparse(i,j,s,m,n);

if strcmp(obj.norm_type, 'l1')
    code = code / norm(code,1);
end
if strcmp(obj.norm_type, 'l2')
    code = code / norm(code,2);
end

end

function encoding = LLCEncode(imwords, dictwords, K, beta, kdtree, ...
    maxComparisons, outputFullMat)

% START validate input parameters -------------------------------------
if ~exist('K', 'var') || isempty(K), K = 5; end
if ~exist('beta', 'var') || isempty(beta), beta = 1e-4; end
% only used if a kdtree is specified
if ~exist('maxComparisons', 'var') || isempty(maxComparisons), maxComparisons = size(dictwords,2); end
if ~exist('outputFullMat', 'var') || isempty(outputFullMat), outputFullMat = true; end
% END validate input parameters ---------------------------------------

% -- find K nearest neighbours in dictwords of imwords --
if (nargin < 5) || isempty(kdtree)
    distances = vl_alldist2(double(dictwords),double(imwords));
    % distances is MxN matrix where M is num of codewords
    % and N is number of descriptors in imwords
    [~, ix] = sort(distances);
    % ix is a KxN matrix containing
    % the indices of the K nearest neighbours of each image descriptor
    ix(K+1:end,:) = [];
else
    ix = vl_kdtreequery(kdtree, single(dictwords), ...
        single(imwords), ...
        'MaxComparisons', ...
        maxComparisons, ...
        'NumNeighbors', K);
end

encoding = ...
    Encoding.LLCEncodeHelper(double(dictwords), double(imwords), ...
    double(ix), double(beta), outputFullMat);

end

% ========================================================================
% USAGE: [Coeff]=LLC_coding_appr(B,X,knn,lambda)
% Approximated Locality-constraint Linear Coding
%
% Inputs
%       B       -d x M codebook, M entries in a d-dim space
%       X       -d x N matrix, N data points in a d-dim space
%       knn     -number of nearest neighboring
%       lambda  -regulerization to improve condition
%
% Outputs
%       Coeff   -M x N matrix, each row is a code for corresponding X
%
% Jinjun Wang, march 19, 2010
% ========================================================================

% http://blog.sina.com.cn/s/blog_631a4cc40100wdul.html

% negtive coding weight?

function [Coeff] = LLC_coding_appr(B, X, knn, beta)

if ~exist('knn', 'var') || isempty(knn), knn = 5; end
if ~exist('beta', 'var') || isempty(beta), beta = 1e-4; end

nframe=size(X,2);
nbase=size(B,2);

distances = vl_alldist2(B,X);
[~, IDX] = sort(distances);
IDX = IDX(1:knn, :);

% llc approximation coding
II = eye(knn, knn);
Coeff = zeros(nbase, nframe);
for i=1:nframe
   idx = IDX(:,i);
   z = B(:,idx) - repmat(X(:,i), 1, knn);           % shift ith pt to origin
   C = z'*z;                                        % local covariance
   C = C + II*beta*trace(C);                        % regularlization (K>D)
   w = C\ones(knn,1);
%    w(0>w) = 0;
   w = w/sum(w);                                    % enforce sum(w)=1
   Coeff(idx,i) = w;
end

end
