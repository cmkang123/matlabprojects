function cogs = getCellCentroidsAll(cells2edges,edges2pixels,edgeIDs_all,...
    sizeR,sizeC,edges2nodes,nodeInds)

% Output:
%   cogs - column vector containing centres of gravity for all the cells as
%   listed in cells2edges. each element is a structure s.t. (cogs(i).x,cogs(i).y)
%   is the centre of gravity

numCells = size(cells2edges,1);
for i=1:numCells
    clear edgeIDset_cell
    edgeIDset_cell = cells2edges(i,:);
    edgeIDset_cell = edgeIDset_cell(edgeIDset_cell>0);
    cogs(i) = getCellCentroid(edgeIDset_cell,edges2pixels,edgeIDs_all,...
    sizeR,sizeC,edges2nodes,nodeInds);
end
    