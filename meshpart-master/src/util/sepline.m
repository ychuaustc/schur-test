function [bestline,linequality] = sepline(A,xy,ntries)
% SEPLINE Good separating line (or plane) for geometric partitioning.
%
%   [bestline,linequality] = sepline(A,xy,ntries) Generate cutting planes in
%   the d-dimensional mesh space, trying to find one that gives a good edge
%   separator of the graph A. "xy" is the input points, in the mesh space
%   (not conformally mapped). "ntries" optional (optional, default 2*d) is
%   the number of planes to try. We generate the planes at random, weighted
%   toward the first singular vector of the matrix of coordinates. The
%   weighting becomes weaker as the number of tries goes up. "bestline" is
%   returned as a vector normal to the best line/plane. "linequality" is the
%   quality of its partition as measured by "sequality".
%
%   See GEOPART.

% Yingzhou Li, 2017
% John Gilbert and Shanghua Teng, 1992-1993.
% Copyright (c) 1990-1996 by Xerox Corporation.  All rights reserved.
% HELP COPYRIGHT for complete copyright and licensing notice.
%
% Modified by Tim Davis, for Matlab 5.1.  Jul 6, 1998.
% Modified by Yingzhou Li, for Matlab 8.  Feb 9, 2017.

d = size(xy,2);

if nargin < 3
    ntries = 2*d;
end

if ntries == 0
    linequality = Inf;
    bestline = NaN(1,d);
    return;
end

[~,S,V] = svd(xy,0);

if ntries == 1
    % With only one try, use the singular vector.
    vv = V(:,1)';
else
    % "exponent" determines the weighting.
    % This formula is ad hoc, but seems pretty good.
    exponent = 2*(d+1)/(ntries-1);
    s = diag(S).^exponent;
    W = (V * diag(s) * V');
    vv = randn(ntries,d) * W;
    rownorms = sqrt(sum(vv.*vv,2));
    vv = diag(1./rownorms) * vv;
end

linequality = Inf;
for i = 1 : ntries
    v = vv(i,:);
    quality = sepquality(v,A,xy);
    if quality < linequality
        linequality = quality;
        bestline = v;
    end
end

end