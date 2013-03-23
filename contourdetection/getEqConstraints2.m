function [Aeq,beq] = getEqConstraints2(numEdges,jEdges)

[~, numJtypes] = size(jEdges);
% type 1 is J2 - junction with just 2 edges
nodeTypeStats = zeros(numJtypes,2);
% each row corresponds to a junction type. row 1: type 1 (J2)
% column 1: n.o. junction nodes of this type
% column 2: n.o. edge pair combinations to be activated
totJunctionVar = zeros(numJtypes,1); % stores the number of coefficients for each type of J
for i=1:numJtypes
    jEdges_i = jEdges{i};
    [numJ_i,numEdges_i] = size(jEdges_i);
    nodeTypeStats(i,1) = numJ_i;
    nodeTypeStats(i,2) = numEdges_i;
    numEdgeCombinations = nchoosek(numEdges_i,2);
    totJunctionVar(i) = numJ_i.*(numEdgeCombinations + 1); % 1 for the inactive node
    clear nodeAngleCost_i
end

numJ3 = size(j3Edges,1);
numJ4 = size(j4Edges,1);

% num cols of Aeq = 2*numEdges + sum_j(numNodes_j*numCombinations+1)
numCols_Aeq = 2*numEdges + sum(totJunctionVar); 
% num cols of Aeq = numEdges + 2*numJ
numRows_Aeq = numEdges + sum(nodeTypeStats(:,1))*2;

Aeq = zeros(numRows_Aeq,numCols_Aeq);
beq = zeros(numRows_Aeq,1);
beq(1:(numEdges + sum(nodeTypeStats(:,1)))) = 1;

%% activation/inactivation constraints for each edge
j = 1;
for i=1:numEdges
    Aeq(i,j:(j+1)) = 1;
    j = j+2;
end

%% activation/inactivation constraints for each junction node
colStop = numEdges*2;
rowStop = numEdges;
for jType = 1:numJtypes
    % for each junction type
    numNodes_j = nodeTypeStats(jType,1);
    numEdgePJ = jType + 1;      % number of edges per junction
    numCoef = nchoosek(numEdgePJ,2) + 1; % num edge pair combinations + inactivation  
    rowStart = rowStop + 1; 
    rowStop = rowStart - 1 + numNodes_j;
    for row=rowStart:rowStop
        colStart = colStop + 1;
        colStop = colStart - 1 + numCoef;
        Aeq(row,colStart:colStop) = 1;
    end    
end

% % J3
% j = numEdges*2+1;
% for i=(numEdges+1):(numEdges+numJ3)
%     Aeq(i,j:(j+3)) = 1;
%     j = j+4;
% end
% % J4
% j = numEdges*2+numJ3*4+1;
% for i=(numEdges+numJ3+1):(numEdges+numJ3+numJ4)
%     Aeq(i,j:(j+6)) = 1;
%     j = j+7;
% end

%% closedness constraints
% for each node, either exactly two edges should be active (active node) or
% all the edges should be inactive (inactive node)
numNodesTot = sum(nodeTypeStats(:,1));
rowStop = numEdges + numNodesTot;
jColIdStop = numEdges*2;
for jType=1:numJtypes
    % for each junction type
    % for each node, get the indices of the activeState edge variables
    jEdges_j = cell2mat(jEdges{jType});
    numNodes_j = nodeTypeStats(jType,1);
    activeEdgeColInds = jEdges_j*2;     % edges are represented in pairs of state variables
                                        % the second element corresponds to
                                        % the active state
    % for each junction for type j
    rowStart = rowStop + 1;
    rowStop = rowStart - 1 + numNodes_j;
    k = 1;
    for row=rowStart:rowStop
        Aeq(row,activeEdgeColInds(k,:)) = 1; 
        k = k + 1;
        numEdges_i = nodeTypeStats(jType,2);
        numEdgeCombinations_j = nchoosek(numEdges_i,2);
        jIds = (jColIdStop+2):(jColIdStop+numEdgeCombinations_j);
        Aeq(row,jIds) = -2;               % refer closedness constraint formulation
        jColIdStop = jColIdStop + numEdgeCombinations_j;
    end
        
end



% % for all nodes, get the active edge state variable indices
% j3ActiveEdgeColInds = j3Edges .*2;
% j4ActiveEdgeColInds = j4Edges .*2;
% 
% % J3
% jColId = numEdges*2;
% k = 1;
% for i=(numEdges+numJ3+numJ4+1):(numEdges+numJ3*2+numJ4)
%    Aeq(i,j3ActiveEdgeColInds(k,:)) = 1;          % marks active edges for junction i
%    k = k+1;
%    jIds = (jColId+2):(jColId+4);        % activate the 3 active states coeff for J3
%    Aeq(i,jIds) = -2;                      % refer closedness constraint formulation
%    
%    % finally
%    jColId = jColId + 4;
% end
% 
% % J4
% jColId = numEdges*2 + numJ3*4;
% k = 1;
% for i=(numEdges+numJ3*2+numJ4+1):(numEdges+numJ3*2+numJ4*2)
%    Aeq(i,j4ActiveEdgeColInds(k,:)) = 1;          % marks active edges for junction i
%    k = k+1;
%    jIds = (jColId+2):(jColId+7);        % activate the 6 active states coeff for J4
%    Aeq(i,jIds) = -2;                      % refer closedness constraint formulation
%    
%    % finally
%    jColId = jColId + 7;
% end
