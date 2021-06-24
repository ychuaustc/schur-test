function [VertexU, t, iterARAP, iterSchur] = IterConjPre(MThetaLVX, MThetaLVY, MSS, MSEall, MWW, MWE, MEE, MEE_W, ...
                                             LW, LE, dsInd, dwInd, deInd, dssize, Face, FXV, FYV, FCotTheta, EnULOld, nV, nF, ...
                                             numDecompose, epsArap, epsSchur)
%
%   this function do the iterative step with preconditioned conjugate sovler
%
%   INPUT:  MThetaLVX - assign the x-coordinate value of cot(theta) * L(V) to the adjacent matrix
%           MThetaLVY - assign the y-coordinate value of cot(theta) * L(V) to the adjacent matrix
%           MSS - the subdomain matrix for the Schur system
%           MSE - the subdomain-edge matrix for the Schur system
%           MWW - the wirebasket matrix for the Schur system
%           MWE - the wirebasket-edge matrix for the Schur system
%           MEE - the edge matrix for the Schur system
%           MEE_W - the wirebasket matrix block
%           LW - the wirebasket part of the Lagrangian multiplier
%           LE - the edge part of the Lagrangian multiplier
%           dsInd - the index for the subdomains
%           dwInd - the index for the wirebasket
%           deInd - the index for the edge
%           Face - mesh faces
%           FXV - x-coordinates for the face matrix-V
%           FYV - y-coordinates for the face matrix-V
%           FCotTheta - the cotangent value of the face matrix
%           EnULOld - the ARAP energy E(U, L)
%           nV - mesh size
%           nF - number of faces
%           numDecompose - decomposition number
%           epsARAP - convergence error for ARAP method
%           epsSchur - convergence error for Schur method
%
%   OUTPUT: 
%           VertexU - mesh vertices
%           t - running time
%           iterARAP - ARAP method iteration time
%           iterSchur - Schur method iteration time


iterARAP = 0;   % iteration count

%   iteration
while 1
	iterARAP = iterARAP + 1;
	CX = ArapSystemC(MThetaLVX);
	CY = ArapSystemC(MThetaLVY);
    
    %   compute solver for MSS and preconditioner
    MSSsolver = findsolverSS(MSS, numDecompose);
    presolver = findsolverPre(MWW, MWE, MEE_W);
    %   preconditioned conjugate gradient solver
    [CSX, CWX, bX] = SchurSystemC(MSEall, MWW, MWE, CX, dsInd, dwInd, deInd, MSSsolver, numDecompose);
    [CSY, CWY, bY] = SchurSystemC(MSEall, MWW, MWE, CY, dsInd, dwInd, deInd, MSSsolver, numDecompose);
    %   solve the solution
    [XU, iter_X{iterARAP}, t_X{iterARAP}] ...
    = SchurConjPreSolver(MSEall, MWW, MWE, MEE, MEE_W, LW, LE, CSX, CWX, bX, dsInd, dwInd, deInd, MSSsolver, presolver, dssize, nV, numDecompose, epsSchur);
    [YU, iter_Y{iterARAP}, t_Y{iterARAP}] ...
    = SchurConjPreSolver(MSEall, MWW, MWE, MEE, MEE_W, LW, LE, CSY, CWY, bY, dsInd, dwInd, deInd, MSSsolver, presolver, dssize, nV, numDecompose, epsSchur);
    
	VertexU = [XU, YU];
	[FXU, FYU] = FaceCoord(VertexU, Face);
	[FLVX, FLVY, MThetaLVX, MThetaLVY] ...
    = ArapL(FXV, FYV, FXU, FYU, FCotTheta, Face, nV, nF);	% compute the rotation L for current iteration
 	EnULNew = EnergyUL(FCotTheta, FLVX, FLVY, FXU, FYU);    % compute the ARAP energy for current iteration
    
 	if abs(EnULNew - EnULOld) / nF >= epsArap
        EnULOld = EnULNew;
    else
        break;
	end
end

%   running time
t = 0;
for i = 1:iterARAP
    t = t + t_X{i} + t_Y{i};
end
t = t / (iterARAP * 2);

%   iteration time
iterSchur = 0;
for i = 1:iterARAP
    iterSchur = iterSchur + iter_X{i} + iter_Y{i};
end
iterSchur = floor(iterSchur / (iterARAP * 2));

VertexU = full(VertexU);


end