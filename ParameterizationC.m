%%  return parameterized mesh
%%
%%  Input:  //
%%  Output: //

function [vertex] = ParameterizationC(dsInd, dwInd, deInd, MS, MSE, MW, MWE, ME, CSx, CSy, CWx, CWy, CEx, CEy, ...
                                      Vertex, I, nI, B, nB, numDecompose)

%% do the parameterization by solving the reformed linear system

% direct solver
fprintf('starting parameterization using conjugate solver ...\n');
[XSx, XWx, XEx, itx, tx] = ConjSolver(MS, MSE, MW, MWE, ME, CSx, CWx, CEx, numDecompose);
[XSy, XWy, XEy, ity, ty] = ConjSolver(MS, MSE, MW, MWE, ME, CSy, CWy, CEy, numDecompose);
fprintf('parameterization using conjugate solver done\n');
fprintf('parameterization running iteration: %d\nparameterization running time: %f s\n\n\n\n', round((itx + ity) / 2), (tx + ty) / 2);

%% compute the result

X = zeros(nI, 1);
Y = zeros(nI, 1);
for i = 1:numDecompose
    X(dsInd{i}) = XSx{i};
    Y(dsInd{i}) = XSy{i};
end
X(dwInd) = XWx;
Y(dwInd) = XWy;
X(deInd) = XEx;
Y(deInd) = XEy;

%% set the parameterized meshes

vertex = Vertex;
vertex(:, 3) = 0;
vertex(B, 1:2) = SquareBoundary(nB);
vertex(I, 1) = X;
vertex(I, 2) = Y;

end